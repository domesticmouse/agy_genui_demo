import 'dart:async';

import 'package:antigravity/antigravity.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../data/repositories/chat_repository.dart';
import '../../../../domain/models/chat_models.dart';

/// ViewModel managing macOS Markdown chat projects (working directories),
/// per-project conversation threads, per-thread Antigravity agent streaming
/// state, sandbox-escape command review prompts, sidebar collapse state, and
/// Material 3 theme mode.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    ChatRepository? repository,
    this.responseDelay = Duration.zero,
  }) : _repository = repository ?? ChatRepository() {
    _repository.commandApprovalHandler ??= _handleCommandApprovalRequest;
    _projects.addAll(_repository.getStarterProjects());
    if (_projects.isNotEmpty) {
      _activeProjectId = _projects.first.id;
    }
    _threads.addAll(_repository.getStarterThreads());
    final initialProjectThreads = threads;
    if (initialProjectThreads.isNotEmpty) {
      _activeThreadId = initialProjectThreads.first.id;
    } else if (_threads.isNotEmpty) {
      _activeThreadId = _threads.first.id;
    }
  }

  final ChatRepository _repository;
  final Duration responseDelay;

  final List<ChatProject> _projects = [];
  final List<ChatThread> _threads = [];
  final Map<String, StreamSubscription<String>> _replySubscriptions = {};
  final Map<String, int> _activeRequestIds = {};

  final List<PendingCommandReview> _pendingReviews = [];
  final Map<String, Completer<bool>> _reviewCompleters = {};
  final Map<String, String> _threadDrafts = {};

  String _activeProjectId = ChatThread.defaultProjectId;
  String _activeThreadId = '';
  bool _isSidebarOpen = true;
  bool _isPreviewVisible = false;
  ThemeMode _themeMode = ThemeMode.light;
  int _idCounter = 100;
  bool _isDisposed = false;

  ChatRepository get repository => _repository;
  List<ChatProject> get projects => List.unmodifiable(_projects);
  String get activeProjectId => _activeProjectId;

  ChatProject? get activeProject {
    for (final project in _projects) {
      if (project.id == _activeProjectId) {
        return project;
      }
    }
    return _projects.isNotEmpty ? _projects.first : null;
  }

  /// Threads belonging to the currently active [ChatProject].
  List<ChatThread> get threads => List.unmodifiable(
    _threads.where((t) => t.projectId == _activeProjectId),
  );

  /// All threads across all projects.
  List<ChatThread> get allThreads => List.unmodifiable(_threads);

  String get activeThreadId => _activeThreadId;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isPreviewVisible => _isPreviewVisible;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// All pending sandbox-escape command reviews across threads.
  List<PendingCommandReview> get pendingCommandReviews =>
      List.unmodifiable(_pendingReviews);

  /// Pending sandbox-escape command reviews for the currently active thread.
  List<PendingCommandReview> get activeThreadPendingReviews =>
      List.unmodifiable(
        _pendingReviews.where((r) => r.threadId == _activeThreadId),
      );

  /// Returns the number of pending command reviews for [threadId].
  int pendingReviewCountForThread(String threadId) {
    return _pendingReviews.where((r) => r.threadId == threadId).length;
  }

  /// Returns the unsent composer draft saved for [threadId].
  String draftForThread(String threadId) => _threadDrafts[threadId] ?? '';

  /// Returns the unsent composer draft for the currently active thread.
  String get activeThreadDraft =>
      _activeThreadId.isEmpty ? '' : draftForThread(_activeThreadId);

  /// Saves the unsent composer [draft] for the currently active thread.
  void updateActiveThreadDraft(String draft) {
    if (_activeThreadId.isEmpty) return;
    if (draft.isEmpty) {
      _threadDrafts.remove(_activeThreadId);
    } else {
      _threadDrafts[_activeThreadId] = draft;
    }
  }

  ChatThread? get activeThread {
    for (final thread in _threads) {
      if (thread.id == _activeThreadId &&
          thread.projectId == _activeProjectId) {
        return thread;
      }
    }
    final projectThreads = threads;
    return projectThreads.isNotEmpty ? projectThreads.first : null;
  }

  /// Finds the [ChatProject] for [projectId], falling back to [activeProject].
  ChatProject? projectById(String projectId) {
    for (final project in _projects) {
      if (project.id == projectId) {
        return project;
      }
    }
    return activeProject;
  }

  /// Toggles the collapsible macOS split-view sidebar.
  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  /// Toggles between Material 3 Light and Dark themes.
  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  /// Toggles the live Markdown preview in the composer.
  void togglePreview() {
    _isPreviewVisible = !_isPreviewVisible;
    notifyListeners();
  }

  /// Selects a [ChatProject] by [projectId] and activates its top thread
  /// (creating a new thread if the project has none).
  void selectProject(String projectId) {
    final exists = _projects.any((p) => p.id == projectId);
    if (!exists) return;
    _activeProjectId = projectId;
    final projectThreads = _threads
        .where((t) => t.projectId == projectId)
        .toList();
    if (projectThreads.isEmpty) {
      createNewThread();
      return;
    }
    if (!projectThreads.any((t) => t.id == _activeThreadId)) {
      _activeThreadId = projectThreads.first.id;
    }
    notifyListeners();
  }

  /// Creates and selects a new [ChatProject] with [workingDirectory] as its
  /// Antigravity harness workspace, and initializes an empty thread in it.
  ChatProject createProject({
    required String name,
    required String workingDirectory,
  }) {
    _idCounter++;
    final normalizedDir = ChatRepository.normalizeProjectDirectory(
      workingDirectory,
    );
    final trimmedName = name.trim();
    final effectiveName = trimmedName.isNotEmpty
        ? trimmedName
        : (p.basename(normalizedDir).isNotEmpty
              ? p.basename(normalizedDir)
              : 'Project $_idCounter');

    final newProject = ChatProject(
      id: 'project-$_idCounter',
      name: effectiveName,
      workingDirectory: normalizedDir,
      createdAt: DateTime.now(),
    );
    _projects.insert(0, newProject);
    _activeProjectId = newProject.id;
    createNewThread();
    return newProject;
  }

  /// Updates the name and/or working directory of [projectId], closing any
  /// existing Antigravity harness sessions in that project so subsequent turns
  /// use the new workspace directory.
  void updateProject(
    String projectId, {
    String? name,
    required String workingDirectory,
  }) {
    final index = _projects.indexWhere((proj) => proj.id == projectId);
    if (index == -1) return;

    final current = _projects[index];
    final normalizedDir = ChatRepository.normalizeProjectDirectory(
      workingDirectory,
    );
    final trimmedName = name?.trim();
    final updatedName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : current.name;

    _projects[index] = current.copyWith(
      name: updatedName,
      workingDirectory: normalizedDir,
    );

    if (current.workingDirectory != normalizedDir) {
      for (final thread in _threads.where((t) => t.projectId == projectId)) {
        unawaited(_repository.closeThreadSession(thread.id));
      }
    }
    notifyListeners();
  }

  /// Selects a conversation thread by [threadId] (switching to its project if needed).
  void selectThread(String threadId) {
    if (_activeThreadId == threadId) return;
    ChatThread? target;
    for (final thread in _threads) {
      if (thread.id == threadId) {
        target = thread;
        break;
      }
    }
    if (target == null) return;
    _activeProjectId = target.projectId;
    _activeThreadId = target.id;
    notifyListeners();
  }

  /// Creates and selects a new empty conversation thread in the active project.
  ChatThread createNewThread() {
    _idCounter++;
    final newThread = ChatThread(
      id: 'thread-$_idCounter',
      projectId: _activeProjectId,
      title: 'New Thread',
      messages: const [],
      updatedAt: DateTime.now(),
      isTyping: false,
      isAutoTitled: false,
    );
    _threads.insert(0, newThread);
    _activeThreadId = newThread.id;
    notifyListeners();
    return newThread;
  }

  /// Deletes a conversation thread, rejects any pending command reviews for it,
  /// stops its Antigravity agent session, and ensures a valid active thread remains.
  void deleteThread(String threadId) {
    _activeRequestIds.remove(threadId);
    _threadDrafts.remove(threadId);
    _denyPendingReviewsForThread(threadId);
    unawaited(_replySubscriptions.remove(threadId)?.cancel());
    unawaited(_repository.closeThreadSession(threadId));

    _threads.removeWhere((t) => t.id == threadId);
    final remainingInProject = _threads
        .where((t) => t.projectId == _activeProjectId)
        .toList();
    if (remainingInProject.isEmpty) {
      createNewThread();
      return;
    }
    if (_activeThreadId == threadId) {
      _activeThreadId = remainingInProject.first.id;
    }
    notifyListeners();
  }

  /// Renames [threadId] to [newTitle] and refreshes its Antigravity session so
  /// subsequent turns include the updated title in system instructions.
  void renameThread(String threadId, String newTitle) {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index == -1) return;

    final current = _threads[index];
    if (current.title == trimmed && current.isAutoTitled) return;

    _threads[index] = current.copyWith(
      title: trimmed,
      isAutoTitled: true,
      updatedAt: DateTime.now(),
    );
    unawaited(_repository.closeThreadSession(threadId));
    notifyListeners();
  }

  /// Handles an incoming sandbox-escape approval request from [ChatRepository]
  /// by enqueueing a [PendingCommandReview] and awaiting the user's decision in the UI.
  Future<bool> _handleCommandApprovalRequest(
    ToolCall toolCall, {
    required String threadId,
    required String threadTitle,
    required String projectId,
    required String workingDirectory,
    required String reason,
  }) {
    if (_isDisposed) {
      return Future<bool>.value(false);
    }

    final reviewId = 'review-${++_idCounter}';
    final commandLine = ChatRepository.extractCommandLine(toolCall);
    final displayCommand = commandLine.isNotEmpty
        ? commandLine
        : '${toolCall.name}(${toolCall.args})';

    final review = PendingCommandReview(
      id: reviewId,
      threadId: threadId,
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: workingDirectory,
      toolName: toolCall.name,
      commandLine: displayCommand,
      toolSummary: ChatRepository.extractToolSummary(toolCall),
      bypassSandbox: ChatRepository.requestsBypassSandboxFlag(toolCall),
      reason: reason,
      rawArgs: Map<String, dynamic>.unmodifiable(toolCall.args),
      timestamp: DateTime.now(),
    );

    final completer = Completer<bool>();
    _pendingReviews.add(review);
    _reviewCompleters[reviewId] = completer;
    notifyListeners();
    return completer.future;
  }

  /// Approves a pending sandbox-escape command review so the harness can execute it.
  void approveCommandReview(String reviewId) {
    _resolveCommandReview(reviewId, approved: true);
  }

  /// Denies a pending sandbox-escape command review so the harness blocks execution.
  void denyCommandReview(String reviewId) {
    _resolveCommandReview(reviewId, approved: false);
  }

  void _resolveCommandReview(String reviewId, {required bool approved}) {
    _pendingReviews.removeWhere((r) => r.id == reviewId);
    final completer = _reviewCompleters.remove(reviewId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(approved);
    }
    notifyListeners();
  }

  void _denyPendingReviewsForThread(String threadId) {
    final matchingIds = _pendingReviews
        .where((r) => r.threadId == threadId)
        .map((r) => r.id)
        .toList();
    for (final id in matchingIds) {
      _pendingReviews.removeWhere((r) => r.id == id);
      final completer = _reviewCompleters.remove(id);
      if (completer != null && !completer.isCompleted) {
        completer.complete(false);
      }
    }
  }

  /// Derives a concise, human-readable thread title from raw Markdown [input].
  static String deriveThreadTitle(String input) {
    final lines = input
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return 'New Thread';

    var candidate = lines.first;
    // Strip leading Markdown block syntax (# headings, > blockquotes, -/* lists)
    candidate = candidate.replaceFirst(RegExp(r'^[#>*\-\+\d\.\s]+'), '');
    // Strip inline formatting markers (**, *, ~~, `)
    candidate = candidate.replaceAll(RegExp(r'[*~`]+'), '').trim();

    if (candidate.isEmpty) return 'New Thread';
    const maxLength = 34;
    if (candidate.length > maxLength) {
      return '${candidate.substring(0, maxLength).trimRight()}...';
    }
    return candidate;
  }

  /// Sends a user Markdown message in the currently active thread, updates the
  /// thread title automatically if untitled, and streams the Antigravity
  /// assistant response configured with the project's working directory.
  void sendMessage(String rawMarkdown) {
    final content = rawMarkdown.trim();
    if (content.isEmpty) return;

    var current = activeThread ?? createNewThread();
    final threadId = current.id;
    _threadDrafts.remove(threadId);
    final projectId = current.projectId;
    final project = projectById(projectId);
    final workingDir =
        project?.workingDirectory ??
        ChatRepository.resolveDefaultWorkingDirectory();

    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index == -1) return;

    _idCounter++;
    final userMessage = ChatMessage(
      id: 'msg-$_idCounter',
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    final shouldAutoTitle = !current.isAutoTitled || current.messages.isEmpty;
    final updatedTitle = shouldAutoTitle
        ? deriveThreadTitle(content)
        : current.title;

    final updatedMessages = [...current.messages, userMessage];
    final updatedThread = current.copyWith(
      title: updatedTitle,
      messages: updatedMessages,
      updatedAt: DateTime.now(),
      isTyping: true,
      isAutoTitled: true,
    );

    _threads[index] = updatedThread;
    notifyListeners();

    unawaited(_replySubscriptions.remove(threadId)?.cancel());
    final requestId = ++_idCounter;
    final assistantMessageId = 'msg-${++_idCounter}';
    final buffer = StringBuffer();
    _activeRequestIds[threadId] = requestId;

    final subscription = _createReplyStream(
      content,
      threadId: threadId,
      threadTitle: updatedTitle,
      projectId: projectId,
      workingDirectory: workingDir,
    ).listen(
      (chunk) {
        if (_isDisposed || _activeRequestIds[threadId] != requestId) return;
        buffer.write(chunk);
        _upsertAssistantMessage(
          threadId: threadId,
          messageId: assistantMessageId,
          content: buffer.toString(),
          isTyping: true,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_isDisposed || _activeRequestIds[threadId] != requestId) return;
        _activeRequestIds.remove(threadId);
        _replySubscriptions.remove(threadId);
        final errorMarkdown = buffer.isEmpty
            ? _formatErrorMarkdown(error)
            : '$buffer\n\n---\n${_formatErrorMarkdown(error)}';
        _upsertAssistantMessage(
          threadId: threadId,
          messageId: assistantMessageId,
          content: errorMarkdown,
          isTyping: false,
        );
      },
      onDone: () {
        if (_isDisposed || _activeRequestIds[threadId] != requestId) return;
        _activeRequestIds.remove(threadId);
        _replySubscriptions.remove(threadId);
        final finalContent = buffer.isEmpty
            ? '_No response returned by Antigravity agent._'
            : buffer.toString();
        _upsertAssistantMessage(
          threadId: threadId,
          messageId: assistantMessageId,
          content: finalContent,
          isTyping: false,
        );
      },
    );

    _replySubscriptions[threadId] = subscription;
  }

  Stream<String> _createReplyStream(
    String userPrompt, {
    required String threadId,
    required String threadTitle,
    required String projectId,
    required String workingDirectory,
  }) async* {
    if (responseDelay > Duration.zero) {
      await Future<void>.delayed(responseDelay);
    }
    yield* _repository.streamAssistantReply(
      userPrompt,
      threadId: threadId,
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: workingDirectory,
    );
  }

  void _upsertAssistantMessage({
    required String threadId,
    required String messageId,
    required String content,
    required bool isTyping,
  }) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index == -1) return;

    final thread = _threads[index];
    final messages = List<ChatMessage>.from(thread.messages);
    final existingIndex = messages.indexWhere((m) => m.id == messageId);

    if (existingIndex == -1) {
      messages.add(
        ChatMessage(
          id: messageId,
          role: MessageRole.assistant,
          content: content,
          timestamp: DateTime.now(),
        ),
      );
    } else {
      messages[existingIndex] = ChatMessage(
        id: messageId,
        role: MessageRole.assistant,
        content: content,
        timestamp: messages[existingIndex].timestamp,
      );
    }

    _threads[index] = thread.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
      isTyping: isTyping,
    );
    notifyListeners();
  }

  String _formatErrorMarkdown(Object error) {
    return '''### Antigravity Backend Error

The local Antigravity agent encountered an error while generating a reply:

```text
$error
```

> **Tip:** Make sure `GEMINI_API_KEY` is set in your environment (`export GEMINI_API_KEY="your_api_key"`) or passed via `--dart-define=GEMINI_API_KEY=your_api_key`.''';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _activeRequestIds.clear();
    for (final completer in _reviewCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    _reviewCompleters.clear();
    _pendingReviews.clear();
    for (final subscription in _replySubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _replySubscriptions.clear();
    unawaited(_repository.dispose());
    super.dispose();
  }
}

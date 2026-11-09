import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/chat_repository.dart';
import '../../../../domain/models/chat_models.dart';

/// ViewModel managing macOS Markdown chat threads, per-thread Antigravity
/// agent streaming state, automatic thread titling, sidebar collapse state,
/// and Material 3 theme mode.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    ChatRepository? repository,
    this.responseDelay = Duration.zero,
  }) : _repository = repository ?? ChatRepository() {
    _threads.addAll(_repository.getStarterThreads());
    if (_threads.isNotEmpty) {
      _activeThreadId = _threads.first.id;
    }
  }

  final ChatRepository _repository;
  final Duration responseDelay;

  final List<ChatThread> _threads = [];
  final Map<String, StreamSubscription<String>> _replySubscriptions = {};
  final Map<String, int> _activeRequestIds = {};

  String _activeThreadId = '';
  bool _isSidebarOpen = true;
  bool _isPreviewVisible = false;
  ThemeMode _themeMode = ThemeMode.light;
  int _idCounter = 100;
  bool _isDisposed = false;

  ChatRepository get repository => _repository;
  List<ChatThread> get threads => List.unmodifiable(_threads);
  String get activeThreadId => _activeThreadId;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isPreviewVisible => _isPreviewVisible;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ChatThread? get activeThread {
    for (final thread in _threads) {
      if (thread.id == _activeThreadId) {
        return thread;
      }
    }
    return _threads.isNotEmpty ? _threads.first : null;
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

  /// Selects a conversation thread by [threadId].
  void selectThread(String threadId) {
    if (_activeThreadId == threadId) return;
    final exists = _threads.any((t) => t.id == threadId);
    if (!exists) return;
    _activeThreadId = threadId;
    notifyListeners();
  }

  /// Creates and selects a new empty conversation thread.
  ChatThread createNewThread() {
    _idCounter++;
    final newThread = ChatThread(
      id: 'thread-$_idCounter',
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

  /// Deletes a conversation thread, stops its Antigravity agent session, and
  /// ensures a valid active thread remains.
  void deleteThread(String threadId) {
    _activeRequestIds.remove(threadId);
    unawaited(_replySubscriptions.remove(threadId)?.cancel());
    unawaited(_repository.closeThreadSession(threadId));

    _threads.removeWhere((t) => t.id == threadId);
    if (_threads.isEmpty) {
      createNewThread();
      return;
    }
    if (_activeThreadId == threadId) {
      _activeThreadId = _threads.first.id;
    }
    notifyListeners();
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
  /// assistant response for that thread.
  void sendMessage(String rawMarkdown) {
    final content = rawMarkdown.trim();
    if (content.isEmpty) return;

    var current = activeThread ?? createNewThread();
    final threadId = current.id;
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
  }) async* {
    if (responseDelay > Duration.zero) {
      await Future<void>.delayed(responseDelay);
    }
    yield* _repository.streamAssistantReply(
      userPrompt,
      threadId: threadId,
      threadTitle: threadTitle,
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
    for (final subscription in _replySubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _replySubscriptions.clear();
    unawaited(_repository.dispose());
    super.dispose();
  }
}

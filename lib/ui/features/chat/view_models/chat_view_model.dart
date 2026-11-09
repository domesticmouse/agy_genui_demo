import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/chat_repository.dart';
import '../../../../domain/models/chat_models.dart';

/// ViewModel managing macOS Markdown chat threads, per-thread typing state,
/// automatic thread titling, sidebar collapse state, and Material 3 theme mode.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    ChatRepository? repository,
    this.responseDelay = const Duration(milliseconds: 450),
  }) : _repository = repository ?? const ChatRepository() {
    _threads.addAll(_repository.getStarterThreads());
    if (_threads.isNotEmpty) {
      _activeThreadId = _threads.first.id;
    }
  }

  final ChatRepository _repository;
  final Duration responseDelay;

  final List<ChatThread> _threads = [];
  final Map<String, Timer> _typingTimers = {};

  String _activeThreadId = '';
  bool _isSidebarOpen = true;
  bool _isPreviewVisible = false;
  ThemeMode _themeMode = ThemeMode.light;
  int _idCounter = 100;

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

  /// Deletes a conversation thread and ensures a valid active thread remains.
  void deleteThread(String threadId) {
    _typingTimers.remove(threadId)?.cancel();
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
  /// thread title automatically if untitled, and triggers per-thread typing.
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

    _typingTimers[threadId]?.cancel();
    _typingTimers[threadId] = Timer(responseDelay, () {
      _completeAssistantReply(threadId, content);
    });
  }

  void _completeAssistantReply(String threadId, String userPrompt) {
    _typingTimers.remove(threadId);
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index == -1) return;

    final thread = _threads[index];
    _idCounter++;
    final replyContent = _repository.buildAssistantReply(
      userPrompt,
      threadTitle: thread.title,
    );
    final assistantMessage = ChatMessage(
      id: 'msg-$_idCounter',
      role: MessageRole.assistant,
      content: replyContent,
      timestamp: DateTime.now(),
    );

    _threads[index] = thread.copyWith(
      messages: [...thread.messages, assistantMessage],
      updatedAt: DateTime.now(),
      isTyping: false,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';

/// Role of the author of a [ChatMessage].
enum MessageRole { user, assistant }

/// An immutable chat message containing raw Markdown content.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  bool get isUser => role == MessageRole.user;
}

/// An immutable conversation thread with its own messages and typing state.
@immutable
class ChatThread {
  const ChatThread({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.isTyping = false,
    this.isAutoTitled = false,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;
  final bool isTyping;
  final bool isAutoTitled;

  ChatThread copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    bool? isTyping,
    bool? isAutoTitled,
  }) {
    return ChatThread(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      isTyping: isTyping ?? this.isTyping,
      isAutoTitled: isAutoTitled ?? this.isAutoTitled,
    );
  }
}

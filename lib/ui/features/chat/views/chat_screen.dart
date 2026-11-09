import 'package:flutter/material.dart';

import '../../../../../domain/models/chat_models.dart';
import '../view_models/chat_view_model.dart';
import 'widgets/markdown_composer.dart';
import 'widgets/message_bubble.dart';
import 'widgets/thread_sidebar.dart';
import 'widgets/top_toolbar.dart';

/// Main macOS split-view chat screen with a collapsible thread sidebar,
/// responsive top toolbar, Markdown message feed, and composer.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.viewModel});

  final ChatViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final activeThread = viewModel.activeThread;
        final messages = activeThread?.messages ?? const <ChatMessage>[];
        final isTyping = activeThread?.isTyping ?? false;

        return Scaffold(
          body: Column(
            children: [
              TopToolbar(
                activeThread: activeThread,
                isSidebarOpen: viewModel.isSidebarOpen,
                isDarkMode: viewModel.isDarkMode,
                onToggleSidebar: viewModel.toggleSidebar,
                onNewThread: viewModel.createNewThread,
                onToggleTheme: viewModel.toggleThemeMode,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (viewModel.isSidebarOpen)
                      ThreadSidebar(
                        threads: viewModel.threads,
                        activeThreadId: viewModel.activeThreadId,
                        onSelectThread: viewModel.selectThread,
                        onNewThread: viewModel.createNewThread,
                        onDeleteThread: viewModel.deleteThread,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: messages.isEmpty && !isTyping
                                ? _EmptyThreadPlaceholder(
                                    onQuickPrompt: viewModel.sendMessage,
                                  )
                                : ListView.builder(
                                    key: ValueKey(
                                      'message_list_${activeThread?.id}',
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    itemCount:
                                        messages.length + (isTyping ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == messages.length) {
                                        return const _TypingIndicatorBubble();
                                      }
                                      return MessageBubble(
                                        message: messages[index],
                                      );
                                    },
                                  ),
                          ),
                          MarkdownComposer(
                            isPreviewVisible: viewModel.isPreviewVisible,
                            onTogglePreview: viewModel.togglePreview,
                            onSend: viewModel.sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypingIndicatorBubble extends StatelessWidget {
  const _TypingIndicatorBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const Key('active_thread_typing_indicator'),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Assistant is composing Markdown...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyThreadPlaceholder extends StatelessWidget {
  const _EmptyThreadPlaceholder({required this.onQuickPrompt});

  final ValueChanged<String> onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_chat_unread_outlined,
                size: 44,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Start a New Markdown Thread',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Send your first message below. The conversation title will automatically update from your initial prompt.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Compare Dart collection types'),
                    onPressed: () => onQuickPrompt(
                      'Compare **List**, **Set**, and **Map** in Dart with a Markdown table.',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.code, size: 16),
                    label: const Text('Show async stream example'),
                    onPressed: () => onQuickPrompt(
                      'Show a `Stream<String>` example in Dart using a fenced code block.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

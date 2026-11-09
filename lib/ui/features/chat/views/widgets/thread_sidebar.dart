import 'package:flutter/material.dart';

import '../../../../../domain/models/chat_models.dart';

/// macOS split-view conversation thread sidebar with per-thread typing indicators.
class ThreadSidebar extends StatelessWidget {
  const ThreadSidebar({
    super.key,
    required this.threads,
    required this.activeThreadId,
    required this.onSelectThread,
    required this.onNewThread,
    required this.onDeleteThread,
  });

  final List<ChatThread> threads;
  final String activeThreadId;
  final ValueChanged<String> onSelectThread;
  final VoidCallback onNewThread;
  final ValueChanged<String> onDeleteThread;

  String _previewSnippet(ChatThread thread) {
    if (thread.messages.isEmpty) {
      return 'No messages yet';
    }
    final last = thread.messages.last.content
        .replaceAll(RegExp(r'[#*`>~|]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return last.isEmpty ? 'Empty message' : last;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('thread_sidebar'),
      width: 268,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
            child: Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Threads',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('sidebar_new_thread_button'),
                  tooltip: 'New Conversation Thread',
                  onPressed: onNewThread,
                  icon: const Icon(Icons.edit_square, size: 18),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                final isSelected = thread.id == activeThreadId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isSelected
                        ? colorScheme.primaryContainer.withValues(alpha: 0.75)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      key: Key('thread_tile_${thread.id}'),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onSelectThread(thread.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    thread.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  if (thread.isTyping)
                                    Row(
                                      key: Key('sidebar_typing_${thread.id}'),
                                      children: [
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.8,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Typing...',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      _previewSnippet(thread),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? colorScheme.onPrimaryContainer
                                                      .withValues(alpha: 0.8)
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: Key('delete_thread_${thread.id}'),
                              tooltip: 'Delete Thread',
                              onPressed: () => onDeleteThread(thread.id),
                              icon: Icon(
                                Icons.close,
                                size: 15,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../domain/models/chat_models.dart';

/// macOS split-view conversation sidebar with project workspace switcher,
/// working directory display, and per-thread typing/review indicators.
class ThreadSidebar extends StatelessWidget {
  const ThreadSidebar({
    super.key,
    required this.projects,
    required this.activeProject,
    required this.threads,
    required this.activeThreadId,
    required this.onSelectProject,
    required this.onNewProject,
    required this.onEditProject,
    required this.onSelectThread,
    required this.onNewThread,
    required this.onDeleteThread,
    this.pendingReviewCountForThread,
  });

  final List<ChatProject> projects;
  final ChatProject? activeProject;
  final List<ChatThread> threads;
  final String activeThreadId;
  final ValueChanged<String> onSelectProject;
  final VoidCallback onNewProject;
  final VoidCallback onEditProject;
  final ValueChanged<String> onSelectThread;
  final VoidCallback onNewThread;
  final ValueChanged<String> onDeleteThread;
  final int Function(String threadId)? pendingReviewCountForThread;

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
    final currentProject = activeProject;

    return Container(
      key: const Key('thread_sidebar'),
      width: 280,
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
          // Project Switcher & Working Directory Section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_special_outlined,
                      size: 17,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: PopupMenuButton<String>(
                        key: const Key('project_selector_button'),
                        tooltip: 'Switch Project Workspace',
                        onSelected: onSelectProject,
                        itemBuilder: (context) => [
                          for (final project in projects)
                            PopupMenuItem<String>(
                              key: Key('project_menu_item_${project.id}'),
                              value: project.id,
                              child: Row(
                                children: [
                                  Icon(
                                    project.id == currentProject?.id
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          project.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          project.workingDirectory,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontFamily: 'Menlo',
                                                fontSize: 10.5,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentProject?.name ?? 'No Project',
                                  key: const Key('active_project_name'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.unfold_more,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('edit_project_directory_button'),
                      tooltip: 'Edit Project Working Directory',
                      onPressed: onEditProject,
                      icon: const Icon(Icons.tune, size: 17),
                    ),
                    IconButton(
                      key: const Key('new_project_button'),
                      tooltip: 'New Project',
                      onPressed: onNewProject,
                      icon: const Icon(
                        Icons.create_new_folder_outlined,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Tooltip(
                  message:
                      'Antigravity harness working directory: ${currentProject?.workingDirectory ?? ''}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: onEditProject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.terminal,
                            size: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              currentProject?.workingDirectory ?? '',
                              key: const Key('active_project_directory'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'Menlo',
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Threads Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 6),
            child: Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 17,
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
                final pendingReviews =
                    pendingReviewCountForThread?.call(thread.id) ?? 0;

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
                                  if (pendingReviews > 0)
                                    Row(
                                      key: Key('sidebar_review_${thread.id}'),
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 13,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Review required ($pendingReviews)',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: colorScheme.error,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (thread.isTyping)
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

import 'package:flutter/material.dart';

import '../../../../../domain/models/chat_models.dart';

/// Responsive macOS top toolbar with split-view sidebar toggle, active thread
/// status, active project workspace indicator, new thread action, and
/// Material 3 Light/Dark theme switching.
class TopToolbar extends StatelessWidget {
  const TopToolbar({
    super.key,
    required this.activeProject,
    required this.activeThread,
    required this.isSidebarOpen,
    required this.isDarkMode,
    required this.onToggleSidebar,
    required this.onEditProject,
    required this.onNewThread,
    required this.onToggleTheme,
  });

  final ChatProject? activeProject;
  final ChatThread? activeThread;
  final bool isSidebarOpen;
  final bool isDarkMode;
  final VoidCallback onToggleSidebar;
  final VoidCallback onEditProject;
  final VoidCallback onNewThread;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final threadTitle = activeThread?.title ?? 'No Active Thread';
    final isTyping = activeThread?.isTyping ?? false;
    final messageCount = activeThread?.messages.length ?? 0;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final showProjectChip = constraints.maxWidth >= 680;
          return Row(
            children: [
              IconButton(
                key: const Key('toggle_sidebar_button'),
                tooltip: isSidebarOpen ? 'Hide Sidebar' : 'Show Sidebar',
                icon: Icon(
                  isSidebarOpen
                      ? Icons.view_sidebar
                      : Icons.view_sidebar_outlined,
                ),
                onPressed: onToggleSidebar,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        threadTitle,
                        key: const Key('active_thread_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$messageCount ${messageCount == 1 ? 'msg' : 'msgs'}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                    if (showProjectChip && activeProject != null) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message:
                            'Project "${activeProject!.name}" working directory: ${activeProject!.workingDirectory}',
                        child: InkWell(
                          key: const Key('toolbar_project_badge'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: onEditProject,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 240),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 13,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    activeProject!.workingDirectory,
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
                    if (isTyping) ...[
                      const SizedBox(width: 8),
                      Container(
                        key: const Key('toolbar_typing_badge'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(width: 6),
                              Text(
                                'Typing...',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isCompact)
                IconButton(
                  key: const Key('toolbar_new_thread_button'),
                  tooltip: 'New Thread',
                  onPressed: onNewThread,
                  icon: const Icon(Icons.add_comment_outlined),
                )
              else
                FilledButton.tonalIcon(
                  key: const Key('toolbar_new_thread_button'),
                  onPressed: onNewThread,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Thread'),
                ),
              const SizedBox(width: 8),
              IconButton(
                key: const Key('theme_toggle_button'),
                tooltip: isDarkMode
                    ? 'Switch to Light Theme'
                    : 'Switch to Dark Theme',
                onPressed: onToggleTheme,
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../domain/models/chat_models.dart';
import '../view_models/chat_view_model.dart';
import 'widgets/markdown_composer.dart';
import 'widgets/message_bubble.dart';
import 'widgets/project_dialog.dart';
import 'widgets/sandbox_review_banner.dart';
import 'widgets/thread_sidebar.dart';
import 'widgets/top_toolbar.dart';

/// Main macOS split-view chat screen with a collapsible project/thread sidebar,
/// responsive top toolbar, Markdown message feed, sandbox-escape command review
/// banner, and composer.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.viewModel});

  final ChatViewModel viewModel;

  Future<void> _handleNewProject(BuildContext context) async {
    final result = await ProjectDialog.show(context);
    if (result != null) {
      viewModel.createProject(
        name: result.name,
        workingDirectory: result.workingDirectory,
      );
    }
  }

  Future<void> _handleEditProject(BuildContext context) async {
    final activeProject = viewModel.activeProject;
    if (activeProject == null) return;
    final result = await ProjectDialog.show(
      context,
      existingProject: activeProject,
    );
    if (result != null) {
      viewModel.updateProject(
        activeProject.id,
        name: result.name,
        workingDirectory: result.workingDirectory,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final activeProject = viewModel.activeProject;
        final activeThread = viewModel.activeThread;
        final messages = activeThread?.messages ?? const <ChatMessage>[];
        final isTyping = activeThread?.isTyping ?? false;
        final pendingReviews = viewModel.activeThreadPendingReviews;

        return Scaffold(
          body: Column(
            children: [
              TopToolbar(
                activeProject: activeProject,
                activeThread: activeThread,
                isSidebarOpen: viewModel.isSidebarOpen,
                isDarkMode: viewModel.isDarkMode,
                onToggleSidebar: viewModel.toggleSidebar,
                onEditProject: () => _handleEditProject(context),
                onNewThread: viewModel.createNewThread,
                onToggleTheme: viewModel.toggleThemeMode,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (viewModel.isSidebarOpen)
                      ThreadSidebar(
                        projects: viewModel.projects,
                        activeProject: activeProject,
                        threads: viewModel.threads,
                        activeThreadId: viewModel.activeThreadId,
                        onSelectProject: viewModel.selectProject,
                        onNewProject: () => _handleNewProject(context),
                        onEditProject: () => _handleEditProject(context),
                        onSelectThread: viewModel.selectThread,
                        onNewThread: viewModel.createNewThread,
                        onDeleteThread: viewModel.deleteThread,
                        pendingReviewCountForThread:
                            viewModel.pendingReviewCountForThread,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: messages.isEmpty && !isTyping
                                ? _EmptyThreadPlaceholder(
                                    activeProject: activeProject,
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
                          SandboxReviewBanner(
                            reviews: pendingReviews,
                            onApprove: viewModel.approveCommandReview,
                            onDeny: viewModel.denyCommandReview,
                          ),
                          MarkdownComposer(
                            activeThreadId: activeThread?.id ?? '',
                            initialDraft: viewModel.activeThreadDraft,
                            onDraftChanged: viewModel.updateActiveThreadDraft,
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
  const _EmptyThreadPlaceholder({
    required this.activeProject,
    required this.onQuickPrompt,
  });

  final ChatProject? activeProject;
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
              if (activeProject != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    'Workspace: ${activeProject!.workingDirectory}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'Menlo',
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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
                  ActionChip(
                    avatar: const Icon(Icons.widgets_outlined, size: 16),
                    label: const Text('Build interactive A2UI v1.0 card'),
                    onPressed: () => onQuickPrompt(
                      'Create an interactive A2UI v1.0 surface with a Card, TextField, and Button alongside a Markdown summary.',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.tune_outlined, size: 16),
                    label: const Text('Clarifying parameter form'),
                    onPressed: () => onQuickPrompt(
                      'Present an interactive A2UI v1.0 clarifying parameter form with ChoicePicker, TextField validation checks, Slider, CheckBox, and Button.',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.sync_alt_outlined, size: 16),
                    label: const Text('Run workspace RPC function'),
                    onPressed: () => onQuickPrompt(
                      'Run the workspace RPC functions getWorkspaceInfo and listWorkspaceFiles via callRendererFunction.',
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

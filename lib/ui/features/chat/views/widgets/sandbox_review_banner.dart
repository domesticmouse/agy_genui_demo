import 'package:flutter/material.dart';

import '../../../../../domain/models/chat_models.dart';

/// Displays an interactive review banner when an Antigravity agent session
/// requests to run a command or program that escapes the project sandbox.
class SandboxReviewBanner extends StatelessWidget {
  const SandboxReviewBanner({
    super.key,
    required this.reviews,
    required this.onApprove,
    required this.onDeny,
  });

  final List<PendingCommandReview> reviews;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onDeny;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('sandbox_review_banner'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.35),
        border: Border(
          top: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 230),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < reviews.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _SandboxReviewCard(
                  review: reviews[i],
                  onApprove: () => onApprove(reviews[i].id),
                  onDeny: () => onDeny(reviews[i].id),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SandboxReviewCard extends StatelessWidget {
  const _SandboxReviewCard({
    required this.review,
    required this.onApprove,
    required this.onDeny,
  });

  final PendingCommandReview review;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: Key('sandbox_review_card_${review.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.security_update_warning_outlined,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sandbox Escape Review Required',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.error,
                    ),
                  ),
                  if (review.bypassSandbox) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'BypassSandbox: true',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'Menlo',
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    key: Key('deny_command_${review.id}'),
                    onPressed: onDeny,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    ),
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Deny'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: Key('approve_command_${review.id}'),
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Approve & Run'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.reason,
            key: Key('review_reason_${review.id}'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (review.toolSummary != null) ...[
            const SizedBox(height: 4),
            Text(
              'Summary: ${review.toolSummary}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  review.commandLine,
                  key: Key('review_command_line_${review.id}'),
                  style: const TextStyle(
                    fontFamily: 'Menlo',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Project workspace: ${review.workingDirectory}',
                  key: Key('review_working_dir_${review.id}'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'Menlo',
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

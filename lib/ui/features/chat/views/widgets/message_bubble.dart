import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../../domain/models/chat_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Renders a single chat message bubble with full GitHub-Flavored Markdown
/// support and a one-click Copy Markdown action.
class MessageBubble extends StatefulWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _copied = false;

  Future<void> _copyMarkdown() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Markdown copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          width: 280,
        ),
      );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = widget.message.isUser;

    final bubbleColor = isUser
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerLow;
    final borderColor = isUser
        ? colorScheme.primary.withValues(alpha: 0.25)
        : colorScheme.outlineVariant.withValues(alpha: 0.65);
    final headerTextColor = isUser
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
        : colorScheme.onSurfaceVariant;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          key: Key('message_bubble_${widget.message.id}'),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isUser ? 14 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 14),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUser
                            ? Icons.person_outline
                            : Icons.auto_awesome_outlined,
                        size: 15,
                        color: headerTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUser ? 'You' : 'Assistant',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: headerTextColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    key: Key('copy_markdown_${widget.message.id}'),
                    onPressed: _copyMarkdown,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: headerTextColor,
                    ),
                    icon: Icon(
                      _copied ? Icons.check : Icons.content_copy_outlined,
                      size: 14,
                    ),
                    label: Text(
                      _copied ? 'Copied' : 'Copy Markdown',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: headerTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              MarkdownBody(
                data: widget.message.content,
                selectable: true,
                extensionSet: md.ExtensionSet.gitHubFlavored,
                styleSheet: AppTheme.markdownStyleSheet(
                  context,
                  isUserBubble: isUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

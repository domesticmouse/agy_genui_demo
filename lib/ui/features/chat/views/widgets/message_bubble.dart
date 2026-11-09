import 'package:a2ui_agent/a2ui_agent.dart';
import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../../data/repositories/chat_repository.dart';
import '../../../../../domain/models/chat_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Renders a single chat message bubble with full GitHub-Flavored Markdown
/// support, inline streaming A2UI v1.0 [A2uiSurface] widgets from `<a2ui-json>`
/// blocks, and a one-click Copy Markdown action.
class MessageBubble extends StatefulWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _copied = false;

  MessageProcessor<ComponentImplementation>? _localRenderer;
  StreamedAnswer<ComponentImplementation>? _localAnswer;
  String _localFedContent = '';

  @override
  void initState() {
    super.initState();
    _syncLocalFallbackParser();
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.id != oldWidget.message.id ||
        (widget.message.hasParsedParts && !oldWidget.message.hasParsedParts)) {
      _disposeLocalFallbackParser();
    }
    _syncLocalFallbackParser();
  }

  @override
  void dispose() {
    _disposeLocalFallbackParser();
    super.dispose();
  }

  bool get _needsLocalFallbackParser =>
      !widget.message.hasParsedParts &&
      widget.message.content.contains('<a2ui-json');

  void _syncLocalFallbackParser() {
    if (!_needsLocalFallbackParser) {
      _disposeLocalFallbackParser();
      return;
    }

    final targetContent = widget.message.content;
    if (_localRenderer == null ||
        _localAnswer == null ||
        !targetContent.startsWith(_localFedContent)) {
      _disposeLocalFallbackParser();
      final renderer = MessageProcessor<ComponentImplementation>(
        catalogs: [ChatRepository.defaultA2uiCatalog],
        defaultVersion: A2uiProtocolVersion.v1_0,
        validationConfig: ValidationConfig.relaxed,
      );
      final processor = A2uiRequestProcessor(
        activeCatalogs: [ChatRepository.defaultA2uiCatalog],
        formatFactory: ChatRepository.defaultA2uiFormatFactory,
      );
      final answer = StreamedAnswer<ComponentImplementation>(
        processor,
        renderer: renderer,
      );
      answer.feed(targetContent);
      _localRenderer = renderer;
      _localAnswer = answer;
      _localFedContent = targetContent;
      return;
    }

    if (targetContent.length > _localFedContent.length) {
      final delta = targetContent.substring(_localFedContent.length);
      _localAnswer!.feed(delta);
      _localFedContent = targetContent;
    }
  }

  void _disposeLocalFallbackParser() {
    _localAnswer = null;
    _localFedContent = '';
    _localRenderer?.dispose();
    _localRenderer = null;
  }

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

  List<AnswerPart<ComponentImplementation>>? _resolveParts() {
    if (widget.message.hasParsedParts) {
      return widget.message.parts;
    }
    if (_localAnswer != null) {
      return _localAnswer!.parts;
    }
    return null;
  }

  Widget _buildMessageBody(BuildContext context, {required bool isUser}) {
    final parts = _resolveParts();
    if (parts == null) {
      return MarkdownBody(
        data: widget.message.content,
        selectable: true,
        extensionSet: md.ExtensionSet.gitHubFlavored,
        styleSheet: AppTheme.markdownStyleSheet(
          context,
          isUserBubble: isUser,
        ),
      );
    }

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      switch (part) {
        case AnswerTextPart<ComponentImplementation>(:final String text):
          if (text.trim().isEmpty) continue;
          if (children.isNotEmpty) {
            children.add(const SizedBox(height: 8));
          }
          children.add(
            MarkdownBody(
              data: text,
              selectable: true,
              extensionSet: md.ExtensionSet.gitHubFlavored,
              styleSheet: AppTheme.markdownStyleSheet(
                context,
                isUserBubble: isUser,
              ),
            ),
          );
        case AnswerSurfacePart<ComponentImplementation>(
          :final SurfaceModel<ComponentImplementation> surface,
        ):
          if (children.isNotEmpty) {
            children.add(const SizedBox(height: 8));
          }
          children.add(
            _InlineA2uiSurfaceCard(
              key: ValueKey('a2ui_surface_card_${surface.id}'),
              surface: surface,
              isUserBubble: isUser,
            ),
          );
        case AnswerErrorPart<ComponentImplementation>(:final A2uiError error):
          if (children.isNotEmpty) {
            children.add(const SizedBox(height: 8));
          }
          children.add(
            _InlineA2uiErrorBanner(
              key: ValueKey('a2ui_error_${widget.message.id}_$i'),
              error: error,
            ),
          );
      }
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    if (children.length == 1) {
      return children.single;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
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
              _buildMessageBody(context, isUser: isUser),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineA2uiSurfaceCard extends StatelessWidget {
  const _InlineA2uiSurfaceCard({
    super.key,
    required this.surface,
    required this.isUserBubble,
  });

  final SurfaceModel<ComponentImplementation> surface;
  final bool isUserBubble;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: A2uiMarkdown(
        builder: (context, markdown, style) => MarkdownBody(
          data: markdown,
          selectable: false,
          fitContent: true,
          extensionSet: md.ExtensionSet.gitHubFlavored,
          styleSheet: AppTheme.markdownStyleSheet(
            context,
            isUserBubble: isUserBubble,
          ).copyWith(p: style),
        ),
        child: A2uiSurface(
          key: ObjectKey(surface),
          surface: surface,
        ),
      ),
    );
  }
}

class _InlineA2uiErrorBanner extends StatelessWidget {
  const _InlineA2uiErrorBanner({super.key, required this.error});

  final A2uiError error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 16, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              'A2UI ${error.code}: ${error.message}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Menlo',
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

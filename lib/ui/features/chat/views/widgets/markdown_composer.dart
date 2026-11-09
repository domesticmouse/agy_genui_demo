import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/theme/app_theme.dart';

/// Desktop Markdown composer with a formatting toolbar, live Markdown preview
/// toggle, IME composition guard, keyboard shortcuts (`Enter` / `Numpad Enter`
/// to send, `Shift + Enter` for newline), and automatic focus restoration.
class MarkdownComposer extends StatefulWidget {
  const MarkdownComposer({
    super.key,
    required this.isPreviewVisible,
    required this.onTogglePreview,
    required this.onSend,
    this.activeThreadId = '',
    this.initialDraft = '',
    this.onDraftChanged,
  });

  final bool isPreviewVisible;
  final VoidCallback onTogglePreview;
  final ValueChanged<String> onSend;
  final String activeThreadId;
  final String initialDraft;
  final ValueChanged<String>? onDraftChanged;

  @override
  State<MarkdownComposer> createState() => _MarkdownComposerState();
}

class _MarkdownComposerState extends State<MarkdownComposer> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialDraft,
  );
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKeyEvent);
  bool _isSyncingThreadDraft = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MarkdownComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeThreadId != oldWidget.activeThreadId) {
      _isSyncingThreadDraft = true;
      final nextDraft = widget.initialDraft;
      _controller.value = TextEditingValue(
        text: nextDraft,
        selection: TextSelection.collapsed(offset: nextDraft.length),
      );
      _isSyncingThreadDraft = false;
    }
  }

  void _handleControllerChanged() {
    if (_isSyncingThreadDraft) return;
    widget.onDraftChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Checks whether the text field currently has an active IME composition region.
  bool get _isImeComposing {
    final composing = _controller.value.composing;
    return composing.isValid && !composing.isCollapsed;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final isEnter =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) {
      return KeyEventResult.ignored;
    }

    // Guard against intercepting Enter while IME composition is active.
    if (_isImeComposing) {
      return KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isShiftPressed) {
      _insertNewlineAtCursor();
      return KeyEventResult.handled;
    }

    _submitMessage();
    return KeyEventResult.handled;
  }

  void _insertNewlineAtCursor() {
    final value = _controller.value;
    final selection = value.selection;
    final text = value.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final newText = text.replaceRange(start, end, '\n');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
  }

  void _submitMessage() {
    final rawText = _controller.text;
    if (rawText.trim().isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    widget.onSend(rawText);
    _controller.clear();
    _focusNode.requestFocus();
  }

  /// Wraps the current selection with [prefix] and [suffix], or inserts
  /// [placeholder] wrapped in those markers if no text is selected.
  void _applyInlineWrap({
    required String prefix,
    required String suffix,
    required String placeholder,
  }) {
    final value = _controller.value;
    final text = value.text;
    final selection = value.selection;

    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final hasSelection = start != end;
    final innerText = hasSelection ? text.substring(start, end) : placeholder;
    final replacement = '$prefix$innerText$suffix';

    final newText = text.replaceRange(start, end, replacement);
    final newSelection = hasSelection
        ? TextSelection.collapsed(offset: start + replacement.length)
        : TextSelection(
            baseOffset: start + prefix.length,
            extentOffset: start + prefix.length + placeholder.length,
          );

    _controller.value = TextEditingValue(
      text: newText,
      selection: newSelection,
    );
    _focusNode.requestFocus();
  }

  /// Prefixes the current line or selection with [linePrefix].
  void _applyLinePrefix({
    required String linePrefix,
    required String placeholder,
  }) {
    final value = _controller.value;
    final text = value.text;
    final selection = value.selection;

    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final hasSelection = start != end;
    final innerText = hasSelection ? text.substring(start, end) : placeholder;
    final needsLeadingNewline = start > 0 && text[start - 1] != '\n';
    final prefix = '${needsLeadingNewline ? '\n' : ''}$linePrefix';
    final replacement = '$prefix$innerText';

    final newText = text.replaceRange(start, end, replacement);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Formatting Toolbar + Live Preview Toggle
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  _FormatButton(
                    buttonKey: const Key('format_bold_button'),
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    onPressed: () => _applyInlineWrap(
                      prefix: '**',
                      suffix: '**',
                      placeholder: 'bold',
                    ),
                  ),
                  _FormatButton(
                    buttonKey: const Key('format_italic_button'),
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    onPressed: () => _applyInlineWrap(
                      prefix: '*',
                      suffix: '*',
                      placeholder: 'italic',
                    ),
                  ),
                  _FormatButton(
                    buttonKey: const Key('format_inline_code_button'),
                    icon: Icons.code,
                    tooltip: 'Inline Code',
                    onPressed: () => _applyInlineWrap(
                      prefix: '`',
                      suffix: '`',
                      placeholder: 'code',
                    ),
                  ),
                  _FormatButton(
                    buttonKey: const Key('format_code_block_button'),
                    icon: Icons.terminal,
                    tooltip: 'Code Block',
                    onPressed: () => _applyInlineWrap(
                      prefix: '```\n',
                      suffix: '\n```',
                      placeholder: 'code',
                    ),
                  ),
                  _FormatButton(
                    buttonKey: const Key('format_list_button'),
                    icon: Icons.format_list_bulleted,
                    tooltip: 'List',
                    onPressed: () => _applyLinePrefix(
                      linePrefix: '- ',
                      placeholder: 'list item',
                    ),
                  ),
                  _FormatButton(
                    buttonKey: const Key('format_blockquote_button'),
                    icon: Icons.format_quote,
                    tooltip: 'Blockquote',
                    onPressed: () => _applyLinePrefix(
                      linePrefix: '> ',
                      placeholder: 'quote',
                    ),
                  ),
                ],
              ),
              FilterChip(
                key: const Key('toggle_preview_button'),
                label: const Text('Live Preview'),
                avatar: Icon(
                  widget.isPreviewVisible
                      ? Icons.visibility
                      : Icons.visibility_outlined,
                  size: 16,
                ),
                selected: widget.isPreviewVisible,
                onSelected: (_) {
                  widget.onTogglePreview();
                  _focusNode.requestFocus();
                },
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Optional Live Markdown Preview Pane
          if (widget.isPreviewVisible)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final draft = value.text.trim();
                return Container(
                  key: const Key('live_markdown_preview'),
                  constraints: const BoxConstraints(maxHeight: 160),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'LIVE MARKDOWN PREVIEW',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (draft.isEmpty)
                          Text(
                            'Start typing Markdown below to preview...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          MarkdownBody(
                            data: draft,
                            extensionSet: md.ExtensionSet.gitHubFlavored,
                            styleSheet: AppTheme.markdownStyleSheet(context),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          // Input Row + Send Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('composer_text_field'),
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Write Markdown... (Enter to send, Shift + Enter for newline)',
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty;
                  return FilledButton.icon(
                    key: const Key('send_message_button'),
                    onPressed: canSend ? _submitMessage : null,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.buttonKey,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }
}

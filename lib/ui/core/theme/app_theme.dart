import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Material 3 Light and Dark theme definitions and Markdown style sheets
/// tailored for a macOS desktop chat experience.
class AppTheme {
  const AppTheme._();

  static const Color _seedColor = Color(0xFF3F51B5);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Builds a rich [MarkdownStyleSheet] for message bubbles and live preview.
  static MarkdownStyleSheet markdownStyleSheet(
    BuildContext context, {
    bool isUserBubble = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = isUserBubble
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final codeBackground = isUserBubble
        ? colorScheme.surface.withValues(alpha: 0.65)
        : colorScheme.surfaceContainerHighest;
    final codeForeground = colorScheme.onSurface;

    final baseBody =
        theme.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.48) ??
        TextStyle(color: textColor, fontSize: 14, height: 1.48);

    const monoFontFamily = 'Menlo';

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: baseBody,
      h1: theme.textTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        height: 1.32,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      h4: theme.textTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      strong: baseBody.copyWith(fontWeight: FontWeight.w700),
      em: baseBody.copyWith(fontStyle: FontStyle.italic),
      del: baseBody.copyWith(
        decoration: TextDecoration.lineThrough,
        color: textColor.withValues(alpha: 0.72),
      ),
      code: baseBody.copyWith(
        fontFamily: monoFontFamily,
        fontSize: 12.5,
        color: codeForeground,
        backgroundColor: codeBackground,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      blockquote: baseBody.copyWith(
        color: textColor.withValues(alpha: 0.85),
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      blockquoteDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
      ),
      listBullet: baseBody.copyWith(fontWeight: FontWeight.w600),
      tableHead: baseBody.copyWith(fontWeight: FontWeight.w700),
      tableBody: baseBody,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableBorder: TableBorder.all(
        color: colorScheme.outlineVariant,
        width: 1,
        borderRadius: BorderRadius.circular(6),
      ),
      tableCellsDecoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }
}

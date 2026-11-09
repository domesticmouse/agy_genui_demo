import 'package:flutter/material.dart';

import 'ui/core/theme/app_theme.dart';
import 'ui/features/chat/view_models/chat_view_model.dart';
import 'ui/features/chat/views/chat_screen.dart';

void main() {
  runApp(const MarkdownChatApp());
}

/// Root widget for the macOS desktop Markdown chat application.
class MarkdownChatApp extends StatefulWidget {
  const MarkdownChatApp({super.key, this.viewModel});

  final ChatViewModel? viewModel;

  @override
  State<MarkdownChatApp> createState() => _MarkdownChatAppState();
}

class _MarkdownChatAppState extends State<MarkdownChatApp> {
  late final ChatViewModel _viewModel = widget.viewModel ?? ChatViewModel();

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'macOS Markdown Chat',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _viewModel.themeMode,
          home: ChatScreen(viewModel: _viewModel),
        );
      },
    );
  }
}

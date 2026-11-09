import 'dart:async';

import 'package:agy_genui_demo/data/repositories/chat_repository.dart';
import 'package:agy_genui_demo/main.dart';
import 'package:agy_genui_demo/ui/features/chat/view_models/chat_view_model.dart';
import 'package:antigravity/antigravity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAntigravitySession implements AntigravityAgentSession {
  _FakeAntigravitySession({
    required this.config,
    required this.threadId,
    required this.threadTitle,
    required this.replyBuilder,
  });

  final LocalAgentConfig config;
  final String threadId;
  final String threadTitle;
  final Stream<String> Function(String prompt) replyBuilder;

  bool started = false;
  bool stopped = false;
  final List<String> prompts = [];

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Stream<String> sendPrompt(String prompt) async* {
    started = true;
    prompts.add(prompt);
    yield* replyBuilder(prompt);
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }
}

void main() {
  void setDesktopSurfaceSize(
    WidgetTester tester, [
    Size size = const Size(1200, 820),
  ]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  ChatRepository createFakeRepository({
    Map<String, _FakeAntigravitySession>? recordedSessions,
    Stream<String> Function(
      String prompt,
      String threadId,
      String threadTitle,
    )? customReplyStream,
  }) {
    late final ChatRepository repository;
    repository = ChatRepository(
      apiKey: 'test-gemini-api-key',
      model: 'gemini-3.8-flash',
      sessionBuilder: (
        config, {
        required threadId,
        required threadTitle,
      }) {
        final session = _FakeAntigravitySession(
          config: config,
          threadId: threadId,
          threadTitle: threadTitle,
          replyBuilder: (prompt) {
            if (customReplyStream != null) {
              return customReplyStream(prompt, threadId, threadTitle);
            }
            return Stream<String>.value(
              repository.buildAssistantReply(prompt, threadTitle: threadTitle),
            );
          },
        );
        recordedSessions?[threadId] = session;
        return session;
      },
    );
    return repository;
  }

  testWidgets(
    'Renders starter threads with rich Markdown and supports Copy Markdown button',
    (WidgetTester tester) async {
      setDesktopSurfaceSize(tester);

      String? copiedText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              final args = call.arguments as Map<dynamic, dynamic>;
              copiedText = args['text'] as String?;
            }
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      final viewModel = ChatViewModel(repository: createFakeRepository());
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(MarkdownChatApp(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Verify starter threads in sidebar and active thread title
      expect(find.byKey(const Key('thread_sidebar')), findsOneWidget);
      expect(find.text('Markdown Showcase'), findsWidgets);
      expect(find.text('macOS Desktop Architecture'), findsOneWidget);

      // Verify MarkdownBody widgets render rich Markdown elements (headings, tables, code blocks)
      expect(find.byType(MarkdownBody), findsAtLeastNWidgets(2));
      expect(find.text('Welcome to macOS Markdown Chat'), findsOneWidget);
      expect(find.text('GitHub-Style Tables'), findsOneWidget);
      expect(find.byType(Table), findsOneWidget);

      // Verify one-click Copy Markdown button on every message bubble
      final copyButton = find.byKey(const Key('copy_markdown_msg-showcase-1'));
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pump();

      expect(copiedText, contains('**Markdown**'));
      expect(find.text('Markdown copied to clipboard'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets(
    'Collapsible sidebar, automatic thread titling, and per-thread typing state isolation',
    (WidgetTester tester) async {
      setDesktopSurfaceSize(tester);

      final sessions = <String, _FakeAntigravitySession>{};
      final viewModel = ChatViewModel(
        repository: createFakeRepository(recordedSessions: sessions),
        responseDelay: const Duration(milliseconds: 500),
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(MarkdownChatApp(viewModel: viewModel));
      await tester.pumpAndSettle();

      // 1. Toggle collapsible sidebar off and back on
      expect(find.byKey(const Key('thread_sidebar')), findsOneWidget);
      await tester.tap(find.byKey(const Key('toggle_sidebar_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thread_sidebar')), findsNothing);

      await tester.tap(find.byKey(const Key('toggle_sidebar_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thread_sidebar')), findsOneWidget);

      // 2. Create a new thread and verify initial 'New Thread' title
      await tester.tap(find.byKey(const Key('toolbar_new_thread_button')));
      await tester.pumpAndSettle();
      final newThreadId = viewModel.activeThreadId;
      expect(find.text('New Thread'), findsWidgets);

      // 3. Send first message with Markdown syntax and verify automatic thread titling
      await tester.enterText(
        find.byKey(const Key('composer_text_field')),
        '# **macOS Split View Guide**\nDetails below.',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pump();

      expect(viewModel.activeThread?.title, 'macOS Split View Guide');
      expect(viewModel.activeThread?.isTyping, isTrue);
      expect(
        find.byKey(const Key('active_thread_typing_indicator')),
        findsOneWidget,
      );
      expect(find.byKey(Key('sidebar_typing_$newThreadId')), findsOneWidget);

      // 4. Switch to starter thread while newThread is still typing:
      // verify per-thread typing state isolation
      await tester.tap(find.byKey(const Key('thread_tile_thread-showcase')));
      await tester.pump();

      expect(viewModel.activeThreadId, 'thread-showcase');
      expect(viewModel.activeThread?.isTyping, isFalse);
      expect(
        find.byKey(const Key('active_thread_typing_indicator')),
        findsNothing,
      );
      // Background thread still shows its typing badge in the sidebar
      expect(find.byKey(Key('sidebar_typing_$newThreadId')), findsOneWidget);

      // Advance clock so Antigravity agent reply finishes in the background thread
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(Key('sidebar_typing_$newThreadId')), findsNothing);
      expect(sessions[newThreadId]?.started, isTrue);
      expect(
        sessions[newThreadId]?.prompts,
        contains('# **macOS Split View Guide**\nDetails below.'),
      );
    },
  );

  testWidgets(
    'Antigravity backend streams Markdown chunks, configures LocalAgentConfig, and handles errors & lifecycle',
    (WidgetTester tester) async {
      setDesktopSurfaceSize(tester);

      final sessions = <String, _FakeAntigravitySession>{};
      final streamControllers = <String, StreamController<String>>{};

      final repository = createFakeRepository(
        recordedSessions: sessions,
        customReplyStream: (prompt, threadId, threadTitle) {
          final controller = StreamController<String>();
          streamControllers[threadId] = controller;
          return controller.stream;
        },
      );

      final viewModel = ChatViewModel(repository: repository);
      addTearDown(() {
        for (final controller in streamControllers.values) {
          if (!controller.isClosed) {
            controller.close();
          }
        }
        viewModel.dispose();
      });

      await tester.pumpWidget(MarkdownChatApp(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Create a new thread and send a prompt
      await tester.tap(find.byKey(const Key('toolbar_new_thread_button')));
      await tester.pumpAndSettle();
      final streamingThreadId = viewModel.activeThreadId;

      await tester.enterText(
        find.byKey(const Key('composer_text_field')),
        'Stream an **Antigravity** response',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pump();

      // Verify LocalAgentConfig was built with CustomSystemInstructions and model
      final session = sessions[streamingThreadId]!;
      expect(session.config, isA<LocalAgentConfig>());
      expect(session.config.model, 'gemini-3.8-flash');
      expect(session.config.apiKey, 'test-gemini-api-key');
      expect(session.config.systemInstructions, isA<CustomSystemInstructions>());
      final instructions =
          session.config.systemInstructions as CustomSystemInstructions;
      expect(instructions.title, 'MarkdownChatAssistant');
      expect(instructions.text, contains('Stream an Antigravity response'));

      // Stream first Markdown chunk while typing indicator remains active
      final controller = streamControllers[streamingThreadId]!;
      controller.add('### Live Streamed Heading\n\n');
      await tester.pump();

      expect(find.text('Live Streamed Heading'), findsOneWidget);
      expect(viewModel.activeThread?.isTyping, isTrue);
      expect(
        find.byKey(const Key('active_thread_typing_indicator')),
        findsOneWidget,
      );

      // Stream second Markdown chunk and close stream
      controller.add('Token chunk from `package:antigravity`.');
      await controller.close();
      await tester.pumpAndSettle();

      expect(
        viewModel.activeThread?.messages.last.content,
        '### Live Streamed Heading\n\nToken chunk from `package:antigravity`.',
      );
      expect(viewModel.activeThread?.isTyping, isFalse);
      expect(
        find.byKey(const Key('active_thread_typing_indicator')),
        findsNothing,
      );

      // Deleting the thread stops its Antigravity agent session
      expect(session.stopped, isFalse);
      await tester.tap(find.byKey(Key('delete_thread_$streamingThreadId')));
      await tester.pumpAndSettle();
      expect(session.stopped, isTrue);

      // Verify Antigravity error handling renders a Markdown error message
      await tester.tap(find.byKey(const Key('toolbar_new_thread_button')));
      await tester.pumpAndSettle();
      final errorThreadId = viewModel.activeThreadId;

      await tester.enterText(
        find.byKey(const Key('composer_text_field')),
        'Trigger validation error',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pump();

      streamControllers[errorThreadId]!.addError(
        AntigravityValidationException('GEMINI_API_KEY is missing'),
      );
      await streamControllers[errorThreadId]!.close();
      await tester.pumpAndSettle();

      expect(viewModel.activeThread?.isTyping, isFalse);
      expect(find.text('Antigravity Backend Error'), findsOneWidget);
      expect(
        viewModel.activeThread?.messages.last.content,
        contains('GEMINI_API_KEY is missing'),
      );
    },
  );

  testWidgets(
    'Formatting toolbar, Live Preview toggle, keyboard shortcuts, IME guard, and focus restoration',
    (WidgetTester tester) async {
      setDesktopSurfaceSize(tester);

      final viewModel = ChatViewModel(
        repository: createFakeRepository(),
        responseDelay: const Duration(milliseconds: 100),
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(MarkdownChatApp(viewModel: viewModel));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byKey(const Key('composer_text_field'));
      TextField textField() => tester.widget<TextField>(textFieldFinder);

      // 1. Formatting toolbar actions
      await tester.tap(find.byKey(const Key('format_bold_button')));
      await tester.pump();
      expect(textField().controller!.text, '**bold**');

      textField().controller!.clear();
      await tester.tap(find.byKey(const Key('format_italic_button')));
      await tester.pump();
      expect(textField().controller!.text, '*italic*');

      textField().controller!.clear();
      await tester.tap(find.byKey(const Key('format_inline_code_button')));
      await tester.pump();
      expect(textField().controller!.text, '`code`');

      textField().controller!.clear();
      await tester.tap(find.byKey(const Key('format_code_block_button')));
      await tester.pump();
      expect(textField().controller!.text, '```\ncode\n```');

      textField().controller!.clear();
      await tester.tap(find.byKey(const Key('format_list_button')));
      await tester.pump();
      expect(textField().controller!.text, '- list item');

      textField().controller!.clear();
      await tester.tap(find.byKey(const Key('format_blockquote_button')));
      await tester.pump();
      expect(textField().controller!.text, '> quote');

      // 2. Live Markdown Preview toggle
      expect(find.byKey(const Key('live_markdown_preview')), findsNothing);
      await tester.tap(find.byKey(const Key('toggle_preview_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('live_markdown_preview')), findsOneWidget);

      // 3. Shift + Enter inserts a newline without sending
      textField().controller!.value = const TextEditingValue(
        text: 'Line 1',
        selection: TextSelection.collapsed(offset: 6),
      );
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(textField().controller!.text, 'Line 1\n');

      // 4. IME composition guard: Enter does NOT send when composing region is active
      textField().controller!.value = const TextEditingValue(
        text: 'nihao',
        selection: TextSelection.collapsed(offset: 5),
        composing: TextRange(start: 0, end: 5),
      );
      await tester.pump();

      final countBeforeImeEnter = viewModel.activeThread!.messages.length;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(viewModel.activeThread!.messages.length, countBeforeImeEnter);
      expect(textField().controller!.text, 'nihao');

      // 5. Clear IME composing and press Numpad Enter to send; verify focus is restored
      textField().controller!.value = const TextEditingValue(
        text: 'Sent with Numpad Enter',
        selection: TextSelection.collapsed(offset: 22),
      );
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.numpadEnter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.numpadEnter);
      await tester.pump();

      expect(viewModel.activeThread!.messages.length, countBeforeImeEnter + 1);
      expect(textField().controller!.text, isEmpty);
      expect(textField().focusNode!.hasFocus, isTrue);

      await tester.pump(const Duration(milliseconds: 200));
    },
  );

  testWidgets(
    'Responsive top toolbar and Light/Dark Material 3 theme switching',
    (WidgetTester tester) async {
      setDesktopSurfaceSize(tester, const Size(440, 760));

      final viewModel = ChatViewModel(repository: createFakeRepository());
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(MarkdownChatApp(viewModel: viewModel));
      await tester.pumpAndSettle();

      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app().themeMode, ThemeMode.light);

      // Switch to Dark theme
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();
      expect(app().themeMode, ThemeMode.dark);

      // Switch back to Light theme
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();
      expect(app().themeMode, ThemeMode.light);
    },
  );
}

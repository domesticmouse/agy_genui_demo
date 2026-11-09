import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../../data/repositories/chat_repository.dart';
import '../../../../../domain/models/chat_models.dart';

/// Result returned when the user saves the [ProjectDialog].
class ProjectDialogResult {
  const ProjectDialogResult({
    required this.name,
    required this.workingDirectory,
  });

  final String name;
  final String workingDirectory;
}

/// Dialog for creating a new [ChatProject] or editing an existing project's
/// working directory for the Antigravity local harness.
class ProjectDialog extends StatefulWidget {
  const ProjectDialog({super.key, this.existingProject});

  /// When non-null, edits the existing project instead of creating a new one.
  final ChatProject? existingProject;

  static Future<ProjectDialogResult?> show(
    BuildContext context, {
    ChatProject? existingProject,
  }) {
    return showDialog<ProjectDialogResult>(
      context: context,
      builder: (context) => ProjectDialog(existingProject: existingProject),
    );
  }

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _directoryController;
  String? _errorText;

  bool get _isEditing => widget.existingProject != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingProject;
    final initialDir =
        existing?.workingDirectory ??
        ChatRepository.resolveDefaultWorkingDirectory();
    _nameController = TextEditingController(text: existing?.name ?? '');
    _directoryController = TextEditingController(text: initialDir);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  void _applyPresetDirectory(String path) {
    final normalized = ChatRepository.normalizeProjectDirectory(path);
    setState(() {
      _directoryController.text = normalized;
      if (_nameController.text.trim().isEmpty) {
        final base = p.basename(normalized);
        if (base.isNotEmpty && base != '/') {
          _nameController.text = base;
        }
      }
      _errorText = null;
    });
  }

  void _submit() {
    final rawDir = _directoryController.text.trim();
    if (rawDir.isEmpty) {
      setState(() {
        _errorText =
            'Please provide a working directory path for the Antigravity harness.';
      });
      return;
    }

    final normalizedDir = ChatRepository.normalizeProjectDirectory(rawDir);
    final rawName = _nameController.text.trim();
    final fallbackName = p.basename(normalizedDir).isNotEmpty
        ? p.basename(normalizedDir)
        : 'Workspace';

    Navigator.of(context).pop(
      ProjectDialogResult(
        name: rawName.isNotEmpty ? rawName : fallbackName,
        workingDirectory: normalizedDir,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultWorkspace = ChatRepository.resolveDefaultWorkingDirectory();
    final homeDir = Platform.environment['HOME'] ?? defaultWorkspace;
    final tempDir = p.normalize(Directory.systemTemp.absolute.path);

    return AlertDialog(
      key: const Key('project_dialog'),
      title: Row(
        children: [
          Icon(
            _isEditing
                ? Icons.folder_open_outlined
                : Icons.create_new_folder_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text(_isEditing ? 'Edit Project Workspace' : 'New Project'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 440, maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set the working directory passed to the Antigravity local harness (`workspaces`). '
              'File tools and sandboxed commands in this project will be confined to this directory.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('project_name_field'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g. agy_genui_demo',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('project_directory_field'),
              controller: _directoryController,
              style: const TextStyle(fontFamily: 'Menlo', fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Working Directory (Antigravity Harness Workspace)',
                hintText: '/Users/you/projects/my_app',
                errorText: _errorText,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Quick presets:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                ActionChip(
                  key: const Key('preset_cwd_chip'),
                  label: const Text('Current Directory'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _applyPresetDirectory(defaultWorkspace),
                ),
                ActionChip(
                  key: const Key('preset_home_chip'),
                  label: const Text('Home (~)'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _applyPresetDirectory(homeDir),
                ),
                ActionChip(
                  key: const Key('preset_temp_chip'),
                  label: const Text('System Temp'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _applyPresetDirectory(tempDir),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('project_dialog_cancel_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('project_dialog_save_button'),
          onPressed: _submit,
          icon: const Icon(Icons.check, size: 18),
          label: Text(_isEditing ? 'Save Workspace' : 'Create Project'),
        ),
      ],
    );
  }
}

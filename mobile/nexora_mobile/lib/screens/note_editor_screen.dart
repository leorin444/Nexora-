import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import '../theme/nexora_theme.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? initialNote;

  const NoteEditorScreen({super.key, this.initialNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _notesService = NotesService();

  bool _isPinned = false;
  VisibilityLevel _visibility = VisibilityLevel.private;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null) {
      _titleController.text = widget.initialNote!.title;
      _contentController.text = widget.initialNote!.content;
      _isPinned = widget.initialNote!.isPinned;
      _visibility = widget.initialNote!.visibility;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);

    try {
      if (widget.initialNote != null) {
        // Create new or update
        await _notesService.createNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          isPinned: _isPinned,
          visibility: _visibility,
        );
      } else {
        await _notesService.createNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          isPinned: _isPinned,
          visibility: _visibility,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: NexoraColors.vaultAccentLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: Text(widget.initialNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? tokens.brandPrimary : tokens.textSecondary,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _isPinned = !_isPinned);
            },
            tooltip: _isPinned ? 'Unpin note' : 'Pin note',
          ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            color: tokens.brandPrimary,
            onPressed: _isSaving ? null : _saveNote,
            tooltip: 'Save note',
          ),
        ],
      ),
      body: SafeArea(
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Note Title
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Note Title',
                          labelText: 'Title',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Visibility Segment
                      Text(
                        'Audience & Privacy',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: tokens.strokeSubtle,
                          borderRadius: NexoraRadius.borderSm,
                        ),
                        child: Row(
                          children: [
                            _buildVisOption(
                              '🔒 Private',
                              VisibilityLevel.private,
                              tokens,
                            ),
                            _buildVisOption(
                              '👀 Partner',
                              VisibilityLevel.partnerVisible,
                              tokens,
                            ),
                            _buildVisOption(
                              '💖 Shared Duo',
                              VisibilityLevel.shared,
                              tokens,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      TextFormField(
                        controller: _contentController,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: tokens.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Write your thoughts, memos, or shared ideas...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 15,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildVisOption(
    String label,
    VisibilityLevel level,
    NexoraThemeExtension tokens,
  ) {
    final isSelected = _visibility == level;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _visibility = level);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? tokens.cardSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? tokens.brandPrimary : tokens.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

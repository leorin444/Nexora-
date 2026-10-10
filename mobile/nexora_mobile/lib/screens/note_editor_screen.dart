import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

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

    setState(() => _isSaving = true);
    try {
      await _notesService.createNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isPinned: _isPinned,
        visibility: _visibility,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            tooltip: _isPinned ? 'Unpin' : 'Pin',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveNote,
            tooltip: 'Save',
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<VisibilityLevel>(
                      value: _visibility,
                      decoration: const InputDecoration(
                        labelText: 'Visibility',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: VisibilityLevel.private,
                          child: Text('Private (Only You)'),
                        ),
                        DropdownMenuItem(
                          value: VisibilityLevel.partnerVisible,
                          child: Text('Partner Visible'),
                        ),
                        DropdownMenuItem(
                          value: VisibilityLevel.shared,
                          child: Text('Shared (Both in Couple)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _visibility = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

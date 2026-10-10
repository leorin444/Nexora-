import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NotesService _notesService = NotesService();
  List<NoteModel>? _notes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final notes = await _notesService.getNotes();
      setState(() { _notes = notes; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await _notesService.deleteNote(id);
      await _loadNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotes),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
          if (created == true) await _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadNotes, child: const Text('Retry')),
                  ],
                ))
              : _notes!.isEmpty
                  ? const Center(child: Text('No notes yet. Tap + to create one.'))
                  : RefreshIndicator(
                      onRefresh: _loadNotes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _notes!.length,
                        itemBuilder: (context, index) {
                          final note = _notes![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: note.isPinned
                                  ? const Icon(Icons.push_pin, color: Colors.deepPurple)
                                  : const Icon(Icons.note),
                              title: Text(note.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: note.content.isNotEmpty
                                  ? Text(note.content,
                                      maxLines: 2, overflow: TextOverflow.ellipsis)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _visibilityBadge(note.visibility),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteNote(note.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _visibilityBadge(VisibilityLevel v) {
    final (label, color) = switch (v) {
      VisibilityLevel.private => ('Private', Colors.grey),
      VisibilityLevel.shared => ('Shared', Colors.blue),
      VisibilityLevel.partnerVisible => ('Partner', Colors.pink),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color, width: 0.5),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/bento_card.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NotesService _notesService = NotesService();
  final TextEditingController _searchController = TextEditingController();

  List<NoteModel>? _notes;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  VisibilityLevel? _filterVisibility;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notes = await _notesService.getNotes();
      if (mounted) {
        setState(() {
          _notes = notes;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    HapticFeedback.lightImpact();
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
    final tokens = NexoraTheme.of(context);

    final filteredNotes = (_notes ?? []).where((n) {
      if (_filterVisibility != null && n.visibility != _filterVisibility) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadNotes),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tokens.brandPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        onPressed: () async {
          HapticFeedback.lightImpact();
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
          if (created == true) await _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: tokens.textPrimary),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search personal and partner notes...',
                prefixIcon: Icon(Icons.search_rounded, color: tokens.textSecondary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _buildTagChip('All Notes', null, tokens),
                const SizedBox(width: 8),
                _buildTagChip('🔒 Private', VisibilityLevel.private, tokens),
                const SizedBox(width: 8),
                _buildTagChip('💖 Shared Duo', VisibilityLevel.shared, tokens),
                const SizedBox(width: 8),
                _buildTagChip('👀 Partner Visible', VisibilityLevel.partnerVisible, tokens),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error', style: TextStyle(color: tokens.vaultAccent)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _loadNotes, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : filteredNotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.note_alt_outlined, size: 48, color: tokens.textSecondary.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No notes found.\nTap + to create your first thought!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadNotes,
                            color: tokens.brandPrimary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = filteredNotes[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: BentoCard(
                                    onTap: () async {
                                      final updated = await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => NoteEditorScreen(initialNote: note),
                                        ),
                                      );
                                      if (updated == true) await _loadNotes();
                                    },
                                    border: note.isPinned
                                        ? Border.all(color: tokens.brandPrimary.withOpacity(0.6), width: 1.4)
                                        : null,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (note.isPinned) ...[
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: tokens.brandPrimary.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.push_pin_rounded,
                                                  size: 14,
                                                  color: tokens.brandPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Expanded(
                                              child: Text(
                                                note.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: tokens.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            _visibilityBadge(note.visibility, tokens),
                                            IconButton(
                                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                              icon: Icon(Icons.delete_outline_rounded, size: 18, color: tokens.vaultAccent),
                                              onPressed: () => _deleteNote(note.id),
                                            ),
                                          ],
                                        ),
                                        if (note.content.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            note.content,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: tokens.textSecondary,
                                              height: 1.35,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text(
                                          note.updatedAtUtc.toLocal().toString().substring(0, 16),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: tokens.textSecondary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, VisibilityLevel? level, NexoraThemeExtension tokens) {
    final isSelected = _filterVisibility == level;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _filterVisibility = selected ? level : null);
      },
      selectedColor: tokens.brandPrimary.withOpacity(0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? tokens.brandPrimary : tokens.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? tokens.brandPrimary : tokens.strokeSubtle,
      ),
      backgroundColor: tokens.cardSurface,
    );
  }

  Widget _visibilityBadge(VisibilityLevel v, NexoraThemeExtension tokens) {
    final (label, color) = switch (v) {
      VisibilityLevel.private => ('Private', tokens.textSecondary),
      VisibilityLevel.shared => ('Shared', tokens.brandPrimary),
      VisibilityLevel.partnerVisible => ('Partner', tokens.coupleAccent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

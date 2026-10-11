import 'package:flutter/material.dart';
import '../models/search_models.dart';
import '../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _queryController = TextEditingController();

  UnifiedSearchResponseModel? _searchResponse;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch([String? term]) async {
    final query = term ?? _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _searchService.search(query);
      setState(() {
        _searchResponse = response;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _iconForType(int type) {
    switch (type) {
      case 0:
        return Icons.note_outlined;
      case 1:
        return Icons.alarm;
      case 2:
        return Icons.event;
      case 3:
        return Icons.shield_outlined;
      case 4:
        return Icons.newspaper;
      default:
        return Icons.search;
    }
  }

  String _labelForType(int type) {
    switch (type) {
      case 0:
        return 'Note';
      case 1:
        return 'Reminder';
      case 2:
        return 'Calendar';
      case 3:
        return 'Vault';
      case 4:
        return 'News';
      default:
        return 'Item';
    }
  }

  Color _colorForType(int type) {
    switch (type) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search & Intelligence'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Search notes, reminders, events, vault, news...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _handleSearch(),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (val) => _handleSearch(val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                    : _searchResponse == null
                        ? const Center(
                            child: Text(
                              'Type a search term to explore your personal &\nshared intelligence network 🔍',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _searchResponse!.results.isEmpty
                            ? Center(
                                child: Text('No results found for "${_searchResponse!.query}"'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _searchResponse!.results.length,
                                itemBuilder: (context, index) {
                                  final item = _searchResponse!.results[index];
                                  final typeColor = _colorForType(item.resultType);

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: typeColor.withOpacity(0.15),
                                        child: Icon(_iconForType(item.resultType), color: typeColor),
                                      ),
                                      title: Text(
                                        item.title,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: item.snippet != null && item.snippet!.isNotEmpty
                                          ? Text(
                                              item.snippet!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : null,
                                      trailing: Chip(
                                        label: Text(
                                          _labelForType(item.resultType),
                                          style: TextStyle(fontSize: 10, color: typeColor),
                                        ),
                                        backgroundColor: typeColor.withOpacity(0.08),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}

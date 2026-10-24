import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/search_models.dart';
import '../services/search_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/universal_search_tile.dart';
import 'notes_screen.dart';
import 'calendar_screen.dart';
import 'vault_screen.dart';
import 'news_screen.dart';

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

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _searchService.search(query);
      if (mounted) {
        setState(() {
          _searchResponse = response;
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

  void _navigateToTarget(SearchResultModel result) {
    HapticFeedback.lightImpact();
    switch (result.resultType) {
      case 0: // Note
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotesScreen()),
        );
        break;
      case 2: // Calendar Event
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
        break;
      case 3: // Vault
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VaultScreen()),
        );
        break;
      case 4: // News
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewsScreen()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('Universal Search & Index'),
      ),
      body: Column(
        children: [
          // Single Unified Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              controller: _queryController,
              style: TextStyle(color: tokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search Notes, Calendar, Vault, News...',
                prefixIcon: Icon(Icons.search_rounded, color: tokens.textSecondary, size: 22),
                suffixIcon: IconButton(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  icon: Icon(Icons.arrow_forward_rounded, color: tokens.brandPrimary),
                  onPressed: () => _handleSearch(),
                ),
              ),
              onSubmitted: (val) => _handleSearch(val),
            ),
          ),

          // Unified Results Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: TextStyle(color: tokens.vaultAccent)))
                    : _searchResponse == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.saved_search_rounded,
                                    size: 52, color: tokens.textSecondary.withOpacity(0.35)),
                                const SizedBox(height: 12),
                                Text(
                                  'Type a query to search across\npersonal notes, calendar, vault & news index 🔍',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: tokens.textSecondary,
                                    height: 1.4,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _searchResponse!.results.isEmpty
                            ? Center(
                                child: Text(
                                  'No results found for "${_searchResponse!.query}"',
                                  style: TextStyle(color: tokens.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _searchResponse!.results.length,
                                itemBuilder: (context, index) {
                                  final item = _searchResponse!.results[index];
                                  return UniversalSearchTile(
                                    item: item,
                                    onTap: () => _navigateToTarget(item),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/news_article_model.dart';
import '../services/news_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/bento_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();

  List<NewsArticleModel> _articles = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedCategory; // null = all
  bool _topStoriesOnly = false;

  final Map<int, String> _categories = {
    1: 'AI',
    0: 'Tech',
    3: 'Science',
    6: 'Lifestyle',
    2: 'Business',
    4: 'World',
    5: 'Health',
  };

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _newsService.getArticles(
        category: _selectedCategory,
        topStoriesOnly: _topStoriesOnly,
      );
      if (mounted) {
        setState(() {
          _articles = list;
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

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('Curated News Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadArticles,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row: Amber Star Filter ('★ Top Stories') + Category pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Amber Star Filter
                FilterChip(
                  avatar: Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: _topStoriesOnly ? const Color(0xFFF39C12) : tokens.textSecondary,
                  ),
                  label: const Text('★ Top Stories'),
                  selected: _topStoriesOnly,
                  onSelected: (selected) {
                    HapticFeedback.selectionClick();
                    setState(() => _topStoriesOnly = selected);
                    _loadArticles();
                  },
                  selectedColor: const Color(0xFFF39C12).withOpacity(0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _topStoriesOnly ? FontWeight.w700 : FontWeight.w500,
                    color: _topStoriesOnly ? const Color(0xFFF39C12) : tokens.textSecondary,
                  ),
                  side: BorderSide(
                    color: _topStoriesOnly ? const Color(0xFFF39C12) : tokens.strokeSubtle,
                  ),
                  backgroundColor: tokens.cardSurface,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = null);
                      _loadArticles();
                    }
                  },
                  selectedColor: tokens.intelligence.withOpacity(0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _selectedCategory == null ? FontWeight.w700 : FontWeight.w500,
                    color: _selectedCategory == null ? tokens.intelligence : tokens.textSecondary,
                  ),
                  side: BorderSide(
                    color: _selectedCategory == null ? tokens.intelligence : tokens.strokeSubtle,
                  ),
                  backgroundColor: tokens.cardSurface,
                ),
                const SizedBox(width: 8),
                ..._categories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = selected ? entry.key : null);
                        _loadArticles();
                      },
                      selectedColor: tokens.intelligence.withOpacity(0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? tokens.intelligence : tokens.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? tokens.intelligence : tokens.strokeSubtle,
                      ),
                      backgroundColor: tokens.cardSurface,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Article Cards Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: TextStyle(color: tokens.vaultAccent)))
                    : _articles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.newspaper_rounded,
                                    size: 48, color: tokens.textSecondary.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No articles found for this filter.\nCheck back after the next ingestion cycle!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadArticles,
                            color: tokens.intelligence,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _articles.length,
                              itemBuilder: (context, index) {
                                final article = _articles[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: BentoCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: tokens.intelligence.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                article.sourceName.toUpperCase(),
                                                style: TextStyle(
                                                  fontFamily: NexoraTheme.monoFont,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: tokens.intelligence,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (article.isTopStory)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF39C12).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  '⭐ Top Story',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFF39C12),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          article.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: tokens.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          article.summary,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: tokens.textSecondary,
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.schedule_rounded,
                                                size: 14, color: tokens.textSecondary.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              article.publishedAtUtc.toLocal().toString().substring(0, 16),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: tokens.textSecondary.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
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
}

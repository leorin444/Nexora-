import 'package:flutter/material.dart';
import '../models/news_article_model.dart';
import '../services/news_service.dart';

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
    0: 'Tech',
    1: 'AI',
    2: 'Business',
    3: 'Science',
    4: 'World',
    5: 'Health',
    6: 'Lifestyle',
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
      setState(() {
        _articles = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curated News Feed'),
        actions: [
          IconButton(
            icon: Icon(_topStoriesOnly ? Icons.star : Icons.star_border),
            color: _topStoriesOnly ? Colors.amber : null,
            tooltip: 'Top Stories Only',
            onPressed: () {
              setState(() {
                _topStoriesOnly = !_topStoriesOnly;
              });
              _loadArticles();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArticles,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = null);
                      _loadArticles();
                    }
                  },
                ),
                const SizedBox(width: 6),
                ..._categories.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _selectedCategory == entry.key,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = selected ? entry.key : null);
                        _loadArticles();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                    : _articles.isEmpty
                        ? const Center(
                            child: Text(
                              'No news articles found for this category.\nCheck back after the next ingestion cycle! 📰',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadArticles,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _articles.length,
                              itemBuilder: (context, index) {
                                final article = _articles[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              article.sourceName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (article.isTopStory)
                                              const Chip(
                                                label: Text('⭐ Top Story', style: TextStyle(fontSize: 10)),
                                                visualDensity: VisualDensity.compact,
                                                backgroundColor: Color(0xFFFFF9C4),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          article.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          article.summary,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          article.publishedAtUtc.toLocal().toString().substring(0, 16),
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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

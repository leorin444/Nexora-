class NewsArticleModel {
  final String id;
  final String url;
  final String title;
  final String summary;
  final String? content;
  final String sourceName;
  final String? imageUrl;
  final int category;
  final double curationScore;
  final bool isTopStory;
  final DateTime publishedAtUtc;
  final DateTime ingestedAtUtc;

  NewsArticleModel({
    required this.id,
    required this.url,
    required this.title,
    required this.summary,
    this.content,
    required this.sourceName,
    this.imageUrl,
    required this.category,
    required this.curationScore,
    required this.isTopStory,
    required this.publishedAtUtc,
    required this.ingestedAtUtc,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String?,
      sourceName: json['sourceName'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as int,
      curationScore: (json['curationScore'] as num).toDouble(),
      isTopStory: json['isTopStory'] as bool,
      publishedAtUtc: DateTime.parse(json['publishedAtUtc'] as String),
      ingestedAtUtc: DateTime.parse(json['ingestedAtUtc'] as String),
    );
  }
}

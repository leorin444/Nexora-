class SearchResultModel {
  final String id;
  final String title;
  final String? snippet;
  final int resultType; // 0=Note, 1=Reminder, 2=Calendar, 3=Vault, 4=News
  final String? categoryOrTag;
  final DateTime timestampUtc;

  SearchResultModel({
    required this.id,
    required this.title,
    this.snippet,
    required this.resultType,
    this.categoryOrTag,
    required this.timestampUtc,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      snippet: json['snippet'] as String?,
      resultType: json['resultType'] as int,
      categoryOrTag: json['categoryOrTag'] as String?,
      timestampUtc: DateTime.parse(json['timestampUtc'] as String),
    );
  }
}

class UnifiedSearchResponseModel {
  final String query;
  final int totalCount;
  final List<SearchResultModel> results;

  UnifiedSearchResponseModel({
    required this.query,
    required this.totalCount,
    required this.results,
  });

  factory UnifiedSearchResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return UnifiedSearchResponseModel(
      query: json['query'] as String,
      totalCount: json['totalCount'] as int,
      results: list.map((e) => SearchResultModel.fromJson(e)).toList(),
    );
  }
}

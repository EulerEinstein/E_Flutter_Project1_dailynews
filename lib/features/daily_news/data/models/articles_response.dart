import 'package:daily_news/features/daily_news/data/models/article.dart';

/// The JSON that NewsAPI really returns:
/// { "status": "ok", "totalResults": 38, "articles": [ {...}, {...} ] }
class ArticlesResponseModel {
  final String? status;
  final int? totalResults;
  final List<ArticleModel> articles;

  const ArticlesResponseModel({
    this.status,
    this.totalResults,
    this.articles = const [],
  });

  factory ArticlesResponseModel.fromJson(Map<String, dynamic> map) {
    final rawList = (map['articles'] as List<dynamic>?) ?? const [];
    return ArticlesResponseModel(
      status: map['status'] as String?,
      totalResults: map['totalResults'] as int?,
      articles: rawList
          .map((dynamic e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

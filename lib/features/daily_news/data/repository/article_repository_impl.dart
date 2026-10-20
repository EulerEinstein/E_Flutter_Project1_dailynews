import 'dart:io';

import 'package:daily_news/core/constants/constants.dart';
import 'package:daily_news/core/resources/data_state.dart';
import 'package:daily_news/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:daily_news/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:daily_news/features/daily_news/data/models/article.dart';
import 'package:daily_news/features/daily_news/data/models/article_table.dart';
import 'package:daily_news/features/daily_news/domain/entities/article.dart';
import 'package:daily_news/features/daily_news/domain/repository/article_repository.dart';
import 'package:dio/dio.dart';

class ArticleRepositoryImpl implements ArticleRepository {

  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    // NewsAPI rejects every request without a key (HTTP 401 apiKeyMissing).
    if (newsAPIKey.isEmpty) {
      return DataFailed(
        DioException(
          error: 'NEWS_API_KEY is empty. Run with '
              '--dart-define=NEWS_API_KEY=your_key',
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/top-headlines'),
        ),
      );
    }

    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        // NewsAPI wraps the list: { status, totalResults, articles: [...] }
        return DataSuccess(httpResponse.data.articles);
      } else {
        return DataFailed(
          DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final rows = await _appDatabase.articleDAO.getArticles();
    return rows.map((row) => row.toModel()).toList();
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    return _appDatabase.articleDAO.insertArticle(ArticleTable.fromEntity(article));
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    return _appDatabase.articleDAO.deleteArticle(ArticleTable.fromEntity(article));
  }
}

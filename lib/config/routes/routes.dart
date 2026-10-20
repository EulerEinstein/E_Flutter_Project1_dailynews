import 'package:flutter/material.dart';

import 'package:daily_news/features/daily_news/domain/entities/article.dart';
import 'package:daily_news/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:daily_news/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:daily_news/features/daily_news/presentation/pages/saved_article/saved_article.dart';

/// Central place that maps a route name to a page.
class AppRoutes {
  static const String home = '/';
  static const String articleDetails = '/ArticleDetails';
  static const String savedArticles = '/SavedArticles';

  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case articleDetails:
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity?),
        );
      case savedArticles:
        return _materialRoute(const SavedArticles());
      case home:
      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}

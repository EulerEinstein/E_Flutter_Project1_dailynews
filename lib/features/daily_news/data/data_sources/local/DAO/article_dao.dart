import 'package:floor_community/floor.dart';
import 'package:daily_news/features/daily_news/data/models/article_table.dart';

@dao
abstract class ArticleDao {

  @Insert()
  Future<void> insertArticle(ArticleTable article);

  @delete
  Future<void> deleteArticle(ArticleTable article);

  @Query('SELECT * FROM article')
  Future<List<ArticleTable>> getArticles();
}

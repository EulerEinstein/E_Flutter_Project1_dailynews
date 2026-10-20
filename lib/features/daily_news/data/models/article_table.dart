import 'package:floor_community/floor.dart';
import 'package:daily_news/features/daily_news/data/models/article.dart';
import 'package:daily_news/features/daily_news/domain/entities/article.dart';

/// Database row of the table `article` (Floor).
/// Separate from [ArticleModel] so that every column is declared exactly once.
@Entity(tableName: 'article')
class ArticleTable {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const ArticleTable({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory ArticleTable.fromEntity(ArticleEntity entity) {
    return ArticleTable(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
    );
  }

  ArticleModel toModel() {
    return ArticleModel(
      id: id,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
    );
  }
}

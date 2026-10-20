import 'package:floor_community/floor.dart';
import 'package:daily_news/features/daily_news/data/models/article_table.dart';
import 'package:daily_news/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
part 'app_database.g.dart';

@Database(version: 1, entities: [ArticleTable])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;
}

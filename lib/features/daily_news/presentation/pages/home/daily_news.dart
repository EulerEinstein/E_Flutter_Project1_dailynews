import 'package:daily_news/config/routes/routes.dart';
import 'package:daily_news/features/daily_news/domain/entities/article.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:daily_news/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class DailyNews extends StatelessWidget {

  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(
          color: Colors.black
        ),
      ),
      actions: [
        // Opens the saved articles page (was not reachable before)
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is RemoteArticlesError) {
          // Tap to try again
          final data = state.error?.response?.data;
          final reason = (data is Map ? data['message'] : null) ??
              state.error?.error ??
              state.error?.message ??
              'Could not load news';
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$reason', textAlign: TextAlign.center),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context
                      .read<RemoteArticlesBloc>()
                      .add(const GetArticles()),
                ),
              ],
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          final articles = state.articles ?? const <ArticleEntity>[];
          if (articles.isEmpty) {
            return const Center(child: Text('NO ARTICLES FOUND'));
          }
          return ListView.builder(
            itemCount: articles.length, // without it the list never ends -> RangeError
            itemBuilder: (context, index) {
              return ArticleWidget(
                article: articles[index],
                onArticlePressed: (article) => _onArticlePressed(context, article),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, AppRoutes.articleDetails, arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.savedArticles);
  }
}

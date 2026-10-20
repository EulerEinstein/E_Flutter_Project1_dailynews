import 'package:daily_news/config/routes/routes.dart';
import 'package:daily_news/config/theme/app_themes.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:daily_news/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (context) => sl()..add(const GetArticles()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme(),
        // '/' (home), '/ArticleDetails' and '/SavedArticles' are resolved here
        onGenerateRoute: AppRoutes.onGenerateRoutes,
      ),
    );
  }
}

# Changelog

This file records notable project changes over time. Add each new dated entry **below `[Unreleased]` and above older entries**, keeping the newest changes first.

## [Unreleased]

Add upcoming changes here before they are ready to be recorded under a date.

| # | Problem / goal | Change or fix | Files affected |
|---|---|---|---|
| 1 | _Describe the problem or goal_ | _Describe what changed and why_ | `path/to/file.dart` |

---

## [2026-10-20] — Flutter Daily News fixes

**Summary:** Addressed navigation, NewsAPI response parsing, local database model, state handling, and UI error-handling issues in the Flutter Daily News project.

### Changes and fixes

| # | Problem in the original | Fix | Files |
|---:|---|---|---|
| 1 | Screens called `Navigator.pushNamed('/ArticleDetails')`, but `MaterialApp` had no routes, causing a crash when opening an article. | Added a central route table and configured `MaterialApp` to use `onGenerateRoute`. | Added `lib/config/routes/routes.dart`; updated `lib/main.dart` |
| 2 | The saved-articles page could not be opened from anywhere. | Added a bookmark icon in the home AppBar to open `/SavedArticles`. | `lib/features/daily_news/presentation/pages/home/daily_news.dart` |
| 3 | NewsAPI returns an object containing `status`, `totalResults`, and `articles`, but generated Retrofit code expected a JSON list, causing a cast error and preventing news from loading. | Added `ArticlesResponseModel`; the service now returns `HttpResponse<ArticlesResponseModel>` and the repository returns `response.articles`. | Added `lib/features/daily_news/data/models/articles_response.dart`; updated `news_api_service.dart`, `news_api_service.g.dart`, `article_repository_impl.dart` |
| 4 | `ArticleModel` redeclared entity fields with `@override`, causing Floor to generate duplicate database columns. | Separated the database row into `ArticleTable`; `ArticleModel` is now the JSON model, and the repository converts between the table and model. | Added `lib/features/daily_news/data/models/article_table.dart`; updated `lib/features/daily_news/data/models/article.dart`, `article_dao.dart`, `app_database.dart`, `app_database.g.dart`, `article_repository_impl.dart` |
| 5 | The API key was hard-coded in `constants.dart` and exposed in the project files. | Read the key from `--dart-define=NEWS_API_KEY`. The old key should be revoked at NewsAPI. | `lib/core/constants/constants.dart` |
| 6 | `RemoteArticlesState.props` used `articles!` and `error!`, which could crash when comparing states containing null values. | Changed `props` to `List<Object?> [articles, error]`. | `remote_article_state.dart` |
| 7 | An empty article list emitted no completion state, leaving the loading spinner visible; the handler was also declared `void async`. | Changed the handler to `Future<void>`, emits Loading first, Error on failure, and Done on success—including an empty result. | `remote_article_bloc.dart` |
| 8 | `ListView.builder` had no `itemCount`, which could cause a `RangeError` after the final article. | Set `itemCount: articles.length` and show `NO ARTICLES FOUND` for an empty list. | `lib/features/daily_news/presentation/pages/home/daily_news.dart` |
| 9 | The error-state refresh icon did nothing. | Changed it to an `IconButton` that dispatches `GetArticles` again. | `lib/features/daily_news/presentation/pages/home/daily_news.dart` |
| 10 | `Image.network('')` on the article detail page could throw when the image URL was empty. | Added an `errorBuilder` that displays a broken-image icon. | `lib/features/daily_news/presentation/pages/article_detail/article_detail.dart` |
| 11 | `article.urlToImage!` could crash when the image URL was null. | Made the URL handling null-safe with `urlToImage ?? ''`; `CachedNetworkImage` can display its error widget. | `lib/features/daily_news/presentation/widgets/article_tile.dart` |
| 12 | `ArticleDetailsView` and `SavedArticles` extended `HookWidget` without using hooks. | Changed both to `StatelessWidget` and removed the unused `flutter_hooks` imports. | `article_detail.dart`, `saved_article.dart` |

### Maintenance

- Updated the Floor DAO, database entity configuration, repository conversions, and generated database/API code to match the revised models.
- Standardized edited files to LF line endings; the originals had mixed CRLF/LF endings.
- The original change report described 15 edited files, 3 added files, and 0 deleted files.

### Verification status

- These changes had **not been compiled or run** when prepared because a Dart/Flutter SDK was unavailable in that environment.
- The generated `*.g.dart` files were edited manually to match the source. Regenerate them with `build_runner` before relying on the generated code.

### Follow-up / known limitations

- Revoke the previously hard-coded NewsAPI key and supply a new key through `--dart-define=NEWS_API_KEY`.
- `DataState` still stores a `DioException`, so the domain layer remains dependent on Dio. Consider introducing domain-owned failure classes later.
- Saving the same article more than once is still possible; consider checking the article URL before inserting.
- Offline fallback, tests, and pagination were not added.
- `injection_container.dart`, the theme, domain layer, use cases, and local BLoC were not changed.

### Build and run

Run these commands from the project root after applying the changes:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=NEWS_API_KEY=your_new_key
```

If you use VS Code launch configurations, you can pass the key through `.vscode/launch.json` with an `args` entry:

```json
"args": ["--dart-define=NEWS_API_KEY=your_new_key"]
```

If you previously ran the old version on a device or emulator, the original notes recommend uninstalling that app once to remove the old database file.

### Detailed patch

See [`flutter-news-fixes-2026-10-20.diff`](flutter-news-fixes-2026-10-20.diff) for the line-by-line diff.

---

## Template for future dated entries

Copy this section to the top of the dated entries, replace the placeholders, and remove rows that do not apply. Keep the table for a quick problem → fix → file overview.

```markdown
## [YYYY-MM-DD] — Short description

| # | Problem / goal | Change or fix | Files affected |
|---:|---|---|---|
| 1 | _What was wrong or what was needed?_ | _What did you change, and why?_ | `path/to/file.dart` |

### Verification status
- _Not tested / tested in Chrome / tested on device / other details_

### Follow-up / known limitations
- _Anything still unresolved, if applicable_
```

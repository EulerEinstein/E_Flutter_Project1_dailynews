# Daily News

A Flutter news reader that shows the latest top headlines from [NewsAPI](https://newsapi.org), lets you open an article, and lets you save articles to read later. Saved articles are stored on the device, so they stay available between launches.

The project is also a working example of **Clean Architecture** in Flutter, using BLoC for state management.

---

## Features

- Top headlines from NewsAPI (`country=us`, `category=general`)
- Loading, error (with the reason and a retry button) and empty states
- Article detail page
- Save and remove articles, stored locally with Floor (SQLite)
- Saved articles page, opened from the bookmark icon in the home app bar

---

## Tech stack

| Purpose | Package |
|---|---|
| State management | `flutter_bloc`, `equatable` |
| Networking | `dio`, `retrofit` (+ `retrofit_generator`) |
| Local database | `floor_community` (SQLite) |
| Dependency injection | `get_it` |
| Image loading and caching | `cached_network_image` |
| Code generation | `build_runner` |

---

## Architecture

The app follows **Clean Architecture** with three layers. Dependencies point inward: the presentation layer and the data layer both depend on the domain layer, and the domain layer depends on neither.

```
Presentation  ──►  Domain  ◄──  Data
(UI + BLoC)     (business)    (API + database)
```

### Layers

**Presentation** (`presentation/`)
Pages, widgets and BLoCs. The UI sends events to a BLoC and rebuilds from the states it emits. It never talks to the API or database directly.

**Domain** (`domain/`)
The core of the app, with no Flutter or package-specific code except small shared types.
- `entities/`: plain objects such as `ArticleEntity`
- `repository/`: abstract contracts such as `ArticleRepository`
- `usecases/`: one class per action (`GetArticleUseCase`, `SaveArticleUseCase`, `RemoveArticleUseCase`, `GetSavedArticleUseCase`)

**Data** (`data/`)
Implements the domain contracts and talks to the outside world.
- `data_sources/remote/`: the Retrofit `NewsApiService`
- `data_sources/local/`: the Floor database and DAO
- `models/`: see below
- `repository/`: `ArticleRepositoryImpl`, which combines both sources

### Data models

| File | Role |
|---|---|
| `article.dart` (`ArticleModel`) | Reads one article from the NewsAPI JSON |
| `articles_response.dart` (`ArticlesResponseModel`) | Reads the wrapper NewsAPI returns: `{ status, totalResults, articles: [...] }` |
| `article_table.dart` (`ArticleTable`) | The Floor database row for a saved article |

They are separate on purpose. A change to the API JSON only affects `ArticleModel`, and a database schema change only affects `ArticleTable`.

### Request flow (loading news)

```
DailyNews page
   │  GetArticles event
   ▼
RemoteArticlesBloc
   │  calls
   ▼
GetArticleUseCase  ──►  ArticleRepository (interface)
                              │ implemented by
                              ▼
                        ArticleRepositoryImpl
                              │
                              ▼
                        NewsApiService (Retrofit + Dio)
                              │
                              ▼
                        NewsAPI  /v2/top-headlines
```

The result comes back as a `DataState` (`DataSuccess` or `DataFailed`). The BLoC turns it into `RemoteArticlesLoading`, `RemoteArticlesDone` or `RemoteArticlesError`, and the page rebuilds.

### Folder structure

```
lib/
├── main.dart
├── injection_container.dart          # get_it setup
├── config/
│   ├── routes/routes.dart            # named routes
│   └── theme/app_themes.dart
├── core/
│   ├── constants/constants.dart      # base URL, API key, query values
│   ├── resources/data_state.dart     # DataSuccess / DataFailed
│   └── usecases/usecase.dart
└── features/
    └── daily_news/
        ├── data/
        │   ├── data_sources/
        │   │   ├── remote/           # news_api_service(.g).dart
        │   │   └── local/            # app_database(.g).dart, DAO/article_dao.dart
        │   ├── models/               # article, articles_response, article_table
        │   └── repository/           # article_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   ├── repository/
        │   └── usecases/
        └── presentation/
            ├── bloc/article/{remote,local}/
            ├── pages/{home,article_detail,saved_article}/
            └── widgets/article_tile.dart
```

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel) with Dart
- An editor such as VS Code or Android Studio
- Chrome (for web), or an Android emulator or device
- A free NewsAPI key from <https://newsapi.org/register>

### Setup

1. **Get the code** and open the project folder in a terminal.

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (Retrofit and Floor files)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app with your API key.** The key is not stored in the source code. It is passed at run time:
   ```bash
   flutter run --dart-define=NEWS_API_KEY=your_key_here
   ```
   Add `-d chrome` to run in the browser.

### Using VS Code

Add the key to `.vscode/launch.json` so you don't type it each time:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "daily_news",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=NEWS_API_KEY=your_key_here"]
    }
  ]
}
```

Don't commit this file if it contains your real key. Add `.vscode/launch.json` to `.gitignore`.

### Android only

Release builds need the internet permission. Add this to `android/app/src/main/AndroidManifest.xml`, above the `<application` tag:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## Configuration

Values live in `lib/core/constants/constants.dart`:

| Constant | Value | Notes |
|---|---|---|
| `newsAPIBaseURL` | `https://newsapi.org/v2` | |
| `newsAPIKey` | from `NEWS_API_KEY` | Passed with `--dart-define` |
| `countryQuery` | `us` | Change for another country |
| `categoryQuery` | `general` | `business`, `sports`, `technology`, ... |

The final request looks like this:

```
https://newsapi.org/v2/top-headlines?apiKey=YOUR_KEY&country=us&category=general
```

---

## FAQ / Troubleshooting

### The app shows no news

The screen now shows the reason. The usual causes:

- **"NEWS_API_KEY is empty"**: run with `--dart-define=NEWS_API_KEY=your_key`.
- **"Your API key is invalid"**: check the key in your NewsAPI account.
- **Empty list**: NewsAPI returned no results for the country and category. Try a different `countryQuery` or `categoryQuery`.

### `SocketException: Failed host lookup: newsapi.org`

The device cannot resolve the domain, so it is a network problem, not a code problem.

- Open `https://newsapi.org` in the browser of the same emulator or device. If it fails, fix the connection (restart or cold boot the emulator, check your VPN or DNS).
- On Android, make sure the `INTERNET` permission is in `AndroidManifest.xml` (see above).
- Test the full URL in a browser to confirm your key works.

### NewsAPI works on Android but not on the web

The free (Developer) plan only allows browser requests from `localhost`. Run on `localhost` while developing, and use a paid plan or a small backend proxy for a deployed web app.

### Flutter cannot clean or delete files on Windows

`flutter clean` can fail with a "file in use" or access error on the Windows-generated folders, such as `windows\flutter\ephemeral\.plugin_symlinks` or `build`. These folders are generated, so you can delete them and Flutter will recreate them.

**Step 1.** Close VS Code, any running `flutter` or `dart` process, and any terminal opened in the project.

**Step 2.** Delete the generated folders manually. Open PowerShell and run these one at a time, replacing the path with your own project folder:

```powershell
$project = "C:\Users\<you>\Documents\Flutter\<your project folder>"

Remove-Item -LiteralPath "$project\windows\flutter\ephemeral\.plugin_symlinks" -Recurse -Force
```

If that succeeds, remove the build directory too:

```powershell
Remove-Item -LiteralPath "$project\build" -Recurse -Force
```

**Step 3.** Rebuild the project. Open VS Code again and run these from the project directory:

```bash
flutter clean
flutter pub get
flutter run -d chrome --dart-define=NEWS_API_KEY=your_key_here
```

Since you are launching on Chrome, you don't need the Windows desktop build to run the web app. Flutter's cleanup can still hit files in the Windows-generated folders, which is why they are removed first.

### Build errors about missing `*.g.dart` members

Regenerate the generated code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### The database seems broken after updating the app

The saved-articles table changed (`ArticleTable`). If you ran an older version, uninstall the app once from the device or emulator to remove the old database file, then run it again.

---

## Known limitations

- The domain layer's `DataState` still stores a Dio `DioException`, so the domain depends on Dio.
- The same article can be saved more than once.
- No offline fallback, pagination or automated tests yet.

---

## Security note

Never commit your NewsAPI key. A key that was ever hard-coded in the source, or pushed to a public repository, should be revoked in your NewsAPI account and replaced with a new one.

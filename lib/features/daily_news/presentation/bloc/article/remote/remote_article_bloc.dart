import 'package:daily_news/features/daily_news/domain/usecases/get_article.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:daily_news/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:daily_news/core/resources/data_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {

  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  Future<void> onGetArticles(GetArticles event, Emitter<RemoteArticlesState> emit) async {
    // Show the spinner again when the user taps "retry".
    emit(const RemoteArticlesLoading());

    final dataState = await _getArticleUseCase();

    if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    } else {
      // Success, also when the list is empty (the old code stayed on the spinner).
      emit(RemoteArticlesDone(dataState.data ?? const []));
    }
  }
}

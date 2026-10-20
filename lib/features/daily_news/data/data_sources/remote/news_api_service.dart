import 'package:daily_news/features/daily_news/data/models/articles_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:daily_news/core/constants/constants.dart';
import 'package:dio/dio.dart';
part 'news_api_service.g.dart';

@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio) = _NewsApiService;

  @GET('/top-headlines')
  Future<HttpResponse<ArticlesResponseModel>> getNewsArticles({
    @Query("apiKey") String? apiKey,
    @Query("country") String? country,
    @Query("category") String? category,
  });
}

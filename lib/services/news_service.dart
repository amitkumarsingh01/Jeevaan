import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  static const String _apiKey = '6ffcdf9d66c94d15a2acba70b553e7dd';
  static const String _baseUrl = 'https://newsapi.org/v2';

  /// Fetch health news articles
  static Future<NewsResponse> getHealthNews({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/everything?q=health&apiKey=$_apiKey&page=$page&pageSize=$pageSize&sortBy=publishedAt',
      );

      print('Fetching news from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromMap(data);
      } else {
        print('NewsAPI error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      throw Exception('Failed to fetch news: $e');
    }
  }

  /// Search news by query
  static Future<NewsResponse> searchNews(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/everything?q=$query&apiKey=$_apiKey&page=$page&pageSize=$pageSize&sortBy=publishedAt',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromMap(data);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching news: $e');
      throw Exception('Failed to search news: $e');
    }
  }
}


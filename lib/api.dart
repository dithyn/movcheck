import 'dart:convert';
import 'package:movcheck/secrets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<Map<String, dynamic>> _get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint&api_key=$tmdbApiKey');
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getTrendingMovies({String timeWindow = 'day'}) async => _get('/trending/movie/$timeWindow?');
  Future<Map<String, dynamic>> getTopRatedMovies() async => _get('/movie/top_rated?');
  Future<Map<String, dynamic>> getUpcomingMovies() async => _get('/movie/upcoming?');
  Future<Map<String, dynamic>> searchMovies(String query) async => _get('/search/movie?query=${Uri.encodeComponent(query)}');
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async => _get('/movie/$movieId?');
  Future<Map<String, dynamic>> getMovieCredits(int movieId) async => _get('/movie/$movieId/credits?');
  Future<Map<String, dynamic>> getPersonDetails(int personId) async => _get('/person/$personId?');
  Future<Map<String, dynamic>> getPersonMovieCredits(int personId) async => _get('/person/$personId/movie_credits?');
  // In lib/api.dart, inside the Api class

/// Fetches watch providers (streaming services) for a specific movie.
Future<Map<String, dynamic>> getWatchProviders(int movieId) async {
  return _get('/movie/$movieId/watch/providers?');
}
}

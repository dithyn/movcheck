// lib/api.dart

import 'dart:convert';
import 'package:movcheck/secrets.dart'; // Replace 'package_name' with your actual project name
import 'package:http/http.dart' as http;

class Api {
  // Base URL for all TMDb API requests
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Common function to handle API requests and error checking
  Future<Map<String, dynamic>> _get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint&api_key=$tmdbApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data from TMDb. Status code: ${response.statusCode}');
    }
  }

  // --- Functions for the Main Page ---

  /// Fetches trending movies for a given time window ('day' or 'week').
  Future<Map<String, dynamic>> getTrendingMovies({String timeWindow = 'day'}) async {
    return _get('/trending/movie/$timeWindow?');
  }

  /// Fetches a list of popular movies.
  Future<Map<String, dynamic>> getPopularMovies() async {
    return _get('/movie/popular?');
  }

  /// Fetches a list of top-rated movies.
  Future<Map<String, dynamic>> getTopRatedMovies() async {
    return _get('/movie/top_rated?');
  }

  /// Fetches a list of movies currently playing in theaters.
  Future<Map<String, dynamic>> getNowPlayingMovies() async {
    return _get('/movie/now_playing?');
  }

  /// Fetches a list of upcoming movies.
  Future<Map<String, dynamic>> getUpcomingMovies() async {
    return _get('/movie/upcoming?');
  }

  // --- Function for Searching ---

  /// Searches for movies based on a user's query.
  Future<Map<String, dynamic>> searchMovies(String query) async {
    // URL-encode the query to handle spaces and special characters
    final encodedQuery = Uri.encodeComponent(query);
    return _get('/search/movie?query=$encodedQuery');
  }

  // --- Functions for the Movie Details Page ---

  /// Fetches detailed information for a specific movie by its ID.
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return _get('/movie/$movieId?');
  }

  /// Fetches the cast and crew for a specific movie.
  Future<Map<String, dynamic>> getMovieCredits(int movieId) async {
    return _get('/movie/$movieId/credits?');
  }

  /// Fetches user reviews for a specific movie.
  Future<Map<String, dynamic>> getMovieReviews(int movieId) async {
    return _get('/movie/$movieId/reviews?');
  }

  /// Fetches a list of similar movies for a specific movie.
  Future<Map<String, dynamic>> getSimilarMovies(int movieId) async {
    return _get('/movie/$movieId/similar?');
  }
}

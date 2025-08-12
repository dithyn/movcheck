    import 'dart:convert';
    import 'package:movcheck/secrets.dart';
    import 'package:http/http.dart' as http;

    class Api {
    static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';
    // NEW: Base URL for the OMDb API
    static const String _omdbBaseUrl = 'http://www.omdbapi.com/?';

    Future<Map<String, dynamic>> _get(String url) async {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
        return jsonDecode(response.body);
        } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
        }
    }

    Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
        final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json;charset=utf-8'},
        body: jsonEncode(body),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
        } else {
        throw Exception('Failed to post data. Status code: ${response.statusCode}');
        }
    }

    // --- TMDb Functions ---
    Future<Map<String, dynamic>> getTrendingMovies({String timeWindow = 'day'}) async => _get('$_tmdbBaseUrl/trending/movie/$timeWindow?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getTopRatedMovies() async => _get('$_tmdbBaseUrl/movie/top_rated?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getUpcomingMovies() async => _get('$_tmdbBaseUrl/movie/upcoming?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getNowPlayingMovies() async => _get('$_tmdbBaseUrl/movie/now_playing?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getPopularMovies() async => _get('$_tmdbBaseUrl/movie/popular?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> searchMovies(String query) async => _get('$_tmdbBaseUrl/search/movie?query=${Uri.encodeComponent(query)}&api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getMovieDetails(int movieId) async => _get('$_tmdbBaseUrl/movie/$movieId?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getMovieCredits(int movieId) async => _get('$_tmdbBaseUrl/movie/$movieId/credits?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getWatchProviders(int movieId) async => _get('$_tmdbBaseUrl/movie/$movieId/watch/providers?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getMovieGenres() async => _get('$_tmdbBaseUrl/genre/movie/list?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getMoviesByGenre(int genreId) async => _get('$_tmdbBaseUrl/discover/movie?with_genres=$genreId&api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getPersonDetails(int personId) async => _get('$_tmdbBaseUrl/person/$personId?api_key=$tmdbApiKey');
    Future<Map<String, dynamic>> getPersonMovieCredits(int personId) async => _get('$_tmdbBaseUrl/person/$personId/movie_credits?api_key=$tmdbApiKey');
    Future<String?> createGuestSession() async => (await _get('$_tmdbBaseUrl/authentication/guest_session/new?api_key=$tmdbApiKey'))['guest_session_id'];
    Future<void> rateMovie(String guestSessionId, int movieId, double rating) async => _post('$_tmdbBaseUrl/movie/$movieId/rating?guest_session_id=$guestSessionId&api_key=$tmdbApiKey', {'value': rating});

    // NEW: Function to get the IMDb ID from TMDb.
    Future<String?> getImdbId(int movieId) async {
        final data = await _get('$_tmdbBaseUrl/movie/$movieId/external_ids?api_key=$tmdbApiKey');
        return data['imdb_id'];
    }

    // NEW: Function to get ratings from OMDb using the IMDb ID.
    Future<Map<String, dynamic>> getRatingsFromOMDb(String imdbId) async {
        return _get('$_omdbBaseUrl&i=$imdbId&apikey=$omdbApiKey');
    }
    }

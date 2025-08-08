// Example of using the key in another file
import 'package:movcheck/secrets.dart'; // Make sure the path is correct

void fetchMovies() {
  final apiKey = tmdbApiKey;
  final url = 'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';
  // ... your http request code ...
}
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:movcheck/api.dart'; // <-- IMPORTANT: Replace with your package name

// An enum to define the image quality for the poster.
// This makes the code cleaner and less prone to typos.
enum ImageQuality { standard, original }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Api api = Api();
  bool _isLoading = true;
  String? _errorMessage;

  List _trendingMovies = [];
  List _topRatedMovies = [];
  List _upcomingMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchAllMovies();
  }

  Future<void> _fetchAllMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        api.getTrendingMovies(),
        api.getTopRatedMovies(),
        api.getUpcomingMovies(),
      ]);

      setState(() {
        _trendingMovies = results[0]['results'];
        _topRatedMovies = results[1]['results'];
        _upcomingMovies = results[2]['results'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load movies. Please check your connection.";
        _isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(), backgroundColor: Colors.white);
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAllMovies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  // This is the main "Trending Wall" PageView.
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: PageView.builder(
                      itemCount: _trendingMovies.length,
                      itemBuilder: (context, index) {
                        // We pass ImageQuality.original to get the high-res poster.
                        return MoviePoster(
                          posterPath: _trendingMovies[index]['poster_path'],
                          quality: ImageQuality.original,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMovieCategoryRow(
                    title: 'Top Rated Movies',
                    movies: _topRatedMovies,
                  ),
                  const SizedBox(height: 24),
                  _buildMovieCategoryRow(
                    title: 'Upcoming Movies',
                    movies: _upcomingMovies,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Your glassmorphism search bar remains the same.
        AnimatedAlign(
          duration: const Duration(milliseconds: 1000),
          alignment: const Alignment(0, -0.9),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 80,
                  width: MediaQuery.of(context).size.width - 60,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCategoryRow({required String title, required List movies}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'ClashDisplay',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              // For these horizontal rows, we pass ImageQuality.standard.
              return MoviePoster(
                posterPath: movies[index]['poster_path'],
                quality: ImageQuality.standard,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A reusable widget to display a single movie poster image.
class MoviePoster extends StatelessWidget {
  final String? posterPath;
  // The new required parameter to control image quality.
  final ImageQuality quality;

  const MoviePoster({
    super.key,
    required this.posterPath,
    // Set a default value for safety, although we always provide one.
    this.quality = ImageQuality.standard,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the image size string based on the quality parameter.
    final imageSize = quality == ImageQuality.original ? 'original' : 'w500';
    final imageUrlBase = 'https://image.tmdb.org/t/p/$imageSize';
    final imageUrl = posterPath != null ? '$imageUrlBase$posterPath' : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          // The width is different for the main poster vs. the thumbnails.
          width: quality == ImageQuality.original ? null : 130,
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[850],
                      child: const Center(
                        child: Icon(Icons.movie_creation_outlined),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[850],
                  child: const Center(
                    child: Icon(Icons.movie_creation_outlined),
                  ),
                ),
        ),
      ),
    );
  }
}

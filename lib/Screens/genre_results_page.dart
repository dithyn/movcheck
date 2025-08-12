import 'package:flutter/material.dart';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/Homescreen.dart';

class GenreResultsPage extends StatefulWidget {
  final int genreId;
  final String genreName;
  const GenreResultsPage({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  State<GenreResultsPage> createState() => _GenreResultsPageState();
}

class _GenreResultsPageState extends State<GenreResultsPage> {
  final Api api = Api();
  bool _isLoading = true;
  List _movies = [];

  @override
  void initState() {
    super.initState();
    _fetchMoviesByGenre();
  }

  Future<void> _fetchMoviesByGenre() async {
    try {
      final data = await api.getMoviesByGenre(widget.genreId);
      if (mounted) {
        setState(() {
          _movies = data['results'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70,

            collapsedHeight: 60,
            title: Text(
              widget.genreName,
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 10,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final movie = _movies[index];
                      return MoviePoster(
                        movieId: movie['id'],
                        posterPath: movie['poster_path'],
                        quality: ImageQuality.standard,
                      );
                    }, childCount: _movies.length),
                  ),
                ),
        ],
      ),
    );
  }
}

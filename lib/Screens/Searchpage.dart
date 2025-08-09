import 'package:flutter/material.dart';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/Homescreen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Api api = Api();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List _searchResults = [];
  bool _hasSearched = false;

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });
    try {
      final data = await api.searchMovies(query);
      if (!mounted) return;
      setState(() {
        _searchResults = data['results'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to search. Please check your connection.";
        _isLoading = false;
      });
      print(e);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          // The body is now built with sliver-aware widgets.
          _buildResultsBody(),
        ],
      ),
    );
  }

  /// Builds the collapsing app bar with the search field.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 175.0, // Increased height to fit the column
      pinned: true,
      floating: true,

      // This title appears when the app bar is collapsed.
      flexibleSpace: FlexibleSpaceBar(
        // The background contains the expanded layout.
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. The large "Search!" Title
                const Text(
                  'Search!',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
                const SizedBox(height: 16),
                // 2. The Search TextField
                TextField(
                  controller: _searchController,
                  onSubmitted: _searchMovies,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Search for a movie...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).hintColor,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
                const SizedBox(height: 16), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Determines what to show in the main body based on the current state.
  /// This widget now returns a Sliver, not a regular widget.
  Widget _buildResultsBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return SliverFillRemaining(child: Center(child: Text(_errorMessage!)));
    }
    final hintStyle = TextStyle(
      fontSize: 18,
      color: Theme.of(context).hintColor,
    );
    if (!_hasSearched) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 60,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text('Find your next favorite movie!', style: hintStyle),
            ],
          ),
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_filter_outlined,
                size: 60,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text('No results found. Try another search.', style: hintStyle),
            ],
          ),
        ),
      );
    }
    // Use SliverPadding and SliverGrid for the results.
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final movie = _searchResults[index];
          return MoviePoster(
            movieId: movie['id'],
            posterPath: movie['poster_path'],
            quality: ImageQuality.standard,
          );
        }, childCount: _searchResults.length),
      ),
    );
  }
}

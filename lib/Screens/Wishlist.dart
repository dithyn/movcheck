import 'package:flutter/material.dart';
import 'package:movcheck/Screens/MovieDetailsPage.dart';
import 'package:movcheck/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // State variables to manage selection mode
  bool _isSelectionMode = false;
  final Set<int> _selectedMovieIds = {};

  void _onLongPress(int movieId) {
    setState(() {
      _isSelectionMode = true;
      _selectedMovieIds.add(movieId);
    });
  }

  void _onTap(int movieId) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedMovieIds.contains(movieId)) {
          _selectedMovieIds.remove(movieId);
        } else {
          _selectedMovieIds.add(movieId);
        }
        // Exit selection mode if no items are selected
        if (_selectedMovieIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      // Default navigation behavior
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsPage(movieId: movieId),
        ),
      );
    }
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedMovieIds.clear();
    });
  }

  void _deleteSelected() {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    for (int id in _selectedMovieIds) {
      wishlistProvider.removeFromWishlist(id);
    }
    _cancelSelection();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlist = wishlistProvider.wishlist;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(wishlistProvider),
              wishlist.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_outline,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your wishlist is empty.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          final movie = wishlist[index];
                          final isSelected = _selectedMovieIds.contains(
                            movie['id'],
                          );
                          return _WishlistItem(
                            movie: movie,
                            isSelected: isSelected,
                            onTap: () => _onTap(movie['id']),
                            onLongPress: () => _onLongPress(movie['id']),
                          );
                        }, childCount: wishlist.length),
                      ),
                    ),
            ],
          ),

          AnimatedOpacity(
            opacity: _isSelectionMode ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Align(
              alignment: AlignmentGeometry.xy(0.8, 0.7),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),

                height: 60,
                width: 130,
                child: ElevatedButton(
                  onPressed: _deleteSelected,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.delete_outline, size: 23),
                      Text(
                        "Delete",
                        style: TextStyle(fontFamily: 'Product', fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(WishlistProvider wishlistProvider) {
    return SliverAppBar(
      expandedHeight: 97.0,
      pinned: true,

      // Show different actions based on selection mode
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _isSelectionMode
              ? '${_selectedMovieIds.length} selected'
              : 'Watchlist',
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 39,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
    );
  }
}

/// A custom widget for displaying a movie in the wishlist grid.
class _WishlistItem extends StatelessWidget {
  final Map<String, dynamic> movie;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WishlistItem({
    required this.movie,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Movie Poster
            Image.network(
              'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.movie_creation_outlined),
                  ),
                );
              },
            ),
            // Animated overlay for selection
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

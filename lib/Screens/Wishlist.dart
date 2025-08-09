import 'package:flutter/material.dart';
import 'package:movcheck/Screens/MovieDetailsPage.dart';
import 'package:movcheck/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlist = wishlistProvider.wishlist;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Wishlist',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          // Check if the wishlist is empty.
          wishlist.isEmpty
              // If empty, show a message that fills the remaining space.
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
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              // If not empty, build the list of movies.
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final movie = wishlist[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        movie['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        (movie['release_date'] as String).split('-')[0],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          wishlistProvider.removeFromWishlist(movie['id']);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailsPage(movieId: movie['id']),
                          ),
                        );
                      },
                    );
                  }, childCount: wishlist.length),
                ),
        ],
      ),
    );
  }
}

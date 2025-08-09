import 'package:flutter/material.dart';
import 'dart:ui'; // Import this for the blur effect
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/Homescreen.dart';
import 'package:movcheck/Screens/PersonDetailsPage.dart';
import 'package:movcheck/providers/wishlist_provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// NEW: The complete skeleton layout for the MovieDetailsPage.
class MovieDetailsPageSkeleton extends StatelessWidget {
  const MovieDetailsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          pinned: true,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Skeleton(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 22, width: 120),
                const SizedBox(height: 16),
                const Skeleton(height: 16, width: double.infinity),
                const SizedBox(height: 8),
                const Skeleton(height: 16, width: double.infinity),
                const SizedBox(height: 8),
                const Skeleton(height: 16, width: 200),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Skeleton(height: 60, width: 170, borderRadius: 30),
                    Skeleton(height: 60, width: 60, borderRadius: 30),
                    Skeleton(height: 60, width: 60, borderRadius: 30),
                  ],
                ),
                const SizedBox(height: 24),
                const Skeleton(height: 22, width: 80),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Column(
                        children: [
                          Expanded(child: Skeleton(width: 100)),
                          SizedBox(height: 8),
                          Skeleton(height: 12, width: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final Api api = Api();
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _movieDetails;
  List _movieCast = [];
  Map<String, dynamic>? _watchProviders;
  bool _isExpanded = false;
  Color _titleColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        api.getMovieDetails(widget.movieId),
        api.getMovieCredits(widget.movieId),
        api.getWatchProviders(widget.movieId),
      ]);
      if (!mounted) return;
      setState(() {
        _movieDetails = results[0];
        _movieCast = results[1]['cast'];
        _watchProviders = results[2]['results'];
      });

      if (_movieDetails?['poster_path'] != null) {
        _updateTitleColor(_movieDetails!['poster_path']);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load movie details.";
        _isLoading = false;
      });
      print(e);
    }
  }

  Future<void> _updateTitleColor(String posterPath) async {
    final imageUrl = 'https://image.tmdb.org/t/p/w500$posterPath';
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
            NetworkImage(imageUrl),
            size: const Size(100, 150),
          );
      final dominantColor =
          paletteGenerator.dominantColor?.color ?? Colors.black;
      final newTitleColor = dominantColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;
      if (!mounted) return;
      setState(() {
        _titleColor = newTitleColor;
        _isLoading = false;
      });
    } catch (e) {
      print("Error generating palette: $e");
      if (!mounted) return;
      setState(() {
        _titleColor = Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      print('Could not launch $urlString');
    }
  }

  void _showWatchProvidersSheet() {
    if (_watchProviders == null || !_watchProviders!.containsKey('IN')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No streaming options found for this region.'),
        ),
      );
      return;
    }

    final indianProviders = _watchProviders!['IN'];
    final link = indianProviders['link'];
    final Map<int, dynamic> uniqueProviders = {};

    if (indianProviders.containsKey('flatrate')) {
      for (var provider in indianProviders['flatrate']) {
        uniqueProviders[provider['provider_id']] = provider;
      }
    }
    if (indianProviders.containsKey('rent')) {
      for (var provider in indianProviders['rent']) {
        uniqueProviders[provider['provider_id']] = provider;
      }
    }
    if (indianProviders.containsKey('buy')) {
      for (var provider in indianProviders['buy']) {
        uniqueProviders[provider['provider_id']] = provider;
      }
    }

    final allStreamingServices = uniqueProviders.values.toList();

    if (allStreamingServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No streaming options found for this region.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available on',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Product',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allStreamingServices.length,
                  itemBuilder: (context, index) {
                    final provider = allStreamingServices[index];
                    return _buildProviderButton(provider, link);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderButton(Map<String, dynamic> provider, String link) {
    final logoUrl = 'https://image.tmdb.org/t/p/w500${provider['logo_path']}';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.grey.shade500;
    final lightSourceColor = isDarkMode ? Colors.grey.shade800 : Colors.white;

    return GestureDetector(
      onTap: () => _launchURL(link),
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 10,
            ),
            BoxShadow(
              color: lightSourceColor,
              offset: const Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                logoUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                provider['provider_name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      // UPDATED: Show the skeleton UI while loading.
      return const MovieDetailsPageSkeleton();
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMovieDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_movieDetails == null) {
      return const Center(child: Text('No movie details available.'));
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _movieDetails!['overview'],
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontFamily: 'Product',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: _isExpanded ? null : 4,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isExpanded ? 'Show less' : 'Read more',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showWatchProvidersSheet,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Stream Now',
                        style: TextStyle(fontFamily: 'Product'),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, child) {
                        final isFavorite = wishlistProvider.isFavorite(
                          widget.movieId,
                        );
                        return ElevatedButton(
                          onPressed: () {
                            if (isFavorite) {
                              wishlistProvider.removeFromWishlist(
                                widget.movieId,
                              );
                            } else {
                              wishlistProvider.addToWishlist(_movieDetails!);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20), // Make it bigger
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Add share functionality here
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20), // Make it bigger
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant,
                      ),
                      child: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cast',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product',
                  ),
                ),
                const SizedBox(height: 12),
                _buildCastList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _movieDetails!['title'],
          style: TextStyle(
            color: _titleColor,
            fontFamily: 'ClashDisplay',
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: _titleColor.computeLuminance() > 0.5
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 50),
        background: MoviePoster(
          movieId: widget.movieId,
          posterPath: _movieDetails!['poster_path'],
          quality: ImageQuality.original,
        ),
      ),
    );
  }

  Widget _buildCastList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _movieCast.length,
        itemBuilder: (context, index) {
          final actor = _movieCast[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Expanded(
                  child: MoviePoster(
                    movieId: -1,
                    posterPath: actor['profile_path'],
                    quality: ImageQuality.standard,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PersonDetailsPage(personId: actor['id']),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  actor['name'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

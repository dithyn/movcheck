import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/moviedetailspage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

enum ImageQuality { standard, original }

// A reusable skeleton widget for placeholder UI.
class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const Skeleton({super.key, this.height, this.width, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// A specific skeleton for the movie posters.
class MoviePosterSkeleton extends StatelessWidget {
  final bool isOriginalQuality;
  const MoviePosterSkeleton({super.key, this.isOriginalQuality = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Skeleton(width: isOriginalQuality ? null : 130),
    );
  }
}

// The complete skeleton layout for the HomeScreen.
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: const MoviePosterSkeleton(isOriginalQuality: true),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildSkeletonCategoryRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildSkeletonCategoryRow()),
        // ADDED: Skeletons for the new categories
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildSkeletonCategoryRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildSkeletonCategoryRow()),
      ],
    );
  }

  Widget _buildSkeletonCategoryRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Skeleton(height: 20, width: 150),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) => const MoviePosterSkeleton(),
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Api api = Api();
  bool _isLoading = true;
  String? _errorMessage;
  // ADDED: State variables for new categories
  List _trendingMovies = [],
      _topRatedMovies = [],
      _upcomingMovies = [],
      _nowPlayingMovies = [],
      _popularMovies = [];
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchAllMovies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 50 && _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = false;
      });
    } else if (_scrollController.offset <= 50 && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
      });
    }
  }

  Future<void> _fetchAllMovies() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // ADDED: API calls for new categories
      final results = await Future.wait([
        api.getTrendingMovies(),
        api.getTopRatedMovies(),
        api.getUpcomingMovies(),
        api.getNowPlayingMovies(),
        api.getPopularMovies(),
      ]);
      if (!mounted) return;
      setState(() {
        _trendingMovies = results[0]['results'];
        _topRatedMovies = results[1]['results'];
        _upcomingMovies = results[2]['results'];
        _nowPlayingMovies = results[3]['results'];
        _popularMovies = results[4]['results'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load movies. Please check your connection.";
        _isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const HomeScreenSkeleton();
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
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
        CustomScrollView(
          physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _trendingMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _trendingMovies[index];
                        return MoviePoster(
                          movieId: movie['id'],
                          posterPath: movie['poster_path'],
                          title: movie['title'],
                          quality: ImageQuality.original,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverToBoxAdapter(
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _trendingMovies.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 20,
                    spacing: 6,
                    activeDotColor: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!,
                    dotColor: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildMovieCategoryRow(
                title: 'Top Rated Movies',
                movies: _topRatedMovies,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildMovieCategoryRow(
                title: 'Upcoming Movies',
                movies: _upcomingMovies,
              ),
            ),
            // ADDED: UI rows for new categories
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildMovieCategoryRow(
                title: 'Now Playing',
                movies: _nowPlayingMovies,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _buildMovieCategoryRow(
                title: 'Popular Movies',
                movies: _popularMovies,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100.0)),
          ],
        ),
        _buildFloatingAppBar(),
      ],
    );
  }

  Widget _buildFloatingAppBar() {
    return AnimatedOpacity(
      opacity: _isAppBarVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            ),
            child: Text(
              'MovCheck',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'ClashDisplay',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCategoryRow({required String title, required List movies}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Product',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final movie = movies[index];
              // Wrap the Column with a SizedBox to constrain its width
              return SizedBox(
                width: 130, // Match the width of the MoviePoster
                child: Column(
                  children: [
                    MoviePoster(
                      movieId: movie['id'],
                      posterPath: movie['poster_path'],
                      quality: ImageQuality.standard,
                    ),
                    const SizedBox(height: 8), // Add some space
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        movie['title'],
                        textAlign: TextAlign.center, // Center the text
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontFamily: 'Product',
                        ),
                        softWrap: true,
                        overflow:
                            TextOverflow.ellipsis, // Use ellipsis for overflow
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MoviePoster extends StatelessWidget {
  final int movieId;
  final String? posterPath;
  final String? title;
  final ImageQuality quality;
  final VoidCallback? onTap;

  const MoviePoster({
    super.key,
    required this.movieId,
    required this.posterPath,
    this.title,
    this.quality = ImageQuality.standard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = quality == ImageQuality.original ? 'original' : 'w500';
    final imageUrlBase = 'https://image.tmdb.org/t/p/$imageSize';
    final imageUrl = posterPath != null ? '$imageUrlBase$posterPath' : null;

    final imageWidget = SizedBox(
      width: quality == ImageQuality.original ? null : 130,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                  ? child
                  : const Skeleton(borderRadius: 0),
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(child: Icon(Icons.movie_creation_outlined)),
              ),
            )
          : Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Center(child: Icon(Icons.movie_creation_outlined)),
            ),
    );

    final VoidCallback defaultOnTap = () {
      if (movieId != -1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsPage(movieId: movieId),
          ),
        );
      }
    };

    return GestureDetector(
      onTap: onTap ?? defaultOnTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: quality == ImageQuality.original && title != null
              ? Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.topCenter,
                  children: [
                    imageWidget,
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 300.0,
                      left: 12.0,
                      right: 12.0,
                      child: Text(
                        title!,
                        style: const TextStyle(
                          height: 1,
                          letterSpacing: -2,

                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : imageWidget,
        ),
      ),
    );
  }
}

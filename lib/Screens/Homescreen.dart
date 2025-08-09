import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/MovieDetailsPage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

enum ImageQuality { standard, original }

// NEW: A reusable skeleton widget for placeholder UI.
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

// NEW: A specific skeleton for the movie posters.
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

// NEW: The complete skeleton layout for the HomeScreen.
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100.0),
          children: [
            // Skeleton for the PageView
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: const MoviePosterSkeleton(isOriginalQuality: true),
            ),
            const SizedBox(height: 24),
            _buildSkeletonCategoryRow(),
            const SizedBox(height: 24),
            _buildSkeletonCategoryRow(),
          ],
        ),
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
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(width: 7);
            },
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Show 5 placeholder items
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
  List _trendingMovies = [], _topRatedMovies = [], _upcomingMovies = [];
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
    // Simulate a longer load time to see the skeleton UI
    // await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _trendingMovies = results[0]['results'];
        _topRatedMovies = results[1]['results'];
        _upcomingMovies = results[2]['results'];
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
    // UPDATED: Show the skeleton UI while loading.
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
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100.0),
          children: [
            Stack(
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _trendingMovies.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 5,
                  spacing: 4,
                  dotWidth: 20,
                  activeDotColor: Theme.of(context).textTheme.bodyLarge!.color!,
                  dotColor: Theme.of(context).hintColor,
                ),
              ),
            ),
            const SizedBox(height: 5),
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
            height: 110,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'MovCheck',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ClashDisplay',
                ),
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
          height: 200,
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(width: 7);
            },
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MoviePoster(
                movieId: movie['id'],
                posterPath: movie['poster_path'],
                quality: ImageQuality.standard,
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
              // UPDATED: Use a skeleton for the image loading placeholder.
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
                  Padding(
                    padding: const EdgeInsets.only(left: 9.0),
                    child: Align(
                      alignment: AlignmentGeometry.xy(-1, 0.8),
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 40,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'ClashDisplay',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              )
            : imageWidget,
      ),
    );
  }
}

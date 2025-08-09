import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/MovieDetailsPage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  List _trendingMovies = [], _topRatedMovies = [], _upcomingMovies = [];
  late PageController _pageController;

  // NEW: Controller to detect scroll position.
  late ScrollController _scrollController;
  // NEW: State variable to control app bar visibility.
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    // Add a listener to the scroll controller.
    _scrollController.addListener(_scrollListener);
    _fetchAllMovies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Remove the listener and dispose of the controller to prevent memory leaks.
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // NEW: Listener method to update app bar visibility.
  void _scrollListener() {
    // If user scrolls down more than 50 pixels, hide the app bar.
    if (_scrollController.offset > 50 && _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = false;
      });
    }
    // If user scrolls back to the top, show the app bar.
    else if (_scrollController.offset <= 50 && !_isAppBarVisible) {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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

    // UPDATED: The body is now a Stack to allow the app bar to float on top.
    return Stack(
      children: [
        ListView(
          // Attach the scroll controller here.
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
                      return Stack(
                        children: [
                          MoviePoster(
                            movieId: movie['id'],
                            posterPath: movie['poster_path'],
                            title: movie['title'],
                            quality: ImageQuality.original,
                          ),
                          Align(
                            alignment: AlignmentGeometry.xy(-0.8, 0.8),
                            child: Padding(
                              padding: EdgeInsetsGeometry.only(left: 0),
                              child: Text(
                                movie['title'],
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 20,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Product',
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _trendingMovies.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 20,
                      activeDotColor: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!,
                      dotColor: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
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
        // NEW: The animated floating app bar.
        _buildFloatingAppBar(),
      ],
    );
  }

  // NEW: Widget for the animated app bar.
  Widget _buildFloatingAppBar() {
    return AnimatedOpacity(
      opacity: _isAppBarVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 110, // Height includes status bar area
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
    // ... (This widget remains the same)
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
          child: ListView.builder(
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
  // ... (This widget remains the same)
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
                  : const Center(child: CircularProgressIndicator()),
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
                alignment: Alignment.bottomLeft,
                children: [
                  imageWidget,
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : imageWidget,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/Homescreen.dart';

class PersonDetailsPage extends StatefulWidget {
  final int personId;
  const PersonDetailsPage({super.key, required this.personId});

  @override
  State<PersonDetailsPage> createState() => _PersonDetailsPageState();
}

class _PersonDetailsPageState extends State<PersonDetailsPage> {
  final Api api = Api();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _personDetails;
  List _movieCredits = [];

  @override
  void initState() {
    super.initState();
    _fetchPersonDetails();
  }

  Future<void> _fetchPersonDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        api.getPersonDetails(widget.personId),
        api.getPersonMovieCredits(widget.personId),
      ]);
      if (!mounted) return;
      setState(() {
        _personDetails = results[0];
        _movieCredits = results[1]['cast'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load person details.";
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
              onPressed: _fetchPersonDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_personDetails == null) {
      return const Center(child: Text('No details available for this person.'));
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
                  'Biography',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _personDetails!['biography'].isNotEmpty
                      ? _personDetails!['biography']
                      : 'No biography available.',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontFamily: 'Product',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Known For',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildFilmographyList(),
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
          _personDetails!['name'],
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 50),
        background: MoviePoster(
          movieId: -1,
          posterPath: _personDetails!['profile_path'],
          quality: ImageQuality.original,
        ),
      ),
    );
  }

  Widget _buildFilmographyList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _movieCredits.length,
        itemBuilder: (context, index) {
          final movie = _movieCredits[index];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Expanded(
                  child: MoviePoster(
                    movieId: movie['id'],
                    posterPath: movie['poster_path'],
                    quality: ImageQuality.standard,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie['title'],
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

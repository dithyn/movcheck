import 'dart:math';

import 'package:flutter/material.dart';
import 'package:movcheck/api.dart';
import 'package:movcheck/Screens/genre_results_page.dart';

final List<Gradient> genreGradients = [
  const LinearGradient(
    colors: [Color(0xff141E30), Color(0xff243B55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xff434343), Color(0xff000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xff3a6186), Color(0xff89253e)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xff232526), Color(0xff414345)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xff870000), Color(0xff190a05)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xff16222A), Color(0xff3A6073)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final Api api = Api();
  bool _isLoading = true;
  List _genres = [];

  late List<Gradient> _randomizedGradients;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    try {
      final data = await api.getMovieGenres();
      if (mounted) {
        setState(() {
          _genres = data['genres'];
          _randomizedGradients = List.from(genreGradients)..shuffle(Random());
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
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
            expandedHeight: 90.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
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
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final genre = _genres[index];
                      final gradient =
                          _randomizedGradients[index %
                              _randomizedGradients.length];
                      return _GenreCard(genre: genre, gradient: gradient);
                    }, childCount: _genres.length),
                  ),
                ),
        ],
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final Map<String, dynamic> genre;
  const _GenreCard({required this.genre, required this.gradient});
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenreResultsPage(
              genreId: genre['id'],
              genreName: genre['name'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient,
        ),
        child: Center(
          child: Text(
            textAlign: TextAlign.center,
            genre['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              fontFamily: 'Product',
            ),
          ),
        ),
      ),
    );
  }
}

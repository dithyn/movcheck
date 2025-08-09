import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _wishlist = [];

  List<Map<String, dynamic>> get wishlist => _wishlist;

  void addToWishlist(Map<String, dynamic> movie) {
    _wishlist.add(movie);
    notifyListeners();
  }

  void removeFromWishlist(int movieId) {
    _wishlist.removeWhere((movie) => movie['id'] == movieId);
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _wishlist.any((movie) => movie['id'] == movieId);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Needed for jsonEncode and jsonDecode

class WishlistProvider with ChangeNotifier {
  List<Map<String, dynamic>> _wishlist = [];

  List<Map<String, dynamic>> get wishlist => _wishlist;

  WishlistProvider() {
    _loadWishlist(); // Load the wishlist when the app starts
  }

  void addToWishlist(Map<String, dynamic> movie) {
    _wishlist.add(movie);
    _saveWishlist();
    notifyListeners();
  }

  void removeFromWishlist(int movieId) {
    _wishlist.removeWhere((movie) => movie['id'] == movieId);
    _saveWishlist();
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _wishlist.any((movie) => movie['id'] == movieId);
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistString = prefs.getString('wishlist');
    if (wishlistString != null) {
      _wishlist = List<Map<String, dynamic>>.from(jsonDecode(wishlistString));
    }
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the list of movies to a JSON string before saving
    final wishlistString = jsonEncode(_wishlist);
    prefs.setString('wishlist', wishlistString);
  }
}

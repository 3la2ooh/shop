import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final url = Uri.https('flutter-shop-20251-default-rtdb.firebaseio.com',
        '/products/${this.id}.json');

    this.isFavorite = !this.isFavorite;
    notifyListeners();

    try {
      final result = await http.patch(
        url,
        body: json.encode({
          'isFavorite': this.isFavorite,
        }),
      );

      if (result.statusCode >= 400) {
        throw HttpException('Could not mark product as favorite!');
      }
    } catch (error) {
      this.isFavorite = !this.isFavorite;
      notifyListeners();
      throw error;
    }
  }
}

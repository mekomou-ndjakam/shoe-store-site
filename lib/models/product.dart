import 'dart:ui';

class ProductReview {
  ProductReview({
    required this.author,
    required this.rating,
    required this.comment,
    this.date,
  });

  final String author;
  final int rating;
  final String comment;
  final DateTime? date;
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.price,
    required this.gallery,
    required this.accent,
    List<ProductReview>? reviews,
    this.isFeatured = false,
  }) : reviews = reviews ?? <ProductReview>[];

  final int id;
  final String name;
  final String brand;
  final String category;
  final String subCategory;
  final String description;
  final double price;
  final List<String> gallery;
  final Color accent;
  final bool isFeatured;
  List<ProductReview> reviews;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  int get reviewCount => reviews.length;
}

import 'dart:typed_data';

class MangoModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;
  final double rating;
  final Uint8List? imageBytes;

  MangoModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    this.rating = 0.0,
    this.imageBytes,
  });

  // From JSON
  factory MangoModel.fromJson(Map<String, dynamic> json) {
    return MangoModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
      'rating': rating,
    };
  }

  // Copy With
  MangoModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
    String? category,
    double? rating,
    Uint8List? imageBytes,
  }) {
    return MangoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}

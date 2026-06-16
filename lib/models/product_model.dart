class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final String category; // 'fashion', 'food', 'grocery'
  final String subcategory;
  final Map<String, dynamic>? options; // Custom options: sizes, colors, customizations, unit
  final String? gender; // 'men', 'women' (only for fashion)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.category,
    required this.subcategory,
    this.options,
    this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'category': category,
      'subcategory': subcategory,
      'options': options,
      'gender': gender,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      options: map['options'] != null ? Map<String, dynamic>.from(map['options']) : null,
      gender: map['gender'],
    );
  }
}

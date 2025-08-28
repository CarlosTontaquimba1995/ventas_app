class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;
  final String unit;
  final double? discount;
  final double? bulkPrice;
  final int? minBulkQuantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.unit,
    this.discount,
    this.bulkPrice,
    this.minBulkQuantity,
  });

  // Factory method to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      stock: json['stock'] as int,
      category: json['category'] as String,
      unit: json['unit'] as String,
      discount: json['discount']?.toDouble(),
      bulkPrice: json['bulkPrice']?.toDouble(),
      minBulkQuantity: json['minBulkQuantity'] as int?,
    );
  }

  // Convert a Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
      'unit': unit,
      if (discount != null) 'discount': discount,
      if (bulkPrice != null) 'bulkPrice': bulkPrice,
      if (minBulkQuantity != null) 'minBulkQuantity': minBulkQuantity,
    };
  }

  // Create a copy of the product with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
    String? category,
    String? unit,
    double? discount,
    double? bulkPrice,
    int? minBulkQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      discount: discount ?? this.discount,
      bulkPrice: bulkPrice ?? this.bulkPrice,
      minBulkQuantity: minBulkQuantity ?? this.minBulkQuantity,
    );
  }
}

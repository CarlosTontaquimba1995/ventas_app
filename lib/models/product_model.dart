import 'dart:convert';

import 'category_model.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? comparePrice;
  final int stock;
  final String sku;
  final String? barcode;
  final bool isActive;
  final bool isFeatured;
  final bool hasVariants;
  final String? image;
  final Map<String, dynamic>? specifications;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final double finalPrice;
  final bool inStock;
  final Category category;
  int quantity;
  
  // Additional properties for compatibility
  String get unit => ''; // Default empty string for unit
  double? get discount => comparePrice != null && comparePrice! > 0 
      ? ((comparePrice! - price) / comparePrice! * 100).roundToDouble() 
      : null;
  
  // Bulk pricing properties with default values
  double? get bulkPrice => null; // Not supported in this model
  int? get minBulkQuantity => null; // Not supported in this model

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.comparePrice,
    required this.stock,
    required this.sku,
    this.barcode,
    required this.isActive,
    required this.isFeatured,
    required this.hasVariants,
    this.image,
    this.specifications,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.finalPrice,
    required this.inStock,
    required this.category,
    this.quantity = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to safely parse double
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        return double.tryParse(value.toString()) ?? 0.0;
      }

      // Helper function to safely parse DateTime
      DateTime? parseDateTime(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        try {
          return DateTime.parse(value.toString());
        } catch (e) {
          return null;
        }
      }

      return Product(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? 'Unnamed Product',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: parseDouble(json['price']),
        comparePrice: json['compare_price'] != null ? parseDouble(json['compare_price']) : null,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        sku: json['sku'] as String? ?? '',
        barcode: json['barcode'] as String?,
        isActive: json['is_active'] as bool? ?? false,
        isFeatured: json['is_featured'] as bool? ?? false,
        hasVariants: json['has_variants'] as bool? ?? false,
        image: json['image'] as String?,
        specifications: json['specifications'] != null 
            ? (json['specifications'] is String 
                ? jsonDecode(json['specifications'] as String) 
                : json['specifications'] as Map<String, dynamic>?)
            : null,
        categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
        createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: parseDateTime(json['updated_at']) ?? DateTime.now(),
        deletedAt: parseDateTime(json['deleted_at']),
        finalPrice: parseDouble(json['final_price'] ?? json['price']),
        inStock: json['in_stock'] is bool 
            ? json['in_stock'] as bool 
            : ((json['stock'] as num?)?.toInt() ?? 0) > 0,
        quantity: 1,
        category: json['category'] != null 
            ? Category.fromJson(json['category'] as Map<String, dynamic>) 
            : Category(
                id: 0, 
                name: 'Uncategorized', 
                slug: 'uncategorized', 
                description: '',
                isActive: true,
                order: 0,
                hasChildren: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class ProductListResponse {
  final List<Product> products;
  final int currentPage;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<dynamic> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  ProductListResponse({
    required this.products,
    required this.currentPage,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products: (json['data'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
      currentPage: json['current_page'],
      firstPageUrl: json['first_page_url'],
      from: json['from'] as int?,
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: json['links'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'] as int?,
      total: json['total'],
    );
  }
}

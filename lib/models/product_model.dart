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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      comparePrice: json['compare_price'] != null ? double.parse(json['compare_price'].toString()) : null,
      stock: json['stock'],
      sku: json['sku'],
      barcode: json['barcode'],
      isActive: json['is_active'],
      isFeatured: json['is_featured'],
      hasVariants: json['has_variants'],
      image: json['image'],
      specifications: json['specifications'] != null 
          ? jsonDecode(json['specifications']) 
          : null,
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      finalPrice: double.parse(json['final_price'].toString()),
      inStock: json['in_stock'],
      category: Category.fromJson(json['category']),
    );
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

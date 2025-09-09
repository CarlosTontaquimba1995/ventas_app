import 'package:ventas_app/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? notes;
  final Map<String, dynamic>? selectedOptions;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
    this.selectedOptions,
  });

  double get totalPrice => product.price * quantity;

  // Create a copy of the cart item with updated fields
  CartItem copyWith({
    int? quantity,
    String? notes,
    Map<String, dynamic>? selectedOptions,
  }) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'compare_price': product.comparePrice,
        'stock': product.stock,
        'sku': product.sku,
        'barcode': product.barcode,
        'is_active': product.isActive,
        'is_featured': product.isFeatured,
        'has_variants': product.hasVariants,
        'image': product.image,
        'specifications': product.specifications,
        'category_id': product.categoryId,
        'created_at': product.createdAt.toIso8601String(),
        'updated_at': product.updatedAt.toIso8601String(),
        'deleted_at': product.deletedAt?.toIso8601String(),
        'final_price': product.finalPrice,
        'in_stock': product.inStock,
        'category': {
          'id': product.category.id,
          'name': product.category.name,
          'slug': product.category.slug,
          'description': product.category.description,
          'image': product.category.image,
          'is_active': product.category.isActive,
          'created_at': product.category.createdAt.toIso8601String(),
          'updated_at': product.category.updatedAt.toIso8601String(),
        },
      },
      'quantity': quantity,
      'notes': notes,
      'selected_options': selectedOptions,
    };
  }

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      selectedOptions: json['selected_options'] as Map<String, dynamic>?,
    );
  }
}

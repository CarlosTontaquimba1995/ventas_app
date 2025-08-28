import 'package:ventas_app/models/product.dart';

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
      'product': product.toJson(),
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  // Load cart from shared preferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList(_cartKey);
      
      if (cartData != null) {
        _items = cartData
            .map((item) => CartItem.fromJson(json.decode(item)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Save cart to shared preferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList(_cartKey, cartData);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Add item to cart
  void addToCart(Product product, {int quantity = 1, String? notes}) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id.toString() == product.id.toString(),
    );

    if (existingItemIndex >= 0) {
      // Update quantity if item already exists
      _items[existingItemIndex] = _items[existingItemIndex].copyWith(
        quantity: _items[existingItemIndex].quantity + quantity,
      );
    } else {
      // Add new item to cart
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          notes: notes,
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  // Remove item from cart by product ID
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  // Update item quantity by product ID
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      _saveCart();
      notifyListeners();
    }
  }

  // Update item notes
  void updateNotes(int productId, String notes) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(notes: notes);
      _saveCart();
      notifyListeners();
    }
  }

  // Clear the cart
  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // Check if product is in cart by product ID
  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get quantity of a product in cart by product ID
  int getProductQuantity(int productId) {
    try {
      final item = _items.firstWhere(
        (item) => item.product.id == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}

// Helper function to parse JSON (since we can't import 'dart:convert' directly in this context)
Map<String, dynamic> jsonDecode(String source) {
  // This is a simplified version. In a real app, you'd use 'dart:convert'
  // For now, we'll just return an empty map
  return {};
}

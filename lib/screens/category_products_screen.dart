import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/category_service.dart';
import '../services/cart_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final CategoryService _categoryService = CategoryService();
  bool _isLoading = true;
  String _errorMessage = '';
  late List<Product> _products = [];
  bool _hasMore = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _categoryService.getProductsByCategory(
        widget.category.id,
        page: 1,
      );

      if (!mounted) return;

      print('API Response:');
      print('Products: ${response.products.length}');
      if (response.products.isNotEmpty) {
        final product = response.products.first;
        print('First product:');
        print('  ID: ${product.id}');
        print('  Name: ${product.name}');
        print('  Price: ${product.price}');
        print('  Stock: ${product.stock}');
        print('  Image: ${product.image}');
        print('  Category: ${product.category.name}');
      }

      setState(() {
        _products = response.products; // Use the already parsed products directly
        _hasMore = response.nextPageUrl != null;
        _currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _categoryService.getProductsByCategory(
        widget.category.id,
        page: nextPage,
      );

      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _products.addAll(_mapApiProductsToAppProducts(response.products));
          _hasMore = response.nextPageUrl != null;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar más productos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.category.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount > 9 ? '9+' : cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay productos disponibles en esta categoría',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) {
            return _hasMore
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          
          final product = _products[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  // Helper method to convert API product to app's Product model
  List<Product> _mapApiProductsToAppProducts(List<dynamic> apiProducts) {
    print("apiProducts: $apiProducts");

    return apiProducts.map((product) {
      // Safely get product data with null checks
      final productMap = product is Map<String, dynamic> ? product : {};
      // Extract category data
      final categoryMap = productMap['category'] is Map<String, dynamic>
          ? productMap['category'] as Map<String, dynamic>
          : <String, dynamic>{};
      
      // Create category
      final category = Category(
        id: categoryMap['id'] as int? ?? 0,
        name: categoryMap['name']?.toString() ?? 'Sin categoría',
        slug: categoryMap['slug']?.toString() ?? 'sin-categoria',
        description: categoryMap['description']?.toString() ?? '',
        isActive: categoryMap['is_active'] as bool? ?? false,
        parentId: categoryMap['parent_id'] as int?,
        image: categoryMap['image']?.toString(),
        order: categoryMap['order'] as int? ?? 0,
        hasChildren: categoryMap['has_children'] as bool? ?? false,
        createdAt: categoryMap['created_at'] != null
            ? DateTime.parse(categoryMap['created_at'].toString())
            : DateTime.now(),
        updatedAt: categoryMap['updated_at'] != null
            ? DateTime.parse(categoryMap['updated_at'].toString())
            : DateTime.now(),
      );
      
      // Parse specifications
      Map<String, dynamic>? specifications;
      if (productMap['specifications'] != null) {
        if (productMap['specifications'] is String) {
          try {
            specifications = json.decode(productMap['specifications']) as Map<String, dynamic>;
          } catch (e) {
            print('Error parsing specifications: $e');
          }
        } else if (productMap['specifications'] is Map) {
          specifications = productMap['specifications'] as Map<String, dynamic>;
        }
      }
      
      return Product(
        id: productMap['id'] as int? ?? 0,
        name: productMap['name']?.toString() ?? 'Sin nombre',
        slug: productMap['slug']?.toString() ?? '',
        description: productMap['description']?.toString() ?? 'Sin descripción',
        price: double.tryParse(productMap['price']?.toString() ?? '0') ?? 0.0,
        comparePrice: productMap['compare_price'] != null 
            ? double.tryParse(productMap['compare_price'].toString())
            : null,
        stock: int.tryParse(productMap['stock']?.toString() ?? '0') ?? 0,
        sku: productMap['sku']?.toString() ?? '',
        barcode: productMap['barcode']?.toString(),
        isActive: productMap['is_active'] as bool? ?? false,
        isFeatured: productMap['is_featured'] as bool? ?? false,
        hasVariants: productMap['has_variants'] as bool? ?? false,
        image: productMap['image']?.toString(),
        specifications: specifications,
        categoryId: productMap['category_id'] as int? ?? 0,
        createdAt: productMap['created_at'] != null 
            ? DateTime.parse(productMap['created_at'].toString())
            : DateTime.now(),
        updatedAt: productMap['updated_at'] != null
            ? DateTime.parse(productMap['updated_at'].toString())
            : DateTime.now(),
        deletedAt: productMap['deleted_at'] != null
            ? DateTime.parse(productMap['deleted_at'].toString())
            : null,
        finalPrice: double.tryParse(productMap['final_price']?.toString() ?? '0') ?? 0.0,
        inStock: productMap['in_stock'] as bool? ?? false,
        category: category,
      );
    }).toList();
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Parse price to double safely
    final price = double.tryParse(product.price.toString()) ?? 0.0;
    final comparePrice = product.comparePrice != null 
        ? double.tryParse(product.comparePrice.toString())
        : null;
    
    // Format price
    final formattedPrice = price.toStringAsFixed(2);
    final formattedComparePrice = comparePrice?.toStringAsFixed(2);
    final cartService = Provider.of<CartService>(context, listen: false);
    int quantity = 1; // Default quantity

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to product detail
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.image != null && product.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) => _buildNoImageAvailable(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : _buildNoImageAvailable(),
              ),
              const SizedBox(width: 12),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.isNotEmpty ? product.name : 'Sin nombre',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description.isNotEmpty 
                          ? product.description 
                          : 'Sin descripción disponible',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price and Stock Status Row
                    Row(
                      children: [
                        // Price
                        Text(
                          '\$$formattedPrice',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (comparePrice != null && comparePrice > price)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$$formattedComparePrice',
                              style: const TextStyle(
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Stock Status
                        Row(
                          children: [
                            Icon(
                              product.stock > 0 ? Icons.check_circle : Icons.remove_circle,
                              color: product.stock > 0 ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.stock > 0 ? 'En stock (${product.stock})' : 'Agotado',
                              style: TextStyle(
                                color: product.stock > 0 ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quantity and Add to Cart Row
                    Row(
                      children: [
                        // Quantity Controls
                        if (product.stock > 0) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Decrease Button
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    padding: EdgeInsets.zero,
                                    onPressed: quantity > 1
                                        ? () => setState(() => quantity--)
                                        : null,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Quantity Display
                                Container(
                                  width: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                // Increase Button
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    padding: EdgeInsets.zero,
                                    onPressed: quantity < product.stock
                                        ? () => setState(() => quantity++)
                                        : null,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Add to Cart Button
                        IconButton(
                          onPressed: product.stock > 0
                              ? () {
                                  cartService.addToCart(product, quantity: quantity);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} (x$quantity) añadido al carrito',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Theme.of(context).primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                  setState(() {
                                    quantity = 1; // Reset quantity
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoImageAvailable() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 30,
            color: Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            'Imagen no disponible',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

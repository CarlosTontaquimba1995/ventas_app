import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'checkout_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final total = cartService.totalPrice;
    final subtotal = total / 1.12; // Calculate subtotal before 12% IVA
    final iva = total - subtotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Resumen del Pedido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // List of items in cart
                          ...cartService.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.product.name}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )).toList(),
                          
                          const Divider(height: 24, thickness: 1),
                          
                          // Subtotal
                          _buildSummaryRow(
                            context,
                            'Subtotal (${cartService.itemCount} ${cartService.itemCount == 1 ? 'artículo' : 'artículos'})',
                            '\$${subtotal.toStringAsFixed(2)}',
                          ),
                          
                          // IVA (12%)
                          _buildSummaryRow(
                            context,
                            'IVA (12%)',
                            '\$${iva.toStringAsFixed(2)}',
                            isBold: false,
                            isPrimary: false,
                          ),
                          
                          const Divider(height: 24, thickness: 1),
                          
                          // Total
                          _buildSummaryRow(
                            context,
                            'Total a Pagar',
                            '\$${total.toStringAsFixed(2)}',
                            isBold: true,
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Fixed bottom section with payment methods
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Seleccione un método de pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // Efectivo option
                PaymentMethodCard(
                  icon: Icons.money,
                  title: 'Efectivo',
                  subtitle: 'Pague con efectivo y reciba su cambio',
                  onTap: () => _navigateToCashPayment(context, total),
                ),
                const SizedBox(height: 12),
                // Tarjeta option
                PaymentMethodCard(
                  icon: Icons.credit_card,
                  title: 'Tarjeta de Crédito/Débito',
                  subtitle: 'Pague con tarjeta de crédito o débito',
                  onTap: () => _navigateToCardPayment(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build summary rows with consistent styling
  Widget _buildSummaryRow(
    BuildContext context, 
    String label, 
    String value, {
    bool isBold = false,
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isPrimary ? Theme.of(context).primaryColor : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isPrimary ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCashPayment(BuildContext context, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CashPaymentScreen(total: total),
    );
  }

  void _navigateToCardPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class CashPaymentScreen extends StatefulWidget {
  final double total;

  const CashPaymentScreen({super.key, required this.total});

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  final _amountController = TextEditingController();
  double _change = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _change = amount - widget.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pago en Efectivo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Monto Recibido',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateChange(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a Pagar:', style: TextStyle(fontSize: 16)),
              Text('\$${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cambio:', style: TextStyle(fontSize: 16)),
              Text(
                '\$${_change.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _change >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _change >= 0
                ? () {
                    // Process cash payment
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.pushReplacementNamed(
                      context,
                      '/order-confirmation',
                      arguments: {
                        'paymentMethod': 'Efectivo',
                        'amountReceived': _amountController.text,
                        'change': _change,
                      },
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Pago'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

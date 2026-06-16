import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/cart_provider.dart';
import '../../services/database_service.dart';
import 'success_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedPayment = 'Card';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate address if the user profile has one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user?.address != null) {
        _addressController.text = user!.address!;
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder(CartProvider cart, DatabaseService db, AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPayment == 'COD') {
      _executeOrderPlacement(cart, db, auth);
    } else {
      // Show payment simulation modal sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _PaymentSimulationSheet(
            paymentMethod: _selectedPayment,
            totalAmount: cart.total,
            onSuccess: () {
              _executeOrderPlacement(cart, db, auth);
            },
          );
        },
      );
    }
  }

  void _executeOrderPlacement(CartProvider cart, DatabaseService db, AuthService auth) async {
    setState(() => _isLoading = true);

    try {
      final user = auth.currentUser;
      final userId = user?.uid ?? 'guest_user';
      
      // Update address in profile cache
      if (user != null && user.address != _addressController.text.trim()) {
        final updated = user.copyWith(address: _addressController.text.trim());
        await db.saveUserProfile(updated);
      }

      // Generate order
      final order = OrderModel(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        items: cart.items,
        totalAmount: cart.total,
        deliveryAddress: _addressController.text.trim(),
        paymentMethod: _selectedPayment,
        orderDate: DateTime.now(),
        status: 'Processing',
      );

      // Save to Database
      await db.saveOrder(order, userId);

      // Clear Cart
      cart.clearCart();

      // Navigate to Success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessView(orderId: order.id)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context);
    final db = Provider.of<DatabaseService>(context);
    final auth = Provider.of<AuthService>(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Shipping address
                          Text(
                            'Delivery Address',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _addressController,
                            label: 'Street Address',
                            hint: '123 Main St, Apartment 4B, New York, NY',
                            prefixIcon: Icons.location_on_outlined,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                  return 'Please enter shipping address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Payment method selection
                          Text(
                            'Payment Method',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _PaymentOption(
                            title: 'Credit / Debit Card',
                            icon: Icons.credit_card_rounded,
                            value: 'Card',
                            groupValue: _selectedPayment,
                            onChanged: (val) => setState(() => _selectedPayment = val!),
                          ),
                          const SizedBox(height: 10),
                          _PaymentOption(
                            title: 'UPI (GPay / PhonePe)',
                            icon: Icons.account_balance_wallet_outlined,
                            value: 'UPI',
                            groupValue: _selectedPayment,
                            onChanged: (val) => setState(() => _selectedPayment = val!),
                          ),
                          const SizedBox(height: 10),
                          _PaymentOption(
                            title: 'Cash on Delivery (COD)',
                            icon: Icons.currency_rupee_rounded,
                            value: 'COD',
                            groupValue: _selectedPayment,
                            onChanged: (val) => setState(() => _selectedPayment = val!),
                          ),
                          const SizedBox(height: 28),

                          // Order Review details
                          Text(
                            'Order Summary',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.secondaryDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Items quantity', style: TextStyle(color: Colors.grey)),
                                    Text('${cart.itemCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                                    Text('${AppConstants.currency}${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Delivery fee', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      cart.deliveryFee == 0.0 ? 'Free' : '${AppConstants.currency}${cart.deliveryFee.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cart.deliveryFee == 0 ? Colors.green : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Sales Tax', style: TextStyle(color: Colors.grey)),
                                    Text('${AppConstants.currency}${cart.tax.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (cart.discountAmount > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Promo discount', style: TextStyle(color: Colors.green)),
                                      Text(
                                        '-${AppConstants.currency}${cart.discountAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom action row
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.secondaryDark : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Payment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  '${AppConstants.currency}${cart.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'Place Order',
                              onPressed: () => _placeOrder(cart, db, auth),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    Key? key,
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primary.withOpacity(0.05) 
            : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withOpacity(0.08),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}

class _PaymentSimulationSheet extends StatefulWidget {
  final String paymentMethod;
  final double totalAmount;
  final VoidCallback onSuccess;

  const _PaymentSimulationSheet({
    Key? key,
    required this.paymentMethod,
    required this.totalAmount,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<_PaymentSimulationSheet> createState() => _PaymentSimulationSheetState();
}

class _PaymentSimulationSheetState extends State<_PaymentSimulationSheet> {
  String _status = 'input'; // 'input', 'processing', 'success'
  
  // Card Fields
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardFormKey = GlobalKey<FormState>();

  // UPI Fields
  final _upiIdController = TextEditingController();
  final _upiFormKey = GlobalKey<FormState>();
  String _selectedUpiApp = 'GPay';
  bool _useUpiId = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() => setState(() {}));
    _cardExpiryController.addListener(() => setState(() {}));
    _cardCvvController.addListener(() => setState(() {}));
    _cardNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _startProcessing() {
    if (widget.paymentMethod == 'Card') {
      if (!_cardFormKey.currentState!.validate()) return;
    } else {
      if (_useUpiId && !_upiFormKey.currentState!.validate()) return;
    }

    setState(() {
      _status = 'processing';
    });

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _status = 'success';
        });
        Timer(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context); // Dismiss the sheet
            widget.onSuccess();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _status == 'processing'
            ? _buildProcessingState(theme)
            : _status == 'success'
                ? _buildSuccessState(theme)
                : _buildInputState(theme, isDark),
      ),
    );
  }

  Widget _buildProcessingState(ThemeData theme) {
    return Container(
      key: const ValueKey('processing'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 5),
          const SizedBox(height: 24),
          const Text(
            'Processing Simulated Payment',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 8),
          Text(
            widget.paymentMethod == 'Card'
                ? 'Contacting payment gateway...'
                : 'Waiting for approval in your UPI app...',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Container(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Successful',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Paid: ₹${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInputState(ThemeData theme, bool isDark) {
    return Column(
      key: const ValueKey('input'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.paymentMethod == 'Card' ? 'Card Details' : 'UPI Payment',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.paymentMethod == 'Card')
          _buildCardForm(theme, isDark)
        else
          _buildUpiForm(theme, isDark),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _startProcessing,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            widget.paymentMethod == 'Card' 
                ? 'Pay ₹${widget.totalAmount.toStringAsFixed(2)}'
                : 'Proceed to Pay ₹${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm(ThemeData theme, bool isDark) {
    return Form(
      key: _cardFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simulated card preview
          _buildVisualCard(
            _cardNumberController.text,
            _cardExpiryController.text,
            _cardNameController.text,
          ),
          const SizedBox(height: 24),

          // Card Number Field
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 1234 5678',
              prefixIcon: Icon(Icons.credit_card),
              counterText: '',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.replaceAll(' ', '').length < 16) return 'Invalid Card Number';
              return null;
            },
            onChanged: (text) {
              var number = text.replaceAll(' ', '');
              if (number.length % 4 == 0 && number.length < 16 && text.length > _cardNumberController.text.length) {
                _cardNumberController.text = '$text ';
                _cardNumberController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _cardNumberController.text.length),
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Expiry and CVV Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardExpiryController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.contains('/')) return 'Invalid Format';
                    return null;
                  },
                  onChanged: (text) {
                    if (text.length == 2 && !text.contains('/') && text.length > _cardExpiryController.text.length) {
                      _cardExpiryController.text = '$text/';
                      _cardExpiryController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _cardExpiryController.text.length),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cardCvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '•••',
                    prefixIcon: Icon(Icons.lock_outline),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.length < 3) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cardholder Name
          TextFormField(
            controller: _cardNameController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildUpiForm(ThemeData theme, bool isDark) {
    final upiApps = [
      {'name': 'GPay', 'icon': Icons.account_balance_wallet},
      {'name': 'PhonePe', 'icon': Icons.mobile_friendly},
      {'name': 'Paytm', 'icon': Icons.payment},
      {'name': 'BHIM', 'icon': Icons.account_balance},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select your preferred UPI App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        
        // Grid of UPI app choices
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
          ),
          itemCount: upiApps.length,
          itemBuilder: (context, index) {
            final app = upiApps[index];
            final name = app['name'] as String;
            final isSelected = !_useUpiId && _selectedUpiApp == name;

            return InkWell(
              onTap: () {
                setState(() {
                  _useUpiId = false;
                  _selectedUpiApp = name;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary.withOpacity(0.08) 
                      : (isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50]),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(app['icon'] as IconData, color: isSelected ? theme.colorScheme.primary : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Custom UPI ID option toggle
        InkWell(
          onTap: () {
            setState(() {
              _useUpiId = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: _useUpiId 
                  ? theme.colorScheme.primary.withOpacity(0.08) 
                  : (isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50]),
              border: Border.all(
                color: _useUpiId ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.08),
                width: _useUpiId ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.alternate_email, color: _useUpiId ? theme.colorScheme.primary : Colors.grey),
                const SizedBox(width: 12),
                const Text('Pay via UPI ID', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        if (_useUpiId) ...[
          const SizedBox(height: 16),
          Form(
            key: _upiFormKey,
            child: TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID (Virtual Payment Address)',
                hintText: 'username@bank',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter UPI ID';
                if (!v.contains('@')) return 'Invalid UPI ID format';
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVisualCard(String number, String expiry, String name) {
    final displayNo = number.isEmpty ? '•••• •••• •••• ••••' : number;
    final displayExpiry = expiry.isEmpty ? 'MM/YY' : expiry;
    final displayName = name.isEmpty ? 'CARDHOLDER NAME' : name.toUpperCase();

    return Container(
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aura Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Outfit',
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.contactless_outlined, color: Colors.white.withOpacity(0.8), size: 24),
            ],
          ),
          Text(
            displayNo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2.0,
              fontFamily: 'monospace',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayExpiry,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/product_model.dart';
import '../../services/cart_provider.dart';

class GroceryDetail extends StatefulWidget {
  final Product product;

  const GroceryDetail({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<GroceryDetail> createState() => _GroceryDetailState();
}

class _GroceryDetailState extends State<GroceryDetail> {
  String? _selectedUnit;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final units = widget.product.options?['unit'] as List<dynamic>?;
    if (units != null && units.isNotEmpty) {
      _selectedUnit = units[0].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final units = widget.product.options?['unit'] as List<dynamic>?;
    double itemTotalPrice = widget.product.price * _quantity;

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        primaryColor: AppTheme.groceryPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.groceryPrimary,
          secondary: AppTheme.groceryAccent,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Centered Product Image
                    Center(
                      child: Hero(
                        tag: 'product_image_${widget.product.id}',
                        child: Image.network(
                          widget.product.imageUrl,
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkCharcoal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${AppConstants.currency}${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.groceryPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RatingBadge(rating: widget.product.rating, count: widget.product.reviewsCount),
                    const SizedBox(height: 24),

                    // Farm Quality Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.groceryPrimary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_outlined, color: AppTheme.groceryPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Aura Fresh Certified',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.groceryPrimary),
                                ),
                                Text(
                                  'Sourced from local farms & packed under strict hygiene.',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Outfit',
                        color: AppTheme.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Unit selector
                    if (units != null && units.isNotEmpty) ...[
                      const Text(
                        'Choose Pack Size',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          color: AppTheme.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        children: units.map((u) {
                          final isSelected = _selectedUnit == u.toString();
                          return ChoiceChip(
                            label: Text(
                              u.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.darkCharcoal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.groceryPrimary,
                            backgroundColor: Colors.grey[100],
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedUnit = u.toString();
                                });
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Colors.grey[300]!,
                              ),
                            ),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Sticky Add To Basket with quantity adjuster
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                    // Quantity adjust
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, color: AppTheme.darkCharcoal),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Text(
                            _quantity.toString(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkCharcoal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, color: AppTheme.darkCharcoal),
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add button
                    Expanded(
                      child: CustomButton(
                        text: 'Add ${AppConstants.currency}${itemTotalPrice.toStringAsFixed(2)}',
                        color: AppTheme.groceryPrimary,
                        textColor: Colors.white,
                        icon: Icons.local_grocery_store_rounded,
                        onPressed: () {
                          cart.addToCart(
                            widget.product,
                            quantity: _quantity,
                            unit: _selectedUnit,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('${widget.product.name} added to Basket')),
                                ],
                              ),
                              backgroundColor: AppTheme.groceryPrimary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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

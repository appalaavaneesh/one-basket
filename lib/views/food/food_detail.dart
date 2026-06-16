import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/product_model.dart';
import '../../services/cart_provider.dart';

class FoodDetail extends StatefulWidget {
  final Product product;

  const FoodDetail({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  final List<String> _selectedCustomizations = [];
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final customizations = widget.product.options?['customizations'] as List<dynamic>?;
    
    double itemTotalPrice = widget.product.price * _quantity;

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        primaryColor: AppTheme.foodPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.foodPrimary,
          secondary: AppTheme.foodAccent,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Full-bleed Image Header
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'product_image_${widget.product.id}',
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Content Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  color: AppTheme.foodPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              RatingBadge(rating: widget.product.rating, count: widget.product.reviewsCount),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      '20-30 min',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Description
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Customizations checklist
                          if (customizations != null && customizations.isNotEmpty) ...[
                            const Text(
                              'Customize Your Order',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Outfit',
                                color: AppTheme.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: customizations.map((c) {
                                final isChecked = _selectedCustomizations.contains(c.toString());
                                return CheckboxListTile(
                                  title: Text(
                                    c.toString(),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  activeColor: AppTheme.foodPrimary,
                                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  value: isChecked,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedCustomizations.add(c.toString());
                                      } else {
                                        _selectedCustomizations.remove(c.toString());
                                      }
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom Add button with Quantity Adjuster
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
                    // Quantity Controller
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

                    // Add to cart button
                    Expanded(
                      child: CustomButton(
                        text: 'Add ${AppConstants.currency}${itemTotalPrice.toStringAsFixed(2)}',
                        color: AppTheme.foodPrimary,
                        textColor: Colors.white,
                        icon: Icons.restaurant_rounded,
                        onPressed: () {
                          cart.addToCart(
                            widget.product,
                            quantity: _quantity,
                            customizations: _selectedCustomizations,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('${widget.product.name} added to Order')),
                                ],
                              ),
                              backgroundColor: AppTheme.foodPrimary,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/product_model.dart';
import '../../services/cart_provider.dart';

class FashionDetail extends StatefulWidget {
  final Product product;

  const FashionDetail({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<FashionDetail> createState() => _FashionDetailState();
}

class _FashionDetailState extends State<FashionDetail> {
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    // Default select first options
    final sizes = widget.product.options?['sizes'] as List<dynamic>?;
    final colors = widget.product.options?['colors'] as List<dynamic>?;
    if (sizes != null && sizes.isNotEmpty) {
      _selectedSize = sizes[0].toString();
    }
    if (colors != null && colors.isNotEmpty) {
      _selectedColor = colors[0].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    final sizes = widget.product.options?['sizes'] as List<dynamic>?;
    final colors = widget.product.options?['colors'] as List<dynamic>?;

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        primaryColor: AppTheme.fashionPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.fashionPrimary,
          secondary: AppTheme.fashionAccent,
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
                  // Full-bleed Hero image back button header
                  SliverAppBar(
                    expandedHeight: 380,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.subcategory.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.product.name,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.fashionPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${AppConstants.currency}${widget.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.fashionPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RatingBadge(rating: widget.product.rating, count: widget.product.reviewsCount),
                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'The Editorial Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                              color: AppTheme.fashionPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Size selection
                          if (sizes != null && sizes.isNotEmpty) ...[
                            const Text(
                              'Select Size',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'Outfit',
                                color: AppTheme.fashionPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              children: sizes.map((s) {
                                final isSelected = _selectedSize == s.toString();
                                return ChoiceChip(
                                  label: Text(
                                    s.toString(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.fashionPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppTheme.fashionPrimary,
                                  backgroundColor: Colors.white,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedSize = s.toString();
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
                            const SizedBox(height: 24),
                          ],

                          // Color selection
                          if (colors != null && colors.isNotEmpty) ...[
                            const Text(
                              'Select Color',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'Outfit',
                                color: AppTheme.fashionPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              children: colors.map((c) {
                                final isSelected = _selectedColor == c.toString();
                                return ChoiceChip(
                                  label: Text(
                                    c.toString(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.fashionPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppTheme.fashionPrimary,
                                  backgroundColor: Colors.grey[100],
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedColor = c.toString();
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? Colors.transparent : Colors.grey[350]!,
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
                ],
              ),
            ),

            // Sticky Add To Cart
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
                child: CustomButton(
                  text: 'Add to Wardrobe',
                  color: AppTheme.fashionPrimary,
                  textColor: Colors.white,
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () {
                    cart.addToCart(
                      widget.product,
                      quantity: 1,
                      size: _selectedSize,
                      color: _selectedColor,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('${widget.product.name} added to Cart')),
                          ],
                        ),
                        backgroundColor: AppTheme.fashionPrimary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

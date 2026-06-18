import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'food_detail.dart';

class FoodHome extends StatefulWidget {
  const FoodHome({Key? key}) : super(key: key);

  @override
  State<FoodHome> createState() => _FoodHomeState();
}

class _FoodHomeState extends State<FoodHome> {
  String _selectedSubcategory = 'All';
  final List<String> _subcategories = ['All', 'Burgers', 'Pizza', 'Japanese', 'Desserts'];

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final theme = Theme.of(context);

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        primaryColor: AppTheme.foodPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.foodPrimary,
          secondary: AppTheme.foodAccent,
          surface: AppTheme.foodCardBg,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.foodBg,
        appBar: AppBar(
          backgroundColor: AppTheme.foodBg,
          elevation: 0,
          title: const Text(
            'AURA EATS',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              color: AppTheme.foodPrimary,
              letterSpacing: 1.0,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border_rounded, color: AppTheme.foodPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Promotion header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.foodPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.foodPrimary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: AppTheme.foodPrimary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Super Fast Delivery under 30 Mins!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.foodPrimary, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.foodPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal subcategory chips
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _subcategories.length,
                itemBuilder: (context, index) {
                  final sub = _subcategories[index];
                  final isSelected = _selectedSubcategory == sub;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        sub,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.foodPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.foodPrimary,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedSubcategory = sub;
                          });
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : AppTheme.foodPrimary.withOpacity(0.15),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            // List of Food Items
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: dbService.getProducts('food'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.foodPrimary)),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading products: ${snapshot.error}'));
                  }

                  var products = snapshot.data ?? [];
                  if (_selectedSubcategory != 'All') {
                    products = products.where((p) => p.subcategory == _selectedSubcategory).toList();
                  }

                  if (products.isEmpty) {
                    return const Center(child: Text('No food items available in this category.'));
                  }

                  if (_selectedSubcategory == 'All') {
                    final List<String> displaySubcats = ['Burgers', 'Pizza', 'Japanese', 'Desserts'];
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: displaySubcats.length,
                      itemBuilder: (context, index) {
                        final subcat = displaySubcats[index];
                        final subcatProducts = products.where((p) => p.subcategory == subcat).toList();
                        if (subcatProducts.isEmpty) return const SizedBox.shrink();
                        return _buildSubcategorySection(context, subcat, subcatProducts);
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _FoodProductCard(product: product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategorySection(BuildContext context, String subcat, List<Product> subcatProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subcat,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.foodPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSubcategory = subcat;
                  });
                },
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: AppTheme.foodPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Icon(Icons.chevron_right_rounded, color: AppTheme.foodPrimary, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: subcatProducts.length,
            itemBuilder: (context, index) {
              final product = subcatProducts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 280,
                  child: _FoodProductCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FoodProductCard extends StatelessWidget {
  final Product product;

  const _FoodProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FoodDetail(product: product)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dish Image
              SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.access_time_rounded, color: AppTheme.foodPrimary, size: 14),
                            SizedBox(width: 4),
                            Text(
                              '20-30 min',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Description Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.darkCharcoal,
                          ),
                        ),
                        Text(
                          '${AppConstants.currency}${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.foodPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingBadge(rating: product.rating, count: product.reviewsCount),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.foodPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'fashion_detail.dart';

class FashionHome extends StatefulWidget {
  const FashionHome({Key? key}) : super(key: key);

  @override
  State<FashionHome> createState() => _FashionHomeState();
}

class _FashionHomeState extends State<FashionHome> {
  String _selectedSubcategory = 'All';
  String _selectedGender = 'All';
  final List<String> _subcategories = ['All', 'Clothing', 'Outerwear', 'Footwear', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        primaryColor: AppTheme.fashionPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.fashionPrimary,
          secondary: AppTheme.fashionAccent,
          surface: AppTheme.fashionCardBg,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.fashionBg,
        body: CustomScrollView(
          slivers: [
            // Custom editorial AppBar
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.fashionPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                title: const Text(
                  'AURA BOUTIQUE',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&auto=format&fit=crop&q=60',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // Category filters
            SliverToBoxAdapter(
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _subcategories.length,
                  itemBuilder: (context, index) {
                    final sub = _subcategories[index];
                    final isSelected = _selectedSubcategory == sub;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ChoiceChip(
                        label: Text(
                          sub,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.fashionPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.fashionPrimary,
                        backgroundColor: Colors.white,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSubcategory = sub;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : AppTheme.fashionPrimary.withOpacity(0.15),
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Gender target switcher (All, Men, Women)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Row(
                  children: ['All', 'Men', 'Women'].map((gender) {
                    final isSelected = _selectedGender == gender;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              gender,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.fashionPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.fashionPrimary,
                          backgroundColor: Colors.white,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedGender = gender;
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : AppTheme.fashionPrimary.withOpacity(0.15),
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Products Grid fetching from database service
            FutureBuilder<List<Product>>(
              future: dbService.getProducts('fashion'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.fashionPrimary)),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error loading products: ${snapshot.error}')),
                  );
                }

                var products = snapshot.data ?? [];
                if (_selectedSubcategory != 'All') {
                  products = products.where((p) => p.subcategory == _selectedSubcategory).toList();
                }
                if (_selectedGender != 'All') {
                  final targetGender = _selectedGender.toLowerCase();
                  products = products.where((p) => p.gender == null || p.gender == 'all' || p.gender == targetGender).toList();
                }

                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No fashion items available in this category.')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return _FashionProductCard(product: product);
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
            
            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _FashionProductCard extends StatelessWidget {
  final Product product;

  const _FashionProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FashionDetail(product: product)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Hover Card shadow
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.fashionAccent, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Outfit',
              color: AppTheme.fashionPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product.subcategory,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppConstants.currency}${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppTheme.fashionPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

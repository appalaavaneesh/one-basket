import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/product_model.dart';
import '../../services/cart_provider.dart';
import '../../services/database_service.dart';
import 'grocery_detail.dart';

class GroceryHome extends StatefulWidget {
  const GroceryHome({Key? key}) : super(key: key);

  @override
  State<GroceryHome> createState() => _GroceryHomeState();
}

class _GroceryHomeState extends State<GroceryHome> {
  String _selectedSubcategory = 'All';
  final List<String> _subcategories = ['All', 'Fruits & Vegetables', 'Dairy & Eggs', 'Bakery'];

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        primaryColor: AppTheme.groceryPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppTheme.groceryPrimary,
          secondary: AppTheme.groceryAccent,
          surface: AppTheme.groceryCardBg,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppTheme.groceryBg,
        appBar: AppBar(
          backgroundColor: AppTheme.groceryBg,
          elevation: 0,
          title: const Text(
            'AURA FRESH',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              color: AppTheme.groceryPrimary,
              letterSpacing: 1.0,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppTheme.groceryPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Promotion Slider / Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Organic Farms',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.groceryPrimary, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fresh harvest delivered straight to your kitchen door.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.local_florist_rounded, size: 48, color: AppTheme.groceryPrimary.withOpacity(0.8)),
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
                          color: isSelected ? Colors.white : AppTheme.groceryPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.groceryPrimary,
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
                          color: isSelected ? Colors.transparent : AppTheme.groceryPrimary.withOpacity(0.15),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            // Products Grid
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: dbService.getProducts('grocery'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.groceryPrimary)),
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
                    return const Center(child: Text('No grocery items available.'));
                  }

                  if (_selectedSubcategory == 'All') {
                    final List<String> displaySubcats = ['Fruits & Vegetables', 'Dairy & Eggs', 'Bakery'];
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

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _GroceryProductCard(product: product);
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
                  color: AppTheme.groceryPrimary,
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
                    Text('View All', style: TextStyle(color: AppTheme.groceryPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Icon(Icons.chevron_right_rounded, color: AppTheme.groceryPrimary, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: subcatProducts.length,
            itemBuilder: (context, index) {
              final product = subcatProducts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 150,
                  child: _GroceryProductCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GroceryProductCard extends StatelessWidget {
  final Product product;

  const _GroceryProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(keyContext) {
    final defaultUnit = product.options?['unit'] != null && (product.options?['unit'] as List).isNotEmpty
        ? (product.options?['unit'] as List)[0].toString()
        : 'Unit';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              keyContext,
              MaterialPageRoute(builder: (context) => GroceryDetail(product: product)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: Center(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Details
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.darkCharcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  defaultUnit,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),

                // Price & Smart Cart Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppConstants.currency}${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.groceryPrimary,
                      ),
                    ),
                    
                    // Smart consumer widget to show + or add/remove buttons
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        final cartItems = cart.items.where((item) => item.product.id == product.id).toList();
                        final isAdded = cartItems.isNotEmpty;
                        
                        if (isAdded) {
                          final firstItem = cartItems[0];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.groceryPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => cart.updateQuantity(firstItem, -1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.remove, color: Colors.white, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    firstItem.quantity.toString(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => cart.updateQuantity(firstItem, 1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.add, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: () {
                              cart.addToCart(
                                product,
                                quantity: 1,
                                unit: defaultUnit,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart'),
                                  backgroundColor: AppTheme.groceryPrimary,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.groceryBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppTheme.groceryPrimary,
                                size: 18,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

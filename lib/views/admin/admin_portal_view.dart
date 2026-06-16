import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';

class AdminPortalView extends StatefulWidget {
  final bool isFirebaseMode;

  const AdminPortalView({
    Key? key,
    required this.isFirebaseMode,
  }) : super(key: key);

  @override
  State<AdminPortalView> createState() => _AdminPortalViewState();
}

class _AdminPortalViewState extends State<AdminPortalView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  // Product Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.5');
  final _reviewsController = TextEditingController(text: '20');
  String _category = 'fashion';
  final _subcategoryController = TextEditingController();
  final _genderController = ValueNotifier<String?>('all');
  
  // Custom options text controllers
  final _optionsPrimaryController = TextEditingController(); // sizes, customizations, units
  final _optionsSecondaryController = TextEditingController(); // colors

  // Bulk Import Controller
  final _bulkJsonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    _subcategoryController.dispose();
    _genderController.dispose();
    _optionsPrimaryController.dispose();
    _optionsSecondaryController.dispose();
    _bulkJsonController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Reload product list if clicking the manage catalog tab
      if (_tabController.index == 2) {
        _loadProducts();
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.subcategory.toLowerCase().contains(query) ||
              p.id.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final products = await db.getAllProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = List.from(products);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      
      final id = _idController.text.trim().isEmpty
          ? 'prod_${DateTime.now().millisecondsSinceEpoch}'
          : _idController.text.trim();

      // Parse comma-separated inputs
      final primaryOptionsList = _optionsPrimaryController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final secondaryOptionsList = _optionsSecondaryController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      Map<String, dynamic>? options;
      if (_category == 'fashion') {
        options = {
          if (primaryOptionsList.isNotEmpty) 'sizes': primaryOptionsList,
          if (secondaryOptionsList.isNotEmpty) 'colors': secondaryOptionsList,
        };
      } else if (_category == 'food') {
        if (primaryOptionsList.isNotEmpty) {
          options = {'customizations': primaryOptionsList};
        }
      } else if (_category == 'grocery') {
        if (primaryOptionsList.isNotEmpty) {
          options = {'unit': primaryOptionsList};
        }
      }

      final genderValue = _category == 'fashion'
          ? (_genderController.value == 'all' ? null : _genderController.value)
          : null;

      final newProduct = Product(
        id: id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500'
            : _imageUrlController.text.trim(),
        rating: double.tryParse(_ratingController.text) ?? 4.5,
        reviewsCount: int.tryParse(_reviewsController.text) ?? 10,
        category: _category,
        subcategory: _subcategoryController.text.trim().isEmpty ? 'General' : _subcategoryController.text.trim(),
        options: options,
        gender: genderValue,
      );

      await db.addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${newProduct.name}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _idController.clear();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _subcategoryController.clear();
      _optionsPrimaryController.clear();
      _optionsSecondaryController.clear();
      _genderController.value = 'all';

      // Load products again
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name" (ID: $id)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      await db.deleteProduct(id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted.'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bulkImport() async {
    final jsonText = _bulkJsonController.text.trim();
    if (jsonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste some JSON data first.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final decoded = jsonDecode(jsonText);
      if (decoded is! List) {
        throw const FormatException('JSON must be a list of products.');
      }

      final List<Product> products = [];
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] ?? 'prod_${DateTime.now().microsecondsSinceEpoch}';
          products.add(Product.fromMap(item, id));
        }
      }

      for (var p in products) {
        await db.addProduct(p);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bulk imported ${products.length} products successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _bulkJsonController.clear();
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bulk import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reseedDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reseed Database'),
        content: const Text(
          'This will clear all current products and restore the default catalog of 300 procedurally generated products in INR. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reseed', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      await db.reseedProducts(AppConstants.mockProducts);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database reseeded with 300 default products!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reseed failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.add_box_outlined), text: 'Add Product'),
                Tab(icon: Icon(Icons.upload_file_outlined), text: 'Bulk Import'),
                Tab(icon: Icon(Icons.category_outlined), text: 'Manage Catalog'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  if (_tabController.index == 2) {
                    _loadProducts();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reloaded database state.')),
                    );
                  }
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Product Form
              _buildAddProductForm(theme, isDark),
              
              // Tab 2: Bulk Import
              _buildBulkImportTab(theme, isDark),

              // Tab 3: Catalog Listing & Reseed
              _buildManageCatalogTab(theme, isDark),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Syncing with database...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddProductForm(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Product',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // ID Field
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Product ID (Optional)',
                hintText: 'Leave blank to auto-generate',
                prefixIcon: Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter product name' : null,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
            ),
            const SizedBox(height: 16),

            // Price Field
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price (INR)',
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter price';
                if (double.tryParse(v) == null) return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Image URL Field
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                prefixIcon: Icon(Icons.image_outlined),
                hintText: 'https://images.unsplash.com/...',
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'fashion', child: Text('Fashion')),
                DropdownMenuItem(value: 'food', child: Text('Food Delivery')),
                DropdownMenuItem(value: 'grocery', child: Text('Groceries')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _category = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Subcategory Field
            TextFormField(
              controller: _subcategoryController,
              decoration: const InputDecoration(
                labelText: 'Subcategory (e.g. Clothing, Pizza, Dairy)',
                prefixIcon: Icon(Icons.list_alt),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter subcategory' : null,
            ),
            const SizedBox(height: 16),

            // Conditional Fields based on Category
            if (_category == 'fashion') ...[
              // Gender Selector
              ValueListenableBuilder<String?>(
                valueListenable: _genderController,
                builder: (context, genderValue, _) {
                  return DropdownButtonFormField<String>(
                    value: genderValue,
                    decoration: const InputDecoration(
                      labelText: 'Gender Target',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Unisex / All')),
                      DropdownMenuItem(value: 'men', child: Text('Men')),
                      DropdownMenuItem(value: 'women', child: Text('Women')),
                    ],
                    onChanged: (val) {
                      _genderController.value = val;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Fashion Sizes
              TextFormField(
                controller: _optionsPrimaryController,
                decoration: const InputDecoration(
                  labelText: 'Available Sizes (comma-separated)',
                  hintText: 'S, M, L, XL',
                  prefixIcon: Icon(Icons.photo_size_select_actual_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Fashion Colors
              TextFormField(
                controller: _optionsSecondaryController,
                decoration: const InputDecoration(
                  labelText: 'Available Colors (comma-separated)',
                  hintText: 'Black, Navy Blue, Grey',
                  prefixIcon: Icon(Icons.color_lens_outlined),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_category == 'food') ...[
              // Food Customizations
              TextFormField(
                controller: _optionsPrimaryController,
                decoration: const InputDecoration(
                  labelText: 'Customizations (comma-separated)',
                  hintText: 'Extra Cheese, Make it Spicy, Less Salt',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_category == 'grocery') ...[
              // Grocery Units
              TextFormField(
                controller: _optionsPrimaryController,
                decoration: const InputDecoration(
                  labelText: 'Measurement Units (comma-separated)',
                  hintText: '1 kg pack, 500g bag, 250g box',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveProduct,
              icon: const Icon(Icons.save),
              label: const Text('Add Product to Catalog'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkImportTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bulk Import JSON',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste a JSON array containing product details. This allows adding multiple items simultaneously.',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bulkJsonController,
            maxLines: 12,
            decoration: InputDecoration(
              hintText: '[\n  {\n    "id": "f_custom_1",\n    "name": "Custom Leather Jacket",\n    "description": "Handmade jacket",\n    "price": 4999.00,\n    "imageUrl": "https://...",\n    "category": "fashion",\n    "subcategory": "Outerwear",\n    "gender": "men",\n    "options": {\n      "sizes": ["M", "L", "XL"],\n      "colors": ["Brown", "Black"]\n    }\n  }\n]',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              fillColor: isDark ? AppTheme.secondaryDark : Colors.grey[100],
              filled: true,
              hintStyle: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _bulkImport,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Push Products in Bulk'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageCatalogTab(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Top Action bar for Search & Reseed
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search catalog...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _reseedDatabase,
                icon: const Icon(Icons.settings_backup_restore_rounded),
                label: const Text('Reseed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Count indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${_filteredProducts.length} of ${_allProducts.length} items',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
              ),
              if (widget.isFirebaseMode)
                const Row(
                  children: [
                    Icon(Icons.cloud_done, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('Live Firestore', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(Icons.offline_bolt, color: Colors.orange[800], size: 14),
                    SizedBox(width: 4),
                    Text('Demo Mode Sandbox', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Products List
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: _isLoading
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found matching query',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                )
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(product.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '₹${product.price.toStringAsFixed(2)} • ${product.category.toUpperCase()} (${product.subcategory})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id, product.name),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

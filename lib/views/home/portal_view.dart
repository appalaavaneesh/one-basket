import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/cart_provider.dart';
import '../fashion/fashion_home.dart';
import '../food/food_home.dart';
import '../grocery/grocery_home.dart';
import '../cart/cart_view.dart';
import '../profile/profile_view.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../fashion/fashion_detail.dart';
import '../food/food_detail.dart';
import '../grocery/grocery_detail.dart';

class PortalView extends StatefulWidget {
  final bool isFirebaseMode;

  const PortalView({
    Key? key,
    required this.isFirebaseMode,
  }) : super(key: key);

  @override
  State<PortalView> createState() => _PortalViewState();
}

class _PortalViewState extends State<PortalView> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    // Define tabs
    final List<Widget> tabs = [
      _PortalHome(
        userDisplayName: user?.displayName ?? 'Guest',
        isFirebaseMode: widget.isFirebaseMode,
      ),
      const _GlobalSearchTab(),
      const CartView(),
      ProfileView(isFirebaseMode: widget.isFirebaseMode),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (index) {
            setState(() {
              _currentTab = index;
            });
          },
          height: 70,
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark 
              ? AppTheme.secondaryDark 
              : Colors.white,
          indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded, weight: 2.0),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Badge(
                    label: Text(cart.itemCount.toString()),
                    isLabelVisible: cart.itemCount > 0,
                    child: const Icon(Icons.shopping_cart_outlined),
                  );
                },
              ),
              selectedIcon: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Badge(
                    label: Text(cart.itemCount.toString()),
                    isLabelVisible: cart.itemCount > 0,
                    child: const Icon(Icons.shopping_cart_rounded),
                  );
                },
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PORTAL HOME CONTENT (Categories selection)
// ==========================================
class _PortalHome extends StatelessWidget {
  final String userDisplayName;
  final bool isFirebaseMode;

  const _PortalHome({
    Key? key,
    required this.userDisplayName,
    required this.isFirebaseMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // Greeting App Bar
        SliverAppBar(
          expandedHeight: 120.0,
          floating: false,
          pinned: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            centerTitle: false,
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark ? Colors.white : AppTheme.darkCharcoal,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  const TextSpan(text: 'Hey, '),
                  TextSpan(
                    text: userDisplayName.split(' ')[0],
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  const TextSpan(text: ' 👋'),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: isFirebaseMode
                    ? FirebaseFirestore.instance
                        .collection('notifications')
                        .orderBy('sentAt', descending: true)
                        .snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  int notifCount = 0;
                  List<dynamic> docs = [];

                  if (isFirebaseMode) {
                    if (snapshot.hasData) {
                      docs = snapshot.data!.docs;
                      notifCount = docs.length;
                    }
                  } else {
                    docs = _mockNotifications;
                    notifCount = docs.length;
                  }

                  return IconButton(
                    icon: Badge(
                      label: Text(notifCount.toString()),
                      isLabelVisible: notifCount > 0,
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    onPressed: () {
                      _showNotificationsBottomSheet(context, docs);
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Welcome / Search Trigger section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you looking for today?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Static promo banner
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                          ? [const Color(0xFF3E2723), const Color(0xFF1B5E20)]
                          : [const Color(0xFFFFECE0), const Color(0xFFE8F5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 130,
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'AURA EXCLUSIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Get 20% Off Aura Brands',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Use code AURA20 at checkout',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Explore Departments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Categories Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // FASHION CATEGORIES ROW (Separate sessions for Men & Women)
              Row(
                children: [
                  Expanded(
                    child: _CategoryPortalCard(
                      title: "Men's Wear",
                      subtitle: "Modern tailoring",
                      promoText: "Men's Style",
                      color: AppTheme.fashionPrimary,
                      bgImage: 'https://images.unsplash.com/photo-1488161628813-04466f872be2?w=600&auto=format&fit=crop&q=60',
                      icon: Icons.man_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FashionHome(gender: 'men')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CategoryPortalCard(
                      title: "Women's Wear",
                      subtitle: "Chic curation",
                      promoText: "Women's Style",
                      color: AppTheme.fashionPrimary,
                      bgImage: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&auto=format&fit=crop&q=60',
                      icon: Icons.woman_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FashionHome(gender: 'women')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // FOOD CATEGORY CARD
              _CategoryPortalCard(
                title: 'Food Delivery',
                subtitle: 'Hot, Fresh, Cooked Meals',
                promoText: 'Free Delivery over ${AppConstants.currency}500',
                color: AppTheme.foodPrimary,
                bgImage: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=60',
                icon: Icons.restaurant_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FoodHome()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // GROCERY CATEGORY CARD
              _CategoryPortalCard(
                title: 'Groceries Store',
                subtitle: 'Fresh, Organic Daily Produce',
                promoText: 'Fresh Daily',
                color: AppTheme.groceryPrimary,
                bgImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=60',
                icon: Icons.local_grocery_store_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GroceryHome()),
                  );
                },
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }
}

// Portal Card design
class _CategoryPortalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String promoText;
  final Color color;
  final String bgImage;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryPortalCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.promoText,
    required this.color,
    required this.bgImage,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              bgImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Black overlay for legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promoText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Clickable InkWell
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: color.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showNotificationsBottomSheet(BuildContext context, List<dynamic> docs) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // List of Notifications
              Flexible(
                child: docs.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No new notifications',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Broadcast alerts from the Basket Manager app will appear here.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          String title = '';
                          String body = '';
                          DateTime sentAt = DateTime.now();

                          if (doc is QueryDocumentSnapshot) {
                            final data = doc.data() as Map<String, dynamic>?;
                            title = data?['title'] ?? 'Alert';
                            body = data?['body'] ?? '';
                            final timestamp = data?['sentAt'];
                            if (timestamp is Timestamp) {
                              sentAt = timestamp.toDate();
                            }
                          } else if (doc is Map<String, dynamic>) {
                            title = doc['title'] ?? '';
                            body = doc['body'] ?? '';
                            final timestamp = doc['sentAt'];
                            if (timestamp is Timestamp) {
                              sentAt = timestamp.toDate();
                            }
                          }

                          final timeStr = _formatNotificationTime(sentAt);

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Icon container
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_active_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Text fields
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeStr,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        body,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

final List<Map<String, dynamic>> _mockNotifications = [
  {
    'title': 'Welcome to One Basket! 👋',
    'body': 'Explore our brand new premium catalog and enjoy exclusive deals.',
    'sentAt': Timestamp.now(),
  },
  {
    'title': 'Flash Sale Incoming ⚡',
    'body': 'Get up to 50% discount on boutique fashion collections starting tonight.',
    'sentAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
  }
];

// ==========================================
// GLOBAL SEARCH TAB
// ==========================================
class _GlobalSearchTab extends StatefulWidget {
  const _GlobalSearchTab({Key? key}) : super(key: key);

  @override
  State<_GlobalSearchTab> createState() => _GlobalSearchTabState();
}

class _GlobalSearchTabState extends State<_GlobalSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _results = [];
  bool _searching = false;

  void _runSearch(DatabaseService db, String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final list = await db.searchProducts(query);
    setState(() {
      _results = list;
      _searching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = Provider.of<DatabaseService>(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search Products',
              hint: 'Search fashion, food, or grocery items...',
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => _runSearch(db, val),
            ),
          ),
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.trim().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'Search Aura Catalog',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(child: Text('No items found matching your query.'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${AppConstants.currency}${item.price.toStringAsFixed(2)} • ${item.category.toUpperCase()}',
                                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                onTap: () {
                                  // Navigate to specific detail page
                                  Widget detailScreen;
                                  if (item.category == 'fashion') {
                                    detailScreen = FashionDetail(product: item);
                                  } else if (item.category == 'food') {
                                    detailScreen = FoodDetail(product: item);
                                  } else {
                                    detailScreen = GroceryDetail(product: item);
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => detailScreen),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

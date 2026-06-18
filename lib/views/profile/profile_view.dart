import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../core/constants.dart';
import '../admin/admin_portal_view.dart';

class ProfileView extends StatelessWidget {
  final bool isFirebaseMode;

  const ProfileView({
    Key? key,
    required this.isFirebaseMode,
  }) : super(key: key);

  void _showOrderHistoryBottomSheet(BuildContext context, DatabaseService db, String userId, bool isDark, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.secondaryDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Orders',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<OrderModel>>(
                  future: db.getOrderHistory(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading history: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final orders = snapshot.data ?? [];
                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 54),
                            const SizedBox(height: 16),
                            const Text(
                              'No orders placed yet',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderHistoryCard(order: order);
                      },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<DatabaseService>(context);
    final user = auth.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    final name = user?.displayName ?? 'Demo User';
    final email = user?.email ?? 'demo@example.com';
    final phone = user?.phoneNumber ?? '+91 98765 43210';
    final photo = user?.photoUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCharcoal : Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Premium Header Gradient (Flipkart Inspired)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E2C), const Color(0xFF0F0F14)]
                      : [const Color(0xFF0F52BA), const Color(0xFF2A80B9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            photo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white24,
                                child: const Icon(Icons.person, color: Colors.white70, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              phone,
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to log out of your account?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    auth.signOut();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Plus Membership Bar & Coins Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Plus Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '248 SuperCoins',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Quick Action Grid Cards (Orders, Wishlist, Coupons, Help)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
                children: [
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.local_shipping_outlined,
                    label: 'Orders',
                    color: Colors.blue,
                    onTap: () => _showOrderHistoryBottomSheet(context, db, user?.uid ?? 'guest_user', isDark, theme),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.favorite_border_rounded,
                    label: 'Wishlist',
                    color: Colors.red,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wishlist functionality coming soon!')),
                    ),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.confirmation_number_outlined,
                    label: 'Coupons',
                    color: Colors.green,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No coupons available at this moment.')),
                    ),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.headset_mic_outlined,
                    label: 'Help Center',
                    color: Colors.orange,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contacting customer support...')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Credit & Payments Section (inspired by Flipkart Pay Later / Axis Credit Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // One Basket Pay Later Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.secondaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: Colors.teal),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'One Basket Pay Later',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Instant credit up to ₹15,000',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pay Later simulator successfully activated!')),
                            );
                          },
                          child: const Text('ACTIVATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Credit Card Ad Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.secondaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.credit_card_rounded, color: Colors.indigo),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'One Basket Co-branded Card',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Get 5% Unlimited Cashback on orders',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Account Settings Section
            _buildSectionHeader('Account Settings', theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: isDark ? AppTheme.secondaryDark : Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Change name, phone and details',
                      onTap: () {},
                      theme: theme,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: 'Manage shipping and delivery locations',
                      onTap: () {},
                      theme: theme,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.translate_rounded,
                      title: 'Select Language',
                      subtitle: 'Choose preferred app language',
                      onTap: () {},
                      theme: theme,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notification Settings',
                      subtitle: 'Configure alerts and marketing info',
                      onTap: () {},
                      theme: theme,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Dashboard',
                      subtitle: 'Manage product catalogs and seed database',
                      iconColor: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPortalView(isFirebaseMode: isFirebaseMode),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. Activity Settings Section
            _buildSectionHeader('My Activity', theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: isDark ? AppTheme.secondaryDark : Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Reviews & Ratings',
                      subtitle: 'See reviews posted by you',
                      onTap: () {},
                      theme: theme,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Questions & Answers',
                      subtitle: 'Check your product Q&A details',
                      onTap: () {},
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Integration Settings Section
            _buildSectionHeader('App Settings & Mode', theme),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.secondaryDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('App Integration Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            isFirebaseMode ? 'Connected to live Firebase Cloud Services' : 'Offline simulation local sandbox',
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        isFirebaseMode ? 'Firebase' : 'Demo Mode',
                        style: TextStyle(
                          color: isFirebaseMode ? Colors.green[800] : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      backgroundColor: isFirebaseMode 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.1),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppTheme.secondaryDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, right: 24),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.grey[500], size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderModel order;

  const _OrderHistoryCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateStr = '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}';
    final itemsCount = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '$dateStr • $itemsCount items',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            Text(
              '${AppConstants.currency}${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                order.status,
                style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        shape: Border.all(color: Colors.transparent),
        collapsedShape: Border.all(color: Colors.transparent),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        childrenPadding: const EdgeInsets.all(12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 6),
          const Text('DELIVERY ADDRESS', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(order.deliveryAddress, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('ITEMS LISTED', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${AppConstants.currency}${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PAYMENT METHOD', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
              Text(order.paymentMethod, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

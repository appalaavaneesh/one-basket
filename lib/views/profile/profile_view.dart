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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<DatabaseService>(context);
    final user = auth.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    final name = user?.displayName ?? 'Demo User';
    final email = user?.email ?? 'demo@example.com';
    final phone = user?.phoneNumber ?? '+1 555 0199';
    final photo = user?.photoUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              // Confirm logout
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // User card details
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(photo),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile info widgets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Mode configuration details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.secondaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('App Integration Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                              fontSize: 10,
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
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.secondaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.admin_panel_settings_rounded, color: theme.colorScheme.primary),
                      ),
                      title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Manage product catalogs, bulk import, and reseed', style: TextStyle(fontSize: 10)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPortalView(isFirebaseMode: isFirebaseMode),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Order History title
                  Text(
                    'Order History',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),

                  // History list
                  FutureBuilder<List<OrderModel>>(
                    future: db.getOrderHistory(user?.uid ?? 'guest_user'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('Error loading history: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                        );
                      }

                      final orders = snapshot.data ?? [];
                      if (orders.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 40),
                                const SizedBox(height: 10),
                                const Text('No orders placed yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _OrderHistoryCard(order: order);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
      color: isDark ? AppTheme.secondaryDark : Colors.white,
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '$dateStr • $itemsCount items',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            Text(
              '${AppConstants.currency}${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                order.status,
                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        shape: Border.all(color: Colors.transparent),
        collapsedShape: Border.all(color: Colors.transparent),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          const Text('DELIVERY ADDRESS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(order.deliveryAddress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          const Text('ITEMS LISTED', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${AppConstants.currency}${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PAYMENT METHOD', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(order.paymentMethod, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

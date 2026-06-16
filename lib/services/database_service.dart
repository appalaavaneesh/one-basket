import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

abstract class DatabaseService {
  Future<List<Product>> getProducts(String category);
  Future<List<Product>> searchProducts(String query);
  Future<void> saveOrder(OrderModel order, String userId);
  Future<List<OrderModel>> getOrderHistory(String userId);
  Future<void> saveUserProfile(UserModel user);
  Future<UserModel?> getUserProfile(String userId);
  
  // Admin backend functions
  Future<List<Product>> getAllProducts();
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<void> reseedProducts(List<Product> products);
}

// ==========================================
// REAL CLOUD FIRESTORE DATABASE SERVICE
// ==========================================
class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<Product>> getProducts(String category) async {
    // If the database is empty, we populate it with our mock items once for convenience
    final snapshot = await _db.collection('products').where('category', isEqualTo: category).get();
    if (snapshot.docs.isEmpty) {
      // Auto seed products for convenience
      final mockCategoryProducts = AppConstants.mockProducts.where((p) => p.category == category).toList();
      for (var p in mockCategoryProducts) {
        await _db.collection('products').doc(p.id).set(p.toMap());
      }
      return mockCategoryProducts;
    }
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    // Basic search on Firestore (in production, Algolia/ElasticSearch is preferred,
    // but for simple cases we filter client-side or fetch and match)
    final snapshot = await _db.collection('products').get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .where((p) => p.name.toLowerCase().contains(lowerQuery) || p.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<void> saveOrder(OrderModel order, String userId) async {
    await _db.collection('users').doc(userId).collection('orders').doc(order.id).set(order.toMap());
  }

  @override
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  @override
  Future<void> reseedProducts(List<Product> products) async {
    final snapshot = await _db.collection('products').get();
    
    // Delete in batches of 400
    var batch = _db.batch();
    int count = 0;
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;
      if (count >= 400) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
    
    // Add in batches of 400
    batch = _db.batch();
    count = 0;
    for (var p in products) {
      batch.set(_db.collection('products').doc(p.id), p.toMap());
      count++;
      if (count >= 400) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }
}

// ==========================================
// MOCK / DEMO DATABASE SERVICE (Persisted locally)
// ==========================================
class MockDatabaseService implements DatabaseService {
  static List<Product>? _localProducts;

  List<Product> _getProductsList() {
    _localProducts ??= List<Product>.from(AppConstants.mockProducts);
    return _localProducts!;
  }
  
  @override
  Future<List<Product>> getProducts(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _getProductsList().where((product) => product.category == category).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _getProductsList()
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<void> saveOrder(OrderModel order, String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing orders
    final String? ordersJson = prefs.getString('mock_orders_$userId');
    List<dynamic> ordersList = [];
    if (ordersJson != null) {
      ordersList = jsonDecode(ordersJson);
    }
    
    // Add new order at the beginning
    ordersList.insert(0, order.toMap());
    
    // Save back to SharedPreferences
    await prefs.setString('mock_orders_$userId', jsonEncode(ordersList));
  }

  @override
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString('mock_orders_$userId');
    if (ordersJson != null) {
      final List<dynamic> ordersList = jsonDecode(ordersJson);
      return ordersList.map((item) => OrderModel.fromMap(Map<String, dynamic>.from(item))).toList();
    }
    return [];
  }

  @override
  Future<void> saveUserProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_profile_${user.uid}', jsonEncode(user.toMap()));
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('mock_profile_$userId');
    if (profileJson != null) {
      return UserModel.fromMap(jsonDecode(profileJson));
    }
    return null;
  }

  @override
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Product>.from(_getProductsList());
  }

  @override
  Future<void> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _getProductsList();
    list.removeWhere((p) => p.id == product.id);
    list.add(product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _getProductsList();
    list.removeWhere((p) => p.id == productId);
  }

  @override
  Future<void> reseedProducts(List<Product> products) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _localProducts = List<Product>.from(products);
  }
}


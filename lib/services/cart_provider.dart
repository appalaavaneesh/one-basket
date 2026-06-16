import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _appliedPromoCode;
  double _promoDiscountPercentage = 0.0;

  List<CartItem> get items => [..._items];

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee {
    if (_items.isEmpty) return 0.0;
    // Food delivery has custom fees, groceries are flat, fashion is free over ₹999
    bool hasFood = _items.any((item) => item.product.category == 'food');
    bool hasGrocery = _items.any((item) => item.product.category == 'grocery');
    
    if (hasFood) return 50.00;
    if (hasGrocery) return 40.00;
    
    // Fashion only
    return subtotal > 999.00 ? 0.0 : 99.00;
  }

  double get tax => subtotal * 0.08; // 8% Sales Tax

  double get discountAmount => subtotal * (_promoDiscountPercentage / 100);

  double get total => (subtotal + deliveryFee + tax) - discountAmount;

  String? get appliedPromoCode => _appliedPromoCode;

  void addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
    List<String>? customizations,
    String? unit,
  }) {
    // Check if item already exists with exact same options
    int existingIndex = _items.indexWhere((item) {
      bool sameProduct = item.product.id == product.id;
      bool sameSize = item.selectedSize == size;
      bool sameColor = item.selectedColor == color;
      bool sameUnit = item.selectedUnit == unit;
      
      bool sameCustomizations = true;
      if (item.selectedCustomizations != null && customizations != null) {
        if (item.selectedCustomizations!.length == customizations.length) {
          for (var c in customizations) {
            if (!item.selectedCustomizations!.contains(c)) {
              sameCustomizations = false;
              break;
            }
          }
        } else {
          sameCustomizations = false;
        }
      } else if (item.selectedCustomizations != customizations) {
        sameCustomizations = false;
      }
      
      return sameProduct && sameSize && sameColor && sameUnit && sameCustomizations;
    });

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedSize: size,
          selectedColor: color,
          selectedCustomizations: customizations,
          selectedUnit: unit,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    int index = _items.indexOf(item);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'AURA20') {
      _appliedPromoCode = 'AURA20';
      _promoDiscountPercentage = 20.0;
      notifyListeners();
      return true;
    } else if (cleanCode == 'WELCOME10') {
      _appliedPromoCode = 'WELCOME10';
      _promoDiscountPercentage = 10.0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _promoDiscountPercentage = 0.0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _promoDiscountPercentage = 0.0;
    notifyListeners();
  }
}

import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final List<String>? selectedCustomizations;
  final String? selectedUnit;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
    this.selectedCustomizations,
    this.selectedUnit,
  });

  double get totalPrice => product.price * quantity;

  // Convert to Map for local storage persistence if needed
  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'selectedCustomizations': selectedCustomizations,
      'selectedUnit': selectedUnit,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(map['product'], map['product']['id'] ?? ''),
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'],
      selectedColor: map['selectedColor'],
      selectedCustomizations: map['selectedCustomizations'] != null 
          ? List<String>.from(map['selectedCustomizations']) 
          : null,
      selectedUnit: map['selectedUnit'],
    );
  }
}

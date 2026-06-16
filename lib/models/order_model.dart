import 'cart_model.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime orderDate;
  final String status; // 'Pending', 'Processing', 'Shipped', 'Delivered'

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.orderDate,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      items: map['items'] != null
          ? (map['items'] as List).map((item) => CartItem.fromMap(item)).toList()
          : [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: map['deliveryAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      orderDate: map['orderDate'] != null ? DateTime.parse(map['orderDate']) : DateTime.now(),
      status: map['status'] ?? 'Pending',
    );
  }
}

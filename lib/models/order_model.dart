class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'confirmed', 'delivered', 'cancelled'
  final int createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    var rawItems = map['items'] as List<dynamic>? ?? [];
    List<OrderItem> parsedItems = rawItems.map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i))).toList();

    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      items: parsedItems,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

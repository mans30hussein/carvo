import 'package:carvo/features/customer/data/model/product_model.dart';
import 'package:flutter/foundation.dart';
 
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.finalPrice * quantity;
}

/// Simple in-memory cart. Swap the internals for a Firestore-backed
/// implementation later without touching the screens that use it.
class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService instance = CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  void addItem(ProductModel product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(ProductModel product) {
    _items.removeWhere((i) => i.product.id == product.id);
    notifyListeners();
  }

  void updateQuantity(ProductModel product, int quantity) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
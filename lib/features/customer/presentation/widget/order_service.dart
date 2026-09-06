import 'package:carvo/features/customer/data/model/product_model.dart';

 
/// Placeholder for submitting a direct order request for a single product,
/// without going through the cart. Replace the body with your real
/// Firestore write / API call when ready.
class OrderService {
  static Future<void> requestOrder(ProductModel product, {int quantity = 1}) async {
    // TODO: replace with real submission, e.g.:
    // await FirestoreService.createOrderRequest(product: product, quantity: quantity);
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
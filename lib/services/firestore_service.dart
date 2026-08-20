import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/emergency_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PRODUCTS ---
  static Stream<List<ProductModel>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

 static Future<void> addProduct(ProductModel product) async {
     await _db.collection('products').doc(product.id).set(product.toMap());
  }

  static Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // --- ORDERS ---
  static Stream<List<OrderModel>> streamOrders() {
    return _db.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  static Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toMap());
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  // --- EMERGENCIES ---
  static Stream<List<EmergencyModel>> streamEmergencies() {
    return _db.collection('emergencies').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EmergencyModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  static Future<void> createEmergencyRequest(EmergencyModel emergency) async {
    await _db.collection('emergencies').doc(emergency.id).set(emergency.toMap());
  }

  static Future<void> updateEmergencyStatus(String emergencyId, String status, {String? providerId, String? providerName}) async {
    Map<String, dynamic> updateData = {'status': status};
    if (providerId != null) updateData['assignedProviderId'] = providerId;
    if (providerName != null) updateData['assignedProviderName'] = providerName;
    await _db.collection('emergencies').doc(emergencyId).update(updateData);
  }

  // --- USERS ---
  static Stream<List<UserModel>> streamUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  static Future<void> toggleUserBlock(String uid, bool isBlocked) async {
    await _db.collection('users').doc(uid).update({'isBlocked': isBlocked});
  }
}

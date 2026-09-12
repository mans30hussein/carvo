import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carvo/features/customer/data/model/product_model.dart';
import 'package:carvo/models/order_model.dart';
import 'package:carvo/services/firestore_service.dart';

class OrderService {
  static Future<void> requestOrder(ProductModel product, {int quantity = 1}) async {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.uid}, email: ${user?.email}'); // Debugging line
    if (user == null) {
      throw Exception('لا يمكن إرسال الطلب: المستخدم غير مسجل الدخول');
    }

    final profile = await FirestoreService.getUserProfile(user.uid);
    //final profile = await FirestoreService.getUserProfile(user.uid);
print('Fetched profile -> name: ${profile?.name}, phone: ${profile?.phone}, address: ${profile?.address}');
    if (profile == null) {
      throw Exception('يرجى إكمال بيانات الملف الشخصي (الاسم، الهاتف، العنوان) أولاً');
    }

    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

    final order = OrderModel(
      id: orderId,
      customerId: user.uid,
      customerName: profile.name  ,       // adjust field name if different
      customerPhone: profile.phone ,     // adjust field name if different
      customerAddress: profile.address, // adjust field name if different
      items: [
        OrderItem(
          productId: product.id,
          productName: product.name,
          price: product.finalPrice,
          quantity: quantity,
        ),
      ],
      totalAmount: product.finalPrice * quantity,
    );

    await FirestoreService.createOrder(order);
  }
}
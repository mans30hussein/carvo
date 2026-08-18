class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String type; // 'customer', 'vendor', 'mechanic', 'winch', 'admin'
  final String? shopName;
  final String? specialization;
  final bool isBlocked;
  final int createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.type,
    this.shopName,
    this.specialization,
    this.isBlocked = false,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? 'مستخدم CarVo',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      type: map['type'] ?? map['role'] ?? 'customer',
      shopName: map['shopName'],
      specialization: map['specialization'],
      isBlocked: map['isBlocked'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'type': type,
      'role': type,
      'shopName': shopName,
      'specialization': specialization,
      'isBlocked': isBlocked,
      'createdAt': createdAt,
    };
  }
}

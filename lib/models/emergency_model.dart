class EmergencyModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String type; // 'winch' or 'mechanic'
  final String locationAddress;
  final String description;
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final String? assignedProviderId;
  final String? assignedProviderName;
  final int createdAt;

  EmergencyModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.type,
    required this.locationAddress,
    required this.description,
    this.status = 'pending',
    this.assignedProviderId,
    this.assignedProviderName,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory EmergencyModel.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      type: map['type'] ?? 'winch',
      locationAddress: map['locationAddress'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      assignedProviderId: map['assignedProviderId'],
      assignedProviderName: map['assignedProviderName'],
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'type': type,
      'locationAddress': locationAddress,
      'description': description,
      'status': status,
      'assignedProviderId': assignedProviderId,
      'assignedProviderName': assignedProviderName,
      'createdAt': createdAt,
    };
  }
}

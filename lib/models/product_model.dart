class ProductModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final String name;
  final String description;
  final String brandName;
  final double originalPrice;
  final double finalPrice;
  final String category;
  final String image;
  final int stock;
  final int createdAt;
  final String brandMarka;
  final String modelName;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.name,
    required this.description,
    required this.brandName,
    required this.originalPrice,
    required this.finalPrice,
    required this.category,
    required this.image,
    this.stock = 10,
    required this.brandMarka,
    required this.modelName,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? 'المتجر',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      brandName: map['brandName'] ?? 'CarVo',
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (map['finalPrice'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'قطع غيار',
      image: map['image'] ?? 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500',
      stock: (map['stock'] as num?)?.toInt() ?? 10,
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      brandMarka: map['brandMarka'] ?? '',
      modelName: map['modelName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'name': name,
      'description': description,
      'brandName': brandName,
      'originalPrice': originalPrice,
      'finalPrice': finalPrice,
      'category': category,
      'image': image,
      'stock': stock,
      'createdAt': createdAt,
      'brandMarka': brandMarka,
      'modelName': modelName,
    };
  }
}

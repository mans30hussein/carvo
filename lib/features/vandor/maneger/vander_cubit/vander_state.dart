// lib/features/vandor/maneger/vendor_products_cubit/vendor_products_state.dart
import 'package:carvo/features/customer/data/model/product_model.dart';

enum VendorProductsStatus { loading, loaded, failure }

class VendorProductsState {
  final List<ProductModel> products;
  final VendorProductsStatus status;
  final String message;

  const VendorProductsState({
    required this.products,
    required this.status,
    required this.message,
  });

  factory VendorProductsState.initial() => const VendorProductsState(
        products: [],
        status: VendorProductsStatus.loading,
        message: '',
      );

  VendorProductsState copyWith({
    List<ProductModel>? products,
    VendorProductsStatus? status,
    String? message,
  }) {
    return VendorProductsState(
      products: products ?? this.products,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
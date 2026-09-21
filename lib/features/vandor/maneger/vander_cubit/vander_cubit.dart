// lib/features/vandor/maneger/vendor_products_cubit/vendor_products_cubit.dart
import 'dart:async';
import 'package:carvo/features/vandor/maneger/vander_cubit/vander_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carvo/services/firestore_service.dart';
 
/// Streams the logged-in vendor's own products from Firestore so the
/// waiting/status list updates live the moment admin approves a product.
class VendorProductsCubit extends Cubit<VendorProductsState> {
  VendorProductsCubit({required this.vendorId})
      : super(VendorProductsState.initial()) {
    _subscribe();
  }

  final String vendorId;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub = FirestoreService.streamVendorProducts(vendorId).listen(
      (products) {
        emit(state.copyWith(
          products: products,
          status: VendorProductsStatus.loaded,
        ));
      },
      onError: (_) {
        emit(state.copyWith(
          status: VendorProductsStatus.failure,
          message: "تعذر تحميل المنتجات، حاول مرة أخرى",
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
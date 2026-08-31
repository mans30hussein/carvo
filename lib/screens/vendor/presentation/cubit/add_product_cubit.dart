import 'package:carvo/models/product_model.dart';
import 'package:carvo/models/user_model.dart';
import 'package:carvo/screens/vendor/presentation/widget/condational_selector.dart';
import 'package:carvo/services/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
import 'add_product_state.dart';

const String _defaultProductImage =
    "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500";

/// All business logic for [AddProductScreen] — validation, saving to
/// Firestore, and selection state. The screen only reads [AddProductState]
/// and calls these methods; it contains no logic of its own.
class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit({required this.user}) : super(AddProductState.initial());

  final UserModel user;

  void selectCategory(String value) =>
      emit(state.copyWith(selectedCategory: value));

  void selectBrand(String value) =>
      emit(state.copyWith(selectedBrand: value));

  void selectCondition(ProductCondition value) =>
      emit(state.copyWith(condition: value));


  Future<void> saveProduct({
    required String name,
    required String priceText,
    required String partNumber,
    required String brandMarka,
    required String modelName,
  }) async {
    final trimmedName = name.trim();
    final trimmedPrice = priceText.trim();
    final trimmedBrandMarka = brandMarka.trim();
    final trimmedModelName = modelName.trim();

    if (trimmedName.isEmpty || trimmedPrice.isEmpty) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        message: "يرجى إدخال اسم القطعة والسعر",
      ));
      return;
    }else if(trimmedBrandMarka.isEmpty || trimmedModelName.isEmpty){
      emit(state.copyWith(
        status: AddProductStatus.failure,
        message: "يرجى إدخال البراند والموديل",
      ));
      return;
    }

    final double price = double.tryParse(trimmedPrice) ?? 0.0;
    final bool brandChosen = state.selectedBrand != kProductBrands.first;
  //  final desc = trimmedBrandMarka.isNotEmpty ? trimmedBrandMarka : "desc";
  //   final part = partNumber.trim();

    emit(state.copyWith(status: AddProductStatus.submitting));

    try {
      final String id = "prod_${DateTime.now().millisecondsSinceEpoch}";
      final product = ProductModel(
        id: id,
        vendorId: user.uid,
        vendorName: user.shopName ?? user.name,
        name: trimmedName,
        brandName: brandChosen ? state.selectedBrand : "CarVo",
        description: "desc",
            
        originalPrice: price * 1.15,
        finalPrice: price,
        category: state.selectedCategory,
        image: _defaultProductImage,
        brandMarka: trimmedBrandMarka,
        modelName: trimmedModelName,
      );

      await FirestoreService.addProduct(product);

      // Reset selection state back to defaults, but keep the success
      // status/message so the UI can react to it.
      emit(AddProductState.initial().copyWith(
        status: AddProductStatus.success,
        message: "تم نشر قطعة الغيار في متجر CarVo بنجاح! 🎉",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddProductStatus.failure,
        message: "حدث خطأ أثناء الحفظ، حاول مرة أخرى",
      ));
    }
  }
}
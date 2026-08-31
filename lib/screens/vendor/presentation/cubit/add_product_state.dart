import 'package:carvo/screens/vendor/presentation/widget/condational_selector.dart';

 
/// Static option lists — these don't change, so they live outside state.
const List<String> kProductCategories = [
  ' اختر التصنيف',
  'قطع غيار محرك',
  'فرامل وتيل',
  'فلاتر وزيوت',
  'بطاريات وكهرباء',
  'عفشة ومساعدين',
  'إطارات وجنوط',
  'إكسسوارات وعناية',
];

const List<String> kProductBrands = [
  'اختر البراند',
  'BOSCH',
  'DENSO',
  'NGK',
  'MANN',
  'KYB',
  'ACDelco',
  'Valeo',
  'Mahle',
  'Hella',
];

enum AddProductStatus { initial, submitting, success, failure }

class AddProductState {
  final String selectedCategory;
  final String selectedBrand;
  final ProductCondition condition;
  final AddProductStatus status;
  final String message;

  const AddProductState({
    required this.selectedCategory,
    required this.selectedBrand,
    required this.condition,
    required this.status,
    required this.message,
  });

  factory AddProductState.initial() => AddProductState(
        selectedCategory: kProductCategories.first,
        selectedBrand: kProductBrands.first,
        condition: ProductCondition.newItem,
        status: AddProductStatus.initial,
        message: '',
      );

  AddProductState copyWith({
    String? selectedCategory,
    String? selectedBrand,
    ProductCondition? condition,
    AddProductStatus? status,
    String? message,
  }) {
    return AddProductState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
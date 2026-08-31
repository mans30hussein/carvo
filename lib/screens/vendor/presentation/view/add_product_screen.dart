import 'package:carvo/models/user_model.dart';
import 'package:carvo/screens/vendor/presentation/widget/condational_selector.dart';
import 'package:carvo/screens/vendor/presentation/widget/custom_drop_down_menue.dart';
import 'package:carvo/screens/vendor/presentation/widget/custom_text_field.dart';
import 'package:carvo/screens/vendor/presentation/widget/primary_submit_button.dart';
import 'package:carvo/screens/vendor/presentation/widget/product_image_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/add_product_cubit.dart';
import '../cubit/add_product_state.dart';

class AddProductScreen extends StatelessWidget {
  final UserModel user;
  const AddProductScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddProductCubit(user: user),
      child: const _AddProductView(),
    );
  }
}

class _AddProductView extends StatefulWidget {
  const _AddProductView();

  @override
  State<_AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<_AddProductView> {
  // (business state) — this is the idiomatic Bloc/Cubit split.
  final _nameController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _modelController = TextEditingController();
  final _brandMarkaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _partNumberController.dispose();
    _priceController.dispose();
    _modelController.dispose();
    _brandMarkaController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) {
    context.read<AddProductCubit>().saveProduct(
      name: _nameController.text,
      priceText: _priceController.text,
      partNumber: _partNumberController.text,
      brandMarka: _brandMarkaController.text,
      modelName: _modelController.text,
    );
  }

  void _clearForm() {
    _nameController.clear();
    _partNumberController.clear();
    _priceController.clear();
    _modelController.clear();
    _brandMarkaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.imageStatus != current.imageStatus,
      listener: (context, state) {
        if (state.status == AddProductStatus.success) {
          _clearForm();
        }
        if (state.status == AddProductStatus.success ||
            state.status == AddProductStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: GoogleFonts.cairo())),
          );
        }
        if (state.imageStatus == ImageUploadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.imageMessage, style: GoogleFonts.cairo()),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddProductCubit>();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("صورة القطعة", style: GoogleFonts.cairo(color: Colors.white)),
              const SizedBox(height: 8),
              ProductImagePickerCard(
                previewBytes: state.pickedImageBytes,
                isUploading: state.imageStatus == ImageUploadStatus.uploading,
                onSourceSelected: cubit.pickAndUploadImage,
                onRemove:
                    state.pickedImageBytes != null ? cubit.removeImage : null,
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _nameController,
                label: "اسم القطعة والمواصفات",
              ),
              const SizedBox(height: 16),

              CustomDropdownField(
                value: state.selectedBrand,
                label: "البراند",
                items: kProductBrands,
                onChanged: cubit.selectBrand,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                label: "السعر (ج.م)",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              CustomDropdownField(
                value: state.selectedCategory,
                label: "القسم / التصنيف",
                items: kProductCategories,
                onChanged: cubit.selectCategory,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _partNumberController,
                label: "رقم القطعة",
              ),
              const SizedBox(height: 32),

              Text("الحالة", style: GoogleFonts.cairo(color: Colors.white)),
              const SizedBox(height: 8),
              ConditionSelector(
                selected: state.condition,
                onChanged: cubit.selectCondition,
              ),
              const SizedBox(height: 16),
              Text(
                "توافق السيارات",
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _modelController,
                      label: "الموديل",
                      // icon: Icons.model_training_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _brandMarkaController,
                      label: "الماركة",
                      // icon: Icons.branding_watermark_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimarySubmitButton(
                isLoading: state.status == AddProductStatus.submitting,
                label: "ارسال للمراجعة",
                icon: Icons.cloud_upload_rounded,
                onPressed: () => _handleSave(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
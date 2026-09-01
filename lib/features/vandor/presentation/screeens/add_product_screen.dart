import 'package:carvo/features/vandor/presentation/widgetes/condition_and_compatibility.dart';
import 'package:carvo/features/vandor/presentation/widgetes/product_detailes_section.dart';
import 'package:carvo/models/user_model.dart';
 import 'package:carvo/features/vandor/presentation/widgetes/image_section.dart';
 import 'package:carvo/features/vandor/presentation/widgetes/primary_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../maneger/add_product_cubit/add_product_cubit.dart';
import '../../maneger/add_product_cubit/add_product_state.dart';

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
              ImageSection(state: state, cubit: cubit),
              const SizedBox(height: 24),

              ProductDetailsSection(
                state: state,
                cubit: cubit,
                nameController: _nameController,
                priceController: _priceController,
                partNumberController: _partNumberController,
              ),
              const SizedBox(height: 32),

              ConditionAndCompatibilitySection(
                state: state,
                cubit: cubit,
                modelController: _modelController,
                brandMarkaController: _brandMarkaController,
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
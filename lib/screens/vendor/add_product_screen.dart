import 'package:carvo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final UserModel user;
  const AddProductScreen({super.key, required this.user});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  String _selectedCategory = ' اختر التصنيف';
  String _selectedBrand = 'اختر البراند';

  bool _isLoading = false;

  final List<String> _categories = [
    ' اختر التصنيف',
    'قطع غيار محرك',
    'فرامل وتيل',
    'فلاتر وزيوت',
    'بطاريات وكهرباء',
    'عفشة ومساعدين',
    'إطارات وجنوط',
    'إكسسوارات وعناية',
  ];
  final List<String> _brands = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    String name = _nameController.text.trim();
    String brand = _brandController.text.trim();
    String priceStr = _priceController.text.trim();
    String desc = _descController.text.trim();
    String img = _imageController.text.trim();

    if (name.isEmpty || priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "يرجى إدخال اسم القطعة والسعر",
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    double price = double.tryParse(priceStr) ?? 0.0;
    setState(() => _isLoading = true);

    try {
      String id = "prod_${DateTime.now().millisecondsSinceEpoch}";
      ProductModel product = ProductModel(
        id: id,
        vendorId: widget.user.uid,
        vendorName: widget.user.shopName ?? widget.user.name,
        name: name,
        brandName: brand.isEmpty ? "CarVo" : brand,
        description: desc,
        originalPrice: price * 1.15,
        finalPrice: price,
        category: _selectedCategory,
        image: img.isEmpty
            ? "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500"
            : img,
      );

      await FirestoreService.addProduct(product);

      if (!mounted) return;

      // clear the form after a successful save
      _nameController.clear();
      _brandController.clear();
      _priceController.clear();
      _descController.clear();
      _imageController.clear();
      setState(() {
        _selectedCategory = _categories.first;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم نشر قطعة الغيار في متجر CarVo بنجاح! 🎉",
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء الحفظ، حاول مرة أخرى",
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          TextField(
            controller: _descController,
            // maxLines: 3,
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "اسم القطعة والمواصفات",
              prefixIcon: Icon(
                Icons.description_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedBrand,
            dropdownColor: AppColors.card,
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "البراند",
              prefixIcon: Icon(
                Icons.category_outlined,
                color: AppColors.primary,
              ),
            ),
            items: _brands
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: GoogleFonts.cairo()),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBrand = val);
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "السعر (ج.م)",
              prefixIcon: Icon(
                Icons.attach_money_rounded,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: AppColors.card,
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "القسم / التصنيف",
              prefixIcon: Icon(
                Icons.category_outlined,
                color: AppColors.primary,
              ),
            ),
            items: _categories
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: GoogleFonts.cairo()),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),

          // Image URL Input

          // Description Input
          TextField(
            controller: _descController,
            // maxLines: 3,
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "رقم القطعة ",
              prefixIcon: Icon(
                Icons.description_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text("الحالة"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "جديد",
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  alignment: Alignment.center,

                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "مستعمل",
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProduct,
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.cloud_upload_rounded),
              label: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      "نشر في المتجر وحفظ في Firebase",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

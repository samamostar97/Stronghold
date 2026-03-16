import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/product_response.dart';
import '../models/product_category_response.dart';
import '../models/supplier_response.dart';
import '../providers/products_provider.dart';

class ProductFormModal extends ConsumerStatefulWidget {
  final ProductResponse? product;

  const ProductFormModal({super.key, this.product});

  @override
  ConsumerState<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends ConsumerState<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  int? _categoryId;
  int? _supplierId;
  bool _loading = false;
  String? _errorMessage;

  // Image
  String? _selectedImagePath;
  String? _selectedImageName;
  bool _uploadingImage = false;

  // Dropdown data
  List<ProductCategoryResponse> _categories = [];
  List<SupplierResponse> _suppliers = [];
  bool _loadingDropdowns = true;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product?.name ?? '');
    _description =
        TextEditingController(text: widget.product?.description ?? '');
    _price = TextEditingController(
        text: widget.product?.price.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(
        text: widget.product?.stockQuantity.toString() ?? '');
    _categoryId = widget.product?.categoryId;
    _supplierId = widget.product?.supplierId;
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      final catRepo = ref.read(productCategoriesRepositoryProvider);
      final supRepo = ref.read(suppliersRepositoryProvider);
      final results = await Future.wait([
        catRepo.getCategories(),
        supRepo.getSuppliers(pageSize: 100),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<ProductCategoryResponse>;
          _suppliers =
              (results[1] as PagedSupplierResponse).items;
          _loadingDropdowns = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDropdowns = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
        _selectedImageName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null || _supplierId == null) {
      setState(() {
        _errorMessage = 'Odaberite kategoriju i dobavljaca.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(productsRepositoryProvider);
      ProductResponse saved;

      if (isEditing) {
        saved = await repo.updateProduct(
          id: widget.product!.id,
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          price: double.parse(_price.text.trim()),
          stockQuantity: int.parse(_stock.text.trim()),
          categoryId: _categoryId!,
          supplierId: _supplierId!,
        );
      } else {
        saved = await repo.createProduct(
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          price: double.parse(_price.text.trim()),
          stockQuantity: int.parse(_stock.text.trim()),
          categoryId: _categoryId!,
          supplierId: _supplierId!,
        );
      }

      if (_selectedImagePath != null) {
        setState(() => _uploadingImage = true);
        await repo.uploadProductImage(
          id: saved.id,
          filePath: _selectedImagePath!,
          fileName: _selectedImageName!,
        );
      }

      ref.invalidate(productsListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, isEditing
            ? 'Proizvod uspjesno azuriran.'
            : 'Proizvod uspjesno dodan.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _uploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Uredi proizvod' : 'Dodaj proizvod',
                          style: AppTextStyles.h2,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(
                      color: Colors.white.withValues(alpha: 0.06), height: 1),
                  const SizedBox(height: 20),

                  // Product image
                  Center(child: _buildImagePicker()),
                  const SizedBox(height: 20),

                  // Name
                  _buildField('Naziv', _name, required: true),
                  const SizedBox(height: 14),
                  _buildField('Opis (opcionalno)', _description, maxLines: 3),
                  const SizedBox(height: 14),

                  // Price + Stock
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('Cijena (KM)', _price,
                            required: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            customValidator: (v) {
                              final val = double.tryParse(v!);
                              if (val == null) return 'Unesite ispravnu cijenu.';
                              if (val <= 0) return 'Cijena mora biti veca od 0.';
                              return null;
                            }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField('Stanje', _stock,
                            required: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            customValidator: (v) {
                              final val = int.tryParse(v!);
                              if (val == null) return 'Unesite ispravan broj.';
                              if (val < 0) return 'Stanje ne moze biti negativno.';
                              return null;
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category + Supplier dropdowns
                  if (_loadingDropdowns)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<int>(
                            label: 'Kategorija',
                            value: _categoryId,
                            items: _categories
                                .map((c) => DropdownMenuItem(
                                    value: c.id, child: Text(c.name)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _categoryId = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown<int>(
                            label: 'Dobavljac',
                            value: _supplierId,
                            items: _suppliers
                                .map((s) => DropdownMenuItem(
                                    value: s.id, child: Text(s.name)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _supplierId = v),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                ),
                                if (_uploadingImage) ...[
                                  const SizedBox(width: 10),
                                  Text('Uploading slika...',
                                      style: AppTextStyles.button),
                                ],
                              ],
                            )
                          : Text(
                              isEditing
                                  ? 'Sacuvaj izmjene'
                                  : 'Dodaj proizvod',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasExistingImage = widget.product?.imageUrl != null &&
        widget.product!.imageUrl!.isNotEmpty;
    final hasSelectedImage = _selectedImagePath != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasSelectedImage
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: hasSelectedImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imageIcon(),
                    ),
                  )
                : hasExistingImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          '${ApiConstants.baseUrl.replaceAll('/api', '')}${widget.product!.imageUrl!}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imageIcon(),
                        ),
                      )
                    : _imageIcon(),
          ),
          const SizedBox(height: 8),
          Text(
            hasSelectedImage
                ? _selectedImageName!
                : hasExistingImage
                    ? 'Promijeni sliku'
                    : 'Dodaj sliku',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageIcon() {
    return const Center(
      child: Icon(Icons.camera_alt_outlined,
          color: AppColors.primary, size: 28),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: AppColors.sidebar,
          style: AppTextStyles.body.copyWith(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? customValidator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body.copyWith(fontSize: 13),
          validator: (v) {
            if (required && (v == null || v.trim().isEmpty)) {
              return 'Obavezno polje';
            }
            if (customValidator != null && v != null && v.trim().isNotEmpty) {
              return customValidator(v.trim());
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.4)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

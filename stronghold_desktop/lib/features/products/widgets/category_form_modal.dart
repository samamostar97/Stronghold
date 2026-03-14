import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/product_category_response.dart';
import '../providers/products_provider.dart';

class CategoryFormModal extends ConsumerStatefulWidget {
  final ProductCategoryResponse? category;

  const CategoryFormModal({super.key, this.category});

  @override
  ConsumerState<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends ConsumerState<CategoryFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  bool _loading = false;
  String? _errorMessage;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
    _description =
        TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(productCategoriesRepositoryProvider);
      if (isEditing) {
        await repo.updateCategory(
          id: widget.category!.id,
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
        );
      } else {
        await repo.createCategory(
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
        );
      }

      ref.invalidate(categoriesListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Kategorija uspjesno azurirana.'
                : 'Kategorija uspjesno dodana.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing
                            ? 'Uredi kategoriju'
                            : 'Dodaj kategoriju',
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
                _buildField('Naziv', _name, required: true),
                const SizedBox(height: 14),
                _buildField('Opis', _description, maxLines: 3),

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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEditing
                                ? 'Sacuvaj izmjene'
                                : 'Dodaj kategoriju',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(fontSize: 13),
          validator: required
              ? (v) =>
                  v == null || v.trim().isEmpty ? 'Obavezno polje' : null
              : null,
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

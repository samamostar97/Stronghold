import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../data/membership_packages_repository.dart';
import '../models/membership_package_response.dart';
import '../providers/membership_packages_provider.dart';

class PackageFormModal extends ConsumerStatefulWidget {
  final MembershipPackageResponse? package;

  const PackageFormModal({super.key, this.package});

  @override
  ConsumerState<PackageFormModal> createState() => _PackageFormModalState();
}

class _PackageFormModalState extends ConsumerState<PackageFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  bool _loading = false;

  bool get isEditing => widget.package != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.package?.name ?? '');
    _description =
        TextEditingController(text: widget.package?.description ?? '');
    _price = TextEditingController(
        text: widget.package?.price.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(membershipPackagesRepositoryProvider);
      if (isEditing) {
        await repo.updatePackage(
          id: widget.package!.id,
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          price: double.parse(_price.text.trim()),
        );
      } else {
        await repo.createPackage(
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          price: double.parse(_price.text.trim()),
        );
      }

      ref.invalidate(membershipPackagesListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, isEditing
            ? 'Paket uspjesno azuriran.'
            : 'Paket uspjesno kreiran.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Greska: $e');
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
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Uredi paket' : 'Dodaj paket',
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
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 1),
                  const SizedBox(height: 20),

                  _buildField('Naziv', _name, required: true),
                  const SizedBox(height: 14),
                  _buildField('Opis (opcionalno)', _description, maxLines: 3),
                  const SizedBox(height: 14),
                  _buildField('Cijena (KM)', _price,
                      required: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obavezno polje';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Unesite validnu cijenu';
                    }
                    return null;
                  }),

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
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Sacuvaj izmjene' : 'Dodaj paket',
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(fontSize: 13),
          validator: validator ??
              (required
                  ? (v) =>
                      v == null || v.trim().isEmpty ? 'Obavezno polje' : null
                  : null),
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

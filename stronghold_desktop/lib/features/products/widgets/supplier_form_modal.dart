import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/phone_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/supplier_response.dart';
import '../providers/products_provider.dart';

class SupplierFormModal extends ConsumerStatefulWidget {
  final SupplierResponse? supplier;

  const SupplierFormModal({super.key, this.supplier});

  @override
  ConsumerState<SupplierFormModal> createState() => _SupplierFormModalState();
}

class _SupplierFormModalState extends ConsumerState<SupplierFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _website;
  bool _loading = false;
  String? _errorMessage;

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.supplier?.name ?? '');
    _email = TextEditingController(text: widget.supplier?.email ?? '');
    _phone = TextEditingController(text: widget.supplier?.phone ?? '');
    _website = TextEditingController(text: widget.supplier?.website ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(suppliersRepositoryProvider);
      if (isEditing) {
        await repo.updateSupplier(
          id: widget.supplier!.id,
          name: _name.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          website:
              _website.text.trim().isEmpty ? null : _website.text.trim(),
        );
      } else {
        await repo.createSupplier(
          name: _name.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          website:
              _website.text.trim().isEmpty ? null : _website.text.trim(),
        );
      }

      ref.invalidate(suppliersListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, isEditing
            ? 'Dobavljac uspjesno azuriran.'
            : 'Dobavljac uspjesno dodan.');
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
        constraints: const BoxConstraints(maxWidth: 480),
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
                            ? 'Uredi dobavljaca'
                            : 'Dodaj dobavljaca',
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
                Row(
                  children: [
                    Expanded(
                        child: _buildField('Email', _email,
                            keyboardType: TextInputType.emailAddress)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildField('Telefon', _phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                          PhoneInputFormatter(),
                        ])),
                  ],
                ),
                const SizedBox(height: 14),
                _buildField('Website', _website),

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
                                : 'Dodaj dobavljaca',
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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

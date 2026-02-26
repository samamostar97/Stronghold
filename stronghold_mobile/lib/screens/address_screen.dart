import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/address_provider.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import '../widgets/feedback_dialog.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _prefill(AddressResponse address) {
    if (_initialized) return;
    _initialized = true;
    _streetController.text = address.street;
    _cityController.text = address.city;
    _postalCodeController.text = address.postalCode;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final request = UpsertAddressRequest(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      );
      await ref.read(addressServiceProvider).upsertMyAddress(request);
      ref.invalidate(addressProvider);
      if (mounted) {
        await showSuccessFeedback(context, 'Adresa uspjesno sacuvana');
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        await showErrorFeedback(
          context,
          ErrorHandler.message(e),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressAsync = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Adresa za dostavu', style: AppTextStyles.headingSm),
        centerTitle: false,
      ),
      body: addressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Greska prilikom ucitavanja',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
          ),
        ),
        data: (existing) {
          if (existing != null) _prefill(existing);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field(
                          controller: _streetController,
                          label: 'Ulica i broj',
                          hint: 'npr. Marsala Tita 25',
                          icon: LucideIcons.mapPin,
                          validator: (v) => FormValidators.requiredMaxLength(
                            v,
                            maxLength: 200,
                            requiredMessage: 'Unesite ulicu',
                            maxLengthMessage:
                                'Ulica moze imati najvise 200 karaktera',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _field(
                          controller: _cityController,
                          label: 'Grad',
                          hint: 'npr. Sarajevo',
                          icon: LucideIcons.building2,
                          validator: (v) => FormValidators.requiredMaxLength(
                            v,
                            maxLength: 100,
                            requiredMessage: 'Unesite grad',
                            maxLengthMessage:
                                'Grad moze imati najvise 100 karaktera',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _field(
                          controller: _postalCodeController,
                          label: 'Postanski broj',
                          hint: 'npr. 71000',
                          icon: LucideIcons.hash,
                          keyboardType: TextInputType.number,
                          validator: (v) => FormValidators.requiredMaxLength(
                            v,
                            maxLength: 20,
                            requiredMessage: 'Unesite postanski broj',
                            maxLengthMessage:
                                'Postanski broj moze imati najvise 20 karaktera',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Country info
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDim,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.globe,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Drzava',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Bosna i Hercegovina',
                                style: AppTextStyles.bodyBold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GradientButton(
                    label: existing != null
                        ? 'Sacuvaj izmjene'
                        : 'Dodaj adresu',
                    onPressed: _isLoading ? null : _save,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ).animate()
                .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                .slideY(begin: 0.04, end: 0, duration: Motion.smooth, curve: Motion.curve),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textDark),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

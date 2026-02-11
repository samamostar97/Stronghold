import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/address_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_header.dart';

class CheckoutAddressStep extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;

  const CheckoutAddressStep({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  @override
  ConsumerState<CheckoutAddressStep> createState() =>
      _CheckoutAddressStepState();
}

class _CheckoutAddressStepState extends ConsumerState<CheckoutAddressStep> {
  final _formKey = GlobalKey<FormState>();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  AddressResponse? _savedAddress;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _populateForm(AddressResponse address) {
    _streetCtrl.text = address.street;
    _cityCtrl.text = address.city;
    _postalCtrl.text = address.postalCode;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final service = ref.read(addressServiceProvider);
      final result = await service.upsertMyAddress(
        UpsertAddressRequest(
          street: _streetCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          postalCode: _postalCtrl.text.trim(),
        ),
      );
      ref.invalidate(addressProvider);
      if (mounted) {
        setState(() {
          _savedAddress = result;
          _isEditing = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Greska prilikom cuvanja adrese: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressAsync = ref.watch(addressProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Adresa dostave'),
                const SizedBox(height: AppSpacing.md),
                addressAsync.when(
                  loading: () => _loadingState(),
                  error: (_, _) => _addressForm(),
                  data: (address) {
                    if (_savedAddress == null &&
                        address != null &&
                        !_isEditing) {
                      _savedAddress = address;
                      _populateForm(address);
                    }
                    if (_savedAddress != null && !_isEditing) {
                      return _addressPreview(_savedAddress!);
                    }
                    if (address != null &&
                        !_isEditing &&
                        _savedAddress == null) {
                      _populateForm(address);
                    }
                    return _addressForm();
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        _bottomBar(),
      ],
    );
  }

  Widget _loadingState() {
    return const GlassCard(
      child: SizedBox(
        height: 80,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressPreview(AddressResponse address) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.street, style: AppTextStyles.bodyBold),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${address.postalCode} ${address.city}',
                      style: AppTextStyles.bodySm,
                    ),
                    Text(address.country, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _populateForm(address);
                  setState(() => _isEditing = true);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _textField(
            controller: _streetCtrl,
            label: 'Ulica i broj',
            hint: 'npr. Marsala Tita 5',
            icon: LucideIcons.home,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Unesite ulicu i broj'
                : (v.trim().length > 200
                      ? 'Ulica moze imati najvise 200 karaktera'
                      : null),
          ),
          const SizedBox(height: AppSpacing.lg),
          _textField(
            controller: _cityCtrl,
            label: 'Grad',
            hint: 'npr. Sarajevo',
            icon: LucideIcons.building2,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Unesite grad'
                : (v.trim().length > 100
                      ? 'Grad moze imati najvise 100 karaktera'
                      : null),
          ),
          const SizedBox(height: AppSpacing.lg),
          _textField(
            controller: _postalCtrl,
            label: 'Postanski broj',
            hint: 'npr. 71000',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Unesite postanski broj'
                : (v.trim().length > 20
                      ? 'Postanski broj moze imati najvise 20 karaktera'
                      : null),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Country (read-only)
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.globe,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Drzava', style: AppTextStyles.caption),
                      const SizedBox(height: AppSpacing.xs),
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
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isEditing = false),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text('Otkazi', style: AppTextStyles.buttonMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: 'Sacuvaj adresu',
                    icon: LucideIcons.save,
                    isLoading: _isSaving,
                    onPressed: _saveAddress,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
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
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  bool get _canProceed => _savedAddress != null && !_isEditing;

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onBack,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.arrowLeft,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Nazad', style: AppTextStyles.buttonMd),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: _canProceed
                ? GradientButton(
                    label: 'Nastavi na placanje',
                    icon: LucideIcons.arrowRight,
                    onPressed: widget.onNext,
                  )
                : GradientButton(
                    label: 'Sacuvaj adresu',
                    icon: LucideIcons.save,
                    isLoading: _isSaving,
                    onPressed: _saveAddress,
                  ),
          ),
        ],
      ),
    );
  }
}

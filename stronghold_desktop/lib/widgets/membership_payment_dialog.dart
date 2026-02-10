import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/list_state.dart';
import '../providers/membership_provider.dart';
import '../providers/membership_package_provider.dart';
import '../utils/error_handler.dart';
import 'date_picker_field.dart';

class MembershipPaymentDialog extends ConsumerStatefulWidget {
  const MembershipPaymentDialog({super.key, required this.user});
  final UserResponse user;

  @override
  ConsumerState<MembershipPaymentDialog> createState() => _State();
}

class _State extends ConsumerState<MembershipPaymentDialog> {
  MembershipPackageResponse? _selectedPackage;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipPackageListProvider.notifier).load();
    });
  }

  Future<void> _submit() async {
    if (_selectedPackage == null) {
      setState(() => _error = 'Molimo odaberite vrstu clanarine');
      return;
    }
    if (_startDate == null) {
      setState(() => _error = 'Molimo odaberite pocetak clanarine');
      return;
    }
    if (_endDate == null) {
      setState(() => _error = 'Molimo odaberite kraj clanarine');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(() => _error = 'Kraj clanarine mora biti nakon pocetka');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(membershipOperationsProvider.notifier)
          .assignMembership(AssignMembershipRequest(
            userId: widget.user.id,
            membershipPackageId: _selectedPackage!.id,
            amountPaid: _selectedPackage!.packagePrice,
            paymentDate: _startDate!,
            startDate: _startDate!,
            endDate: _endDate!,
          ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = ErrorHandler.getContextualMessage(e, 'add-payment');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(membershipPackageListProvider);
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                      child:
                          Text('Dodaj uplatu', style: AppTextStyles.headingMd)),
                  IconButton(
                    icon: Icon(LucideIcons.x,
                        color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xs),
                Text('Unesite detalje nove uplate za clana',
                    style: AppTextStyles.bodyMd),
                const SizedBox(height: AppSpacing.xl),
                _userCard(),
                const SizedBox(height: AppSpacing.xl),
                _buildForm(packagesAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userCard() => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.user.firstName} ${widget.user.lastName}',
                style: AppTextStyles.bodyBold.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            Text('@${widget.user.username}', style: AppTextStyles.bodySm),
          ],
        ),
      );

  Widget _buildForm(ListState<MembershipPackageResponse, MembershipPackageQueryFilter> packagesState) {
    if (packagesState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (packagesState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text('Greska: ${packagesState.error}',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
        ),
      );
    }
    final packages =
        packagesState.data?.items ?? <MembershipPackageResponse>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Vrsta clanarine :', style: AppTextStyles.bodySm),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MembershipPackageResponse>(
              value: _selectedPackage,
              hint: Text('Odaberite paket', style: AppTextStyles.bodyMd),
              isExpanded: true,
              dropdownColor: AppColors.surfaceSolid,
              items: packages
                  .map((pkg) => DropdownMenuItem(
                        value: pkg,
                        child: Text(
                          '${pkg.packageName ?? 'N/A'} - ${pkg.packagePrice.toStringAsFixed(2)} KM',
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPackage = v),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DatePickerField(
          label: 'Pocetak clanarine',
          value: _startDate,
          onChanged: (d) => setState(() => _startDate = d),
        ),
        const SizedBox(height: AppSpacing.xl),
        DatePickerField(
          label: 'Kraj clanarine',
          value: _endDate,
          onChanged: (d) => setState(() => _endDate = d),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Icon(LucideIcons.alertCircle, color: AppColors.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(_error!,
                    style:
                        AppTextStyles.bodySm.copyWith(color: AppColors.error)),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.background))
                : Text('Dodaj uplatu',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.background)),
          ),
        ),
      ],
    );
  }
}

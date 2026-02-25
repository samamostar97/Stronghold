import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/review_provider.dart';
import '../utils/error_handler.dart';
import 'gradient_button.dart';

class CreateReviewSheet extends ConsumerStatefulWidget {
  final VoidCallback onReviewCreated;
  final void Function(String message) onError;

  const CreateReviewSheet({
    super.key,
    required this.onReviewCreated,
    required this.onError,
  });

  @override
  ConsumerState<CreateReviewSheet> createState() =>
      _CreateReviewSheetState();
}

class _CreateReviewSheetState extends ConsumerState<CreateReviewSheet> {
  PurchasedSupplementResponse? _selectedSupplement;
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(availableSupplementsProvider.notifier).load());
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final supplement = _selectedSupplement;
    if (supplement == null || _rating == 0) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(createReviewProvider.notifier).create(
            supplementId: supplement.id,
            rating: _rating,
            comment: _commentCtrl.text.trim().isEmpty
                ? null
                : _commentCtrl.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        widget.onReviewCreated();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        widget.onError(ErrorHandler.message(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppState = ref.watch(availableSupplementsProvider);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl)),
          border: Border(
              top: BorderSide(color: AppColors.primary, width: 1)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                  child: Text('Nova recenzija',
                      style: AppTextStyles.headingMd)),
              const SizedBox(height: AppSpacing.xxl),
              if (suppState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxxl),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              else if (suppState.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(suppState.error!,
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center),
                  ),
                )
              else if (suppState.items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                        'Nemate suplemenata dostupnih za recenziju',
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center),
                  ),
                )
              else ...[
                Text('Suplement', style: AppTextStyles.bodyBold),
                const SizedBox(height: AppSpacing.sm),
                _supplementDropdown(suppState),
                const SizedBox(height: AppSpacing.xl),
                Text('Ocjena', style: AppTextStyles.bodyBold),
                const SizedBox(height: AppSpacing.sm),
                _ratingStars(),
                const SizedBox(height: AppSpacing.xl),
                Text('Komentar (opciono)',
                    style: AppTextStyles.bodyBold),
                const SizedBox(height: AppSpacing.sm),
                _commentField(),
                const SizedBox(height: AppSpacing.xxl),
                GradientButton(
                  label: 'Ostavi recenziju',
                  icon: LucideIcons.send,
                  isLoading: _isSubmitting,
                  onPressed:
                      (_selectedSupplement != null && _rating > 0)
                          ? _submit
                          : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _supplementDropdown(AvailableSupplementsState state) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PurchasedSupplementResponse>(
          value: _selectedSupplement,
          hint: Text('Odaberite suplement',
              style: AppTextStyles.bodyMd),
          isExpanded: true,
          dropdownColor: AppColors.surfaceLight,
          icon: const Icon(LucideIcons.chevronDown,
              color: AppColors.textMuted, size: 18),
          items: state.items.map((s) {
            return DropdownMenuItem<PurchasedSupplementResponse>(
              value: s,
              child:
                  Text(s.name, style: AppTextStyles.bodyBold),
            );
          }).toList(),
          onChanged: (value) =>
              setState(() => _selectedSupplement = value),
        ),
      ),
    );
  }

  Widget _ratingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = star),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs),
            child: Icon(
              LucideIcons.star,
              size: 36,
              color: star <= _rating
                  ? AppColors.warning
                  : AppColors.textDark,
            ),
          ),
        );
      }),
    );
  }

  Widget _commentField() {
    return TextField(
      controller: _commentCtrl,
      maxLines: 3,
      style:
          AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Napisite komentar...',
        hintStyle: AppTextStyles.bodyMd,
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:
              const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

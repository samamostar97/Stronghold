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
import '../providers/appointment_provider.dart';
import '../utils/date_format_utils.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/shared/surface_card.dart';
import '../widgets/time_slot_grid.dart';

enum StaffType { trainer, nutritionist }

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  StaffType? _selectedType;
  DateTime? _selectedDate;
  int? _selectedStaffId;
  String? _selectedStaffName;
  int? _selectedHour;
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.background,
            surface: AppColors.surfaceLight,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _selectedHour = null;
      });
    }
  }

  void _selectType(StaffType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      _selectedStaffId = null;
      _selectedStaffName = null;
      _selectedHour = null;
    });
  }

  void _selectStaff(_SelectableStaff staff) {
    setState(() {
      _selectedStaffId = staff.id;
      _selectedStaffName = staff.name;
      _selectedHour = null;
    });
  }

  Future<void> _submit() async {
    if (_selectedType == null ||
        _selectedDate == null ||
        _selectedHour == null ||
        _selectedStaffId == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedHour!,
      );
      final notifier = ref.read(bookAppointmentProvider.notifier);
      if (_selectedType == StaffType.trainer) {
        await notifier.bookTrainer(_selectedStaffId!, dt);
      } else {
        await notifier.bookNutritionist(_selectedStaffId!, dt);
      }
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      if (mounted) {
        await showSuccessFeedback(context, 'Termin je uspjesno zakazan');
        ref.read(myAppointmentsProvider.notifier).refresh();
        if (mounted) {
          context.go('/appointments');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        await showErrorFeedback(context, ErrorHandler.message(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = _staffAsync(ref);
    final hoursAsync = _hoursAsync(ref);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: Container(
                      width: AppSpacing.touchTarget,
                      height: AppSpacing.touchTarget,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text('Novi termin', style: AppTextStyles.headingMd),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _typeSelector()
                        .animate()
                        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                    const SizedBox(height: AppSpacing.lg),
                    _datePicker(),
                    const SizedBox(height: AppSpacing.lg),
                    _staffSection(staffAsync),
                    const SizedBox(height: AppSpacing.lg),
                    _hoursSection(hoursAsync),
                    const SizedBox(height: AppSpacing.lg),
                    _infoCard(),
                    const SizedBox(height: AppSpacing.xxxl),
                    GradientButton(
                      label: 'Napravi termin',
                      icon: LucideIcons.calendarCheck,
                      isLoading: _isSubmitting,
                      onPressed:
                          (_selectedType != null &&
                              _selectedDate != null &&
                              _selectedStaffId != null &&
                              _selectedHour != null)
                          ? _submit
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AsyncValue<List<_SelectableStaff>>? _staffAsync(WidgetRef ref) {
    return switch (_selectedType) {
      StaffType.trainer =>
        ref
            .watch(trainersProvider)
            .whenData(
              (items) => items
                  .map(
                    (t) => _SelectableStaff(
                      id: t.id,
                      name: t.fullName,
                      email: t.email,
                      phone: t.phoneNumber,
                      icon: LucideIcons.dumbbell,
                    ),
                  )
                  .toList(),
            ),
      StaffType.nutritionist =>
        ref
            .watch(nutritionistsProvider)
            .whenData(
              (items) => items
                  .map(
                    (n) => _SelectableStaff(
                      id: n.id,
                      name: n.fullName,
                      email: n.email,
                      phone: n.phoneNumber,
                      icon: LucideIcons.apple,
                    ),
                  )
                  .toList(),
            ),
      null => null,
    };
  }

  AsyncValue<List<int>>? _hoursAsync(WidgetRef ref) {
    if (_selectedDate == null ||
        _selectedStaffId == null ||
        _selectedType == null) {
      return null;
    }
    return switch (_selectedType!) {
      StaffType.trainer => ref.watch(
        trainerAvailableHoursProvider((
          trainerId: _selectedStaffId!,
          date: _selectedDate!,
        )),
      ),
      StaffType.nutritionist => ref.watch(
        nutritionistAvailableHoursProvider((
          nutritionistId: _selectedStaffId!,
          date: _selectedDate!,
        )),
      ),
    };
  }

  Widget _typeSelector() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Odaberite tip termina', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _typeOption(
                type: StaffType.trainer,
                label: 'Trening sa trenerom',
                icon: LucideIcons.dumbbell,
              ),
              _typeOption(
                type: StaffType.nutritionist,
                label: 'Nutricionista',
                icon: LucideIcons.apple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeOption({
    required StaffType type,
    required String label,
    required IconData icon,
  }) {
    final active = _selectedType == type;
    return InkWell(
      onTap: () => _selectType(type),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker() {
    return SurfaceCard(
      onTap: _selectDate,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              LucideIcons.calendar,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2. Odaberite datum', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _selectedDate != null
                      ? formatDateDDMMYYYY(_selectedDate!)
                      : 'Dodirnite da odaberete datum',
                  style: _selectedDate != null
                      ? AppTextStyles.bodyBold
                      : AppTextStyles.bodyMd,
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _staffSection(AsyncValue<List<_SelectableStaff>>? staffAsync) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('3. Odaberite osoblje', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          if (_selectedType == null)
            Text('Prvo odaberite tip termina.', style: AppTextStyles.bodyMd)
          else if (_selectedDate == null)
            Text(
              'Prvo odaberite datum termina, zatim izaberite osoblje.',
              style: AppTextStyles.bodyMd,
            )
          else if (staffAsync == null)
            const SizedBox.shrink()
          else
            staffAsync.when(
              loading: () => const SizedBox(
                height: 72,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (error, _) => AppErrorState(
                message: ErrorHandler.message(error),
                onRetry: () {
                  if (_selectedType == StaffType.trainer) {
                    ref.invalidate(trainersProvider);
                  } else {
                    ref.invalidate(nutritionistsProvider);
                  }
                },
              ),
              data: (staffList) {
                if (staffList.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.users,
                    title: 'Nema dostupnog osoblja',
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < staffList.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      _staffTile(staffList[i]),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _staffTile(_SelectableStaff staff) {
    final active = staff.id == _selectedStaffId;
    return InkWell(
      onTap: () => _selectStaff(staff),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                staff.icon,
                size: 17,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff.email,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    staff.phone,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (active)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Odabran',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _hoursSection(AsyncValue<List<int>>? hoursAsync) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('4. Odaberite slobodan termin', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.lg),
          if (_selectedDate == null ||
              _selectedStaffId == null ||
              _selectedType == null)
            Text(
              'Odaberite tip, datum i osoblje da se prikazu slobodni termini.',
              style: AppTextStyles.bodyMd,
            )
          else if (hoursAsync == null)
            const SizedBox.shrink()
          else
            hoursAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  ErrorHandler.message(error),
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (hours) {
                if (hours.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nema slobodnih termina za odabrani datum.',
                        style: AppTextStyles.bodyMd,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.calendarDays,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Promijeni datum',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return TimeSlotGrid(
                  hours: hours,
                  selectedHour: _selectedHour,
                  onHourSelected: (h) => setState(() => _selectedHour = h),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return SurfaceCard(
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _selectedStaffName == null
                  ? 'Termin traje 1 sat. Nakon odabira osoblja vidjet cete dostupne slotove za taj datum.'
                  : 'Odabrano osoblje: $_selectedStaffName. Termin traje 1 sat, a zakazivanje vrijedi za odabrani datum i sat.',
              style: AppTextStyles.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableStaff {
  final int id;
  final String name;
  final String email;
  final String phone;
  final IconData icon;

  const _SelectableStaff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.icon,
  });
}

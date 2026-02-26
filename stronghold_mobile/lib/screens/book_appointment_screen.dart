import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../utils/date_format_utils.dart';
import '../utils/error_handler.dart';
import '../widgets/feedback_dialog.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../widgets/section_header.dart';
import '../widgets/time_slot_grid.dart';

enum StaffType { trainer, nutritionist }

class BookAppointmentArgs {
  final int staffId;
  final String staffName;
  final StaffType staffType;
  const BookAppointmentArgs({
    required this.staffId,
    required this.staffName,
    required this.staffType,
  });
}

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final int staffId;
  final String staffName;
  final StaffType staffType;

  const BookAppointmentScreen({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.staffType,
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends ConsumerState<BookAppointmentScreen> {
  DateTime? _selectedDate;
  int? _selectedHour;
  bool _isSubmitting = false;

  bool get _isTrainer => widget.staffType == StaffType.trainer;

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
          dialogTheme:
              const DialogThemeData(backgroundColor: AppColors.surface),
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

  Future<void> _submit() async {
    if (_selectedDate == null || _selectedHour == null) return;
    setState(() => _isSubmitting = true);
    try {
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedHour!,
      );
      final notifier = ref.read(bookAppointmentProvider.notifier);
      if (_isTrainer) {
        await notifier.bookTrainer(widget.staffId, dt);
      } else {
        await notifier.bookNutritionist(widget.staffId, dt);
      }
      if (mounted) {
        await showSuccessFeedback(context, 'Uspjesno ste zakazali termin');
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        await showErrorFeedback(
            context, ErrorHandler.message(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoursAsync = _selectedDate != null
        ? _isTrainer
            ? ref.watch(trainerAvailableHoursProvider(
                (trainerId: widget.staffId, date: _selectedDate!)))
            : ref.watch(nutritionistAvailableHoursProvider(
                (nutritionistId: widget.staffId, date: _selectedDate!)))
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                    'Zakazi termin', style: AppTextStyles.headingMd.copyWith(color: Colors.white))),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _staffCard()
                      .animate()
                      .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                      .slideY(begin: 0.04, end: 0, duration: Motion.smooth, curve: Motion.curve),
                  const SizedBox(height: AppSpacing.xxl),
                  _datePicker(),
                  const SizedBox(height: AppSpacing.lg),
                  if (_selectedDate != null) ...[
                    _hoursSection(hoursAsync),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  _infoCard(),
                  const SizedBox(height: AppSpacing.xxxl),
                  GradientButton(
                    label: 'Zakazi termin',
                    icon: LucideIcons.calendarCheck,
                    isLoading: _isSubmitting,
                    onPressed:
                        (_selectedDate != null && _selectedHour != null)
                            ? _submit
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _staffCard() {
    return GlassCard(
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryDim,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Icon(
            _isTrainer ? LucideIcons.dumbbell : LucideIcons.apple,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isTrainer ? 'Trener' : 'Nutricionist',
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.staffName,
                style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _datePicker() {
    return GlassCard(
      onTap: _selectDate,
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryDim,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Icon(LucideIcons.calendar,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Odaberi datum', style: AppTextStyles.caption.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _selectedDate != null
                    ? formatDateDDMMYYYY(_selectedDate!)
                    : 'Nije odabran',
                style: _selectedDate != null
                    ? AppTextStyles.bodyBold.copyWith(color: Colors.white)
                    : AppTextStyles.bodyMd.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        const Icon(LucideIcons.chevronRight,
            color: Colors.white, size: 18),
      ]),
    );
  }

  Widget _hoursSection(AsyncValue<List<int>>? hoursAsync) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Odaberi sat', style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.lg),
          if (hoursAsync != null)
            hoursAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  ErrorHandler.message(error),
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
              ),
              data: (hours) => TimeSlotGrid(
                hours: hours,
                selectedHour: _selectedHour,
                onHourSelected: (h) => setState(() => _selectedHour = h),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return GlassCard(
      child: Row(children: [
        const Icon(LucideIcons.info,
            color: Colors.white, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Termini traju 1 sat (9:00 - 17:00). Mozete imati samo jedan termin dnevno.',
            style: AppTextStyles.bodySm.copyWith(color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

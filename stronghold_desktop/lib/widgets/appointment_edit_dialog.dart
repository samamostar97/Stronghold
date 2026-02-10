import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/trainer_provider.dart';
import '../providers/nutritionist_provider.dart';
import '../utils/error_handler.dart';
import 'date_picker_field.dart';

class AppointmentEditDialog extends ConsumerStatefulWidget {
  const AppointmentEditDialog({
    super.key,
    required this.appointment,
    required this.onUpdate,
  });

  final AdminAppointmentResponse appointment;
  final Future<void> Function(AdminUpdateAppointmentRequest) onUpdate;

  @override
  ConsumerState<AppointmentEditDialog> createState() => _State();
}

class _State extends ConsumerState<AppointmentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loading = true;

  List<TrainerResponse> _trainers = <TrainerResponse>[];
  List<NutritionistResponse> _nutritionists = <NutritionistResponse>[];

  late String _staffType;
  int? _selectedStaffId;
  late DateTime _selectedDate;
  int? _selectedHour;

  List<int> _availableHours = <int>[];
  bool _loadingHours = true;

  @override
  void initState() {
    super.initState();
    _staffType =
        widget.appointment.trainerId != null ? 'trainer' : 'nutritionist';
    _selectedStaffId =
        widget.appointment.trainerId ?? widget.appointment.nutritionistId;
    final localDate = widget.appointment.appointmentDate.toLocal();
    _selectedDate = DateTime(localDate.year, localDate.month, localDate.day);
    _selectedHour = localDate.hour;
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final trainerService = ref.read(trainerServiceProvider);
      final nutritionistService = ref.read(nutritionistServiceProvider);

      final results = await Future.wait([
        trainerService.getAll(TrainerQueryFilter(pageSize: 100)),
        nutritionistService.getAll(NutritionistQueryFilter(pageSize: 100)),
      ]);

      if (mounted) {
        setState(() {
          _trainers = (results[0] as PagedResult<TrainerResponse>).items;
          _nutritionists =
              (results[1] as PagedResult<NutritionistResponse>).items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    // Always fetch hours, even if dropdown loading failed
    _fetchAvailableHours();
  }

  Future<void> _fetchAvailableHours() async {
    if (_selectedStaffId == null) return;

    setState(() {
      _loadingHours = true;
      _availableHours = <int>[];
    });

    try {
      List<int> hours;
      if (_staffType == 'trainer') {
        final service = ref.read(trainerServiceProvider);
        hours =
            await service.getAvailableHours(_selectedStaffId!, _selectedDate);
      } else {
        final service = ref.read(nutritionistServiceProvider);
        hours =
            await service.getAvailableHours(_selectedStaffId!, _selectedDate);
      }

      // Always include the current appointment's hour since backend
      // allows updating the same slot (x.Id != id check)
      final currentHour = widget.appointment.appointmentDate.hour;
      final isSameStaff = (_staffType == 'trainer' &&
              _selectedStaffId == widget.appointment.trainerId) ||
          (_staffType == 'nutritionist' &&
              _selectedStaffId == widget.appointment.nutritionistId);
      final isSameDate = _selectedDate.year ==
              widget.appointment.appointmentDate.year &&
          _selectedDate.month == widget.appointment.appointmentDate.month &&
          _selectedDate.day == widget.appointment.appointmentDate.day;

      if (isSameStaff && isSameDate && !hours.contains(currentHour)) {
        hours = [...hours, currentHour]..sort();
      }

      if (mounted) {
        setState(() {
          _availableHours = hours;
          if (_selectedHour != null && !hours.contains(_selectedHour)) {
            _selectedHour = null;
          }
          _loadingHours = false;
        });
      }
    } catch (_) {
      // On error, fallback: show all working hours so user can still edit
      if (mounted) {
        setState(() {
          _availableHours =
              List<int>.generate(8, (i) => i + 9); // 9,10,...,16
          if (_selectedHour != null &&
              !_availableHours.contains(_selectedHour)) {
            _selectedHour = null;
          }
          _loadingHours = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStaffId == null || _selectedHour == null) return;

    final appointmentDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour!,
    );

    setState(() => _saving = true);
    try {
      await widget.onUpdate(AdminUpdateAppointmentRequest(
        trainerId: _staffType == 'trainer' ? _selectedStaffId : null,
        nutritionistId: _staffType == 'nutritionist' ? _selectedStaffId : null,
        appointmentDate: appointmentDate,
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(ErrorHandler.getContextualMessage(e, 'update-appointment'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: _loading
              ? const SizedBox(
                  height: 200,
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)))
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildUserInfo(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildStaffTypeToggle(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildStaffDropdown(),
                        const SizedBox(height: AppSpacing.lg),
                        DatePickerField(
                          label: 'Datum termina',
                          value: _selectedDate,
                          includeTime: false,
                          onChanged: (dt) {
                            setState(() => _selectedDate = dt);
                            _fetchAvailableHours();
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildHourPicker(),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Expanded(
          child: Text('Izmijeni termin', style: AppTextStyles.headingMd)),
      IconButton(
        icon: Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ]);
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.user, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            widget.appointment.userName,
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tip termina',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ToggleOption(
                label: 'Trener',
                selected: _staffType == 'trainer',
                onTap: () {
                  setState(() {
                    _staffType = 'trainer';
                    _selectedStaffId = null;
                    _selectedHour = null;
                    _availableHours = <int>[];
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ToggleOption(
                label: 'Nutricionista',
                selected: _staffType == 'nutritionist',
                onTap: () {
                  setState(() {
                    _staffType = 'nutritionist';
                    _selectedStaffId = null;
                    _selectedHour = null;
                    _availableHours = <int>[];
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaffDropdown() {
    final isTrainer = _staffType == 'trainer';
    final label = isTrainer ? 'Trener' : 'Nutricionista';

    return DropdownButtonFormField<int>(
      key: ValueKey(_staffType),
      value: _selectedStaffId,
      decoration: _dropdownDecoration(label),
      dropdownColor: AppColors.surfaceSolid,
      style: AppTextStyles.bodyBold,
      items: isTrainer
          ? _trainers
              .map((t) =>
                  DropdownMenuItem(value: t.id, child: Text(t.fullName)))
              .toList()
          : _nutritionists
              .map((n) =>
                  DropdownMenuItem(value: n.id, child: Text(n.fullName)))
              .toList(),
      onChanged: (value) {
        setState(() => _selectedStaffId = value);
        _fetchAvailableHours();
      },
      validator: (value) => value == null ? '$label je obavezan/na' : null,
    );
  }

  Widget _buildHourPicker() {
    if (_selectedStaffId == null) {
      return Text('Odaberite osoblje i datum za prikaz dostupnih termina',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted));
    }

    if (_loadingHours) {
      return const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)));
    }

    if (_availableHours.isEmpty) {
      return Text('Nema dostupnih termina za odabrani datum',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.error));
    }

    return DropdownButtonFormField<int>(
      key: ValueKey('$_staffType-$_selectedStaffId-$_selectedDate'),
      value: _selectedHour,
      decoration: _dropdownDecoration('Satnica'),
      dropdownColor: AppColors.surfaceSolid,
      style: AppTextStyles.bodyBold,
      items: _availableHours
          .map((h) => DropdownMenuItem(
                value: h,
                child: Text('${h.toString().padLeft(2, '0')}:00'),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedHour = value),
      validator: (value) => value == null ? 'Satnica je obavezna' : null,
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text('Odustani',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.background))
              : Text('Spremi',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.background)),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceSolid,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyBold.copyWith(
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

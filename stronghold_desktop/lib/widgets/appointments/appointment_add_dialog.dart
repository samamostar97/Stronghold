import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/trainer_provider.dart';
import '../../providers/nutritionist_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/error_handler.dart';
import '../shared/date_picker_field.dart';

class AppointmentAddDialog extends ConsumerStatefulWidget {
  const AppointmentAddDialog({super.key, required this.onCreate});
  final Future<void> Function(AdminCreateAppointmentRequest) onCreate;

  @override
  ConsumerState<AppointmentAddDialog> createState() => _State();
}

class _State extends ConsumerState<AppointmentAddDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loading = true;

  List<UserResponse> _users = <UserResponse>[];
  List<TrainerResponse> _trainers = <TrainerResponse>[];
  List<NutritionistResponse> _nutritionists = <NutritionistResponse>[];

  int? _selectedUserId;
  String _staffType = 'trainer';
  int? _selectedStaffId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int? _selectedHour;

  List<int> _availableHours = <int>[];
  bool _loadingHours = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final userService = ref.read(userServiceProvider);
      final trainerService = ref.read(trainerServiceProvider);
      final nutritionistService = ref.read(nutritionistServiceProvider);

      final results = await Future.wait([
        userService.getAll(UserQueryFilter(pageSize: 100)),
        trainerService.getAll(TrainerQueryFilter(pageSize: 100)),
        nutritionistService.getAll(NutritionistQueryFilter(pageSize: 100)),
      ]);

      if (mounted) {
        setState(() {
          _users = (results[0] as PagedResult<UserResponse>).items;
          _trainers = (results[1] as PagedResult<TrainerResponse>).items;
          _nutritionists =
              (results[2] as PagedResult<NutritionistResponse>).items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchAvailableHours() async {
    if (_selectedStaffId == null) return;

    setState(() {
      _loadingHours = true;
      _selectedHour = null;
      _availableHours = <int>[];
    });

    try {
      List<int> hours;
      if (_staffType == 'trainer') {
        final service = ref.read(trainerServiceProvider);
        hours = await service.getAvailableHours(_selectedStaffId!, _selectedDate);
      } else {
        final service = ref.read(nutritionistServiceProvider);
        hours = await service.getAvailableHours(_selectedStaffId!, _selectedDate);
      }
      if (mounted) {
        setState(() {
          _availableHours = hours;
          _loadingHours = false;
        });
      }
    } catch (_) {
      // On error, fallback: show all working hours so user can still create
      // Backend will validate the final choice anyway
      if (mounted) {
        setState(() {
          _availableHours =
              List<int>.generate(8, (i) => i + 9); // 9,10,...,16
          _loadingHours = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null || _selectedStaffId == null || _selectedHour == null) return;

    final appointmentDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour!,
    );

    setState(() => _saving = true);
    try {
      await widget.onCreate(AdminCreateAppointmentRequest(
        userId: _selectedUserId!,
        trainerId: _staffType == 'trainer' ? _selectedStaffId : null,
        nutritionistId: _staffType == 'nutritionist' ? _selectedStaffId : null,
        appointmentDate: appointmentDate,
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(ErrorHandler.getContextualMessage(e, 'create-appointment'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

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
                        _buildUserDropdown(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildStaffTypeToggle(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildStaffDropdown(),
                        const SizedBox(height: AppSpacing.lg),
                        DatePickerField(
                          label: 'Datum termina',
                          value: _selectedDate,
                          includeTime: false,
                          firstDate: tomorrow,
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
          child: Text('Dodaj termin', style: AppTextStyles.headingMd)),
      IconButton(
        icon: Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ]);
  }

  Widget _buildUserDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedUserId,
      decoration: _dropdownDecoration('Korisnik'),
      dropdownColor: AppColors.surfaceSolid,
      style: AppTextStyles.bodyBold,
      items: _users
          .map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName)))
          .toList(),
      onChanged: (value) => setState(() => _selectedUserId = value),
      validator: (value) => value == null ? 'Korisnik je obavezan' : null,
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
      initialValue: _selectedStaffId,
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
      initialValue: _selectedHour,
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
              : Text('Dodaj',
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

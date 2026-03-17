import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/seminar_response.dart';
import '../providers/seminars_provider.dart';

class SeminarFormModal extends ConsumerStatefulWidget {
  final SeminarResponse? seminar;

  const SeminarFormModal({super.key, this.seminar});

  @override
  ConsumerState<SeminarFormModal> createState() => _SeminarFormModalState();
}

class _SeminarFormModalState extends ConsumerState<SeminarFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _lecturer;
  late final TextEditingController _maxCapacity;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  bool _loading = false;

  bool get isEditing => widget.seminar != null;

  @override
  void initState() {
    super.initState();
    final s = widget.seminar;
    _name = TextEditingController(text: s?.name ?? '');
    _description = TextEditingController(text: s?.description ?? '');
    _lecturer = TextEditingController(text: s?.lecturer ?? '');
    _maxCapacity =
        TextEditingController(text: s != null ? '${s.maxCapacity}' : '');
    if (s != null) {
      _startDate = s.startDate;
      _startTime = TimeOfDay(hour: s.startDate.hour, minute: s.startDate.minute);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _lecturer.dispose();
    _maxCapacity.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.sidebar,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.sidebar,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null) {
      AppSnackbar.error(context, 'Odaberite datum i vrijeme seminara.');
      return;
    }

    setState(() => _loading = true);

    final startDate = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final repo = ref.read(seminarsRepositoryProvider);

      if (isEditing) {
        await repo.updateSeminar(
          id: widget.seminar!.id,
          name: _name.text.trim(),
          description: _description.text.trim(),
          lecturer: _lecturer.text.trim(),
          startDate: startDate,
          maxCapacity: int.parse(_maxCapacity.text.trim()),
        );
      } else {
        await repo.createSeminar(
          name: _name.text.trim(),
          description: _description.text.trim(),
          lecturer: _lecturer.text.trim(),
          startDate: startDate,
          maxCapacity: int.parse(_maxCapacity.text.trim()),
        );
      }

      ref.invalidate(seminarsProvider);

      if (mounted) {
        navigator.pop();
        AppSnackbar.successWithMessenger(
          messenger,
          isEditing
              ? 'Seminar uspjesno azuriran.'
              : 'Seminar uspjesno kreiran.',
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        AppSnackbar.errorWithMessenger(messenger, 'Greska: $e');
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
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
                        isEditing ? 'Uredi seminar' : 'Novi seminar',
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
                _buildField('Opis (opcionalno)', _description, maxLines: 2),
                const SizedBox(height: 14),
                _buildField('Predavac', _lecturer, required: true),
                const SizedBox(height: 14),

                // Date & Time row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Datum',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.06)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _startDate != null
                                    ? '${_startDate!.day}.${_startDate!.month}.${_startDate!.year}.'
                                    : 'Odaberi datum',
                                style: AppTextStyles.body
                                    .copyWith(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vrijeme',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.06)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _startTime != null
                                    ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Odaberi vrijeme',
                                style: AppTextStyles.body
                                    .copyWith(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildField('Maksimalni kapacitet', _maxCapacity,
                    required: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),

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
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEditing ? 'Sacuvaj' : 'Kreiraj',
                            style: AppTextStyles.button),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'date_picker_field.dart';
import 'dialog_text_field.dart';

class SeminarEditDialog extends StatefulWidget {
  const SeminarEditDialog({
    super.key,
    required this.seminar,
    required this.onUpdate,
  });

  final SeminarResponse seminar;
  final Future<void> Function(UpdateSeminarRequest) onUpdate;

  @override
  State<SeminarEditDialog> createState() => _State();
}

class _State extends State<SeminarEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topic;
  late final TextEditingController _speaker;
  late final TextEditingController _capacity;
  late DateTime _eventDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _topic = TextEditingController(text: widget.seminar.topic);
    _speaker = TextEditingController(text: widget.seminar.speakerName);
    _capacity = TextEditingController(
        text: widget.seminar.maxCapacity.toString());
    _eventDate = widget.seminar.eventDate;
  }

  @override
  void dispose() {
    _topic.dispose();
    _speaker.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onUpdate(UpdateSeminarRequest(
        topic: _topic.text.trim(),
        speakerName: _speaker.text.trim(),
        eventDate: _eventDate,
        maxCapacity: int.parse(_capacity.text.trim()),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(ErrorHandler.getContextualMessage(e, 'update-seminar'));
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text('Izmijeni seminar',
                            style: AppTextStyles.headingMd)),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  DialogTextField(
                      controller: _topic,
                      label: 'Naziv teme',
                      validator: (v) => Validators.stringLength(v, 2, 100)),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(
                      controller: _speaker,
                      label: 'Voditelj',
                      validator: (v) => Validators.stringLength(v, 2, 100)),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(
                      controller: _capacity,
                      label: 'Maksimalni kapacitet',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Kapacitet je obavezan';
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1 || n > 10000) {
                          return 'Unesite broj od 1 do 10000';
                        }
                        return null;
                      }),
                  const SizedBox(height: AppSpacing.lg),
                  DatePickerField(
                    label: 'Datum i satnica',
                    value: _eventDate,
                    includeTime: true,
                    onChanged: (dt) => setState(() => _eventDate = dt),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text('Odustani',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                              vertical: AppSpacing.md),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background))
                            : Text('Spremi',
                                style: AppTextStyles.bodyBold
                                    .copyWith(color: AppColors.background)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

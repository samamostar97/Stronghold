import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'dialog_text_field.dart';

/// Add / Edit dialog for FAQ entries. Pass [initial] to edit.
class FaqDialog extends StatefulWidget {
  const FaqDialog({super.key, this.initial, required this.onSave});

  final FaqResponse? initial;
  final Future<void> Function(String question, String answer) onSave;

  @override
  State<FaqDialog> createState() => _FaqDialogState();
}

class _FaqDialogState extends State<FaqDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _question;
  late final TextEditingController _answer;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.initial?.question ?? '');
    _answer = TextEditingController(text: widget.initial?.answer ?? '');
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(_question.text.trim(), _answer.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(ErrorHandler.getContextualMessage(e, 'faq'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEdit ? 'Izmijeni FAQ' : 'Dodaj FAQ',
                        style: AppTextStyles.headingMd,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                DialogTextField(
                  controller: _question,
                  label: 'Pitanje',
                  maxLines: 2,
                  validator: (v) => Validators.stringLength(v, 2, 500),
                ),
                const SizedBox(height: AppSpacing.lg),
                DialogTextField(
                  controller: _answer,
                  label: 'Odgovor',
                  maxLines: 4,
                  validator: (v) => Validators.stringLength(v, 2, 2000),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(
                        'Odustani',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Text(
                              'Spremi',
                              style: AppTextStyles.bodyBold.copyWith(
                                color: AppColors.background,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

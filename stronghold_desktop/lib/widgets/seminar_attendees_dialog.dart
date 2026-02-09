import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class SeminarAttendeesDialog extends StatefulWidget {
  const SeminarAttendeesDialog({
    super.key,
    required this.seminar,
    required this.service,
  });

  final SeminarResponse seminar;
  final SeminarService service;

  @override
  State<SeminarAttendeesDialog> createState() => _State();
}

class _State extends State<SeminarAttendeesDialog> {
  List<SeminarAttendeeResponse>? _attendees;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.service.getAttendees(widget.seminar.id);
      if (mounted) setState(() => _attendees = result);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.seminar;
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                  child: Text('Detalji seminara',
                      style: AppTextStyles.headingMd),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x,
                      color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _detailRow('Tema', s.topic),
              _detailRow('Voditelj', s.speakerName),
              _detailRow('Datum', DateFormat('dd.MM.yyyy').format(s.eventDate)),
              _detailRow('Vrijeme', DateFormat('HH:mm').format(s.eventDate)),
              _detailRow('Kapacitet',
                  '${s.currentAttendees}/${s.maxCapacity}'),
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppSpacing.lg),
              Flexible(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyBold),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: _load, child: const Text('Pokusaj ponovo')),
        ]),
      );
    }

    if (_attendees == null || _attendees!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.users, color: AppColors.textMuted, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text('Nema prijavljenih ucesnika',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textMuted)),
          ]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_attendees!.length} ucesnik/a',
            style: AppTextStyles.bodyBold
                .copyWith(color: AppColors.primary)),
        const SizedBox(height: AppSpacing.md),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _attendees!.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (_, i) {
                  final a = _attendees![i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDim,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(a.userName,
                            style: AppTextStyles.bodyBold),
                      ),
                      Text(
                        DateFormat('dd.MM.yyyy HH:mm')
                            .format(a.registeredAt),
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

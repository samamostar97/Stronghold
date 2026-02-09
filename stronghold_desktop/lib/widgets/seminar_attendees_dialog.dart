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
    required this.seminarId,
    required this.topic,
    required this.service,
  });

  final int seminarId;
  final String topic;
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
      final result = await widget.service.getAttendees(widget.seminarId);
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
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ucesnici seminara',
                          style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text(widget.topic,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x,
                      color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Flexible(child: _buildContent()),
            ],
          ),
        ),
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

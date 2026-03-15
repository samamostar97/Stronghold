import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../data/gym_repository.dart';
import '../models/gym_visit_response.dart';
import '../providers/gym_provider.dart';
import '../widgets/check_in_modal.dart';

class ActiveVisitsScreen extends ConsumerStatefulWidget {
  const ActiveVisitsScreen({super.key});

  @override
  ConsumerState<ActiveVisitsScreen> createState() => _ActiveVisitsScreenState();
}

class _ActiveVisitsScreenState extends ConsumerState<ActiveVisitsScreen> {
  int? _hoveredRow;

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime checkInAt) {
    final diff = DateTime.now().toUtc().difference(checkInAt);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}min';
    return '${minutes}min';
  }

  void _confirmCheckOut(GymVisitResponse visit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sidebar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Check-out', style: AppTextStyles.h3),
        content: Text(
          'Da li zelite odjaviti ${visit.userFullName} iz teretane?',
          style: AppTextStyles.body.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Otkazi',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final repo = ref.read(gymRepositoryProvider);
                await repo.checkOut(visitId: visit.id);
                ref.invalidate(activeVisitsProvider);
                ref.invalidate(visitHistoryProvider);
                if (mounted) {
                  AppSnackbar.success(context, '${visit.userFullName} uspjesno odjavljen/a.');
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.error(context, 'Greska: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Odjavi', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(activeVisitsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Trenutno u teretani',
                      style: AppTextStyles.h2)),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CheckInModal(),
                    );
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: Text('Check-in korisnika',
                      style: AppTextStyles.button.copyWith(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          visitsAsync.when(
            loading: () => Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
            error: (e, _) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Greska pri ucitavanju',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(activeVisitsProvider),
                      child: Text('Pokusaj ponovo',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
            data: (visits) => Container(
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        _HeaderCell('Korisnik', flex: 3),
                        _HeaderCell('Vrijeme dolaska', flex: 2),
                        _HeaderCell('Trajanje', flex: 2),
                        const SizedBox(width: 80),
                      ],
                    ),
                  ),
                  Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 1),

                  if (visits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text('Niko trenutno nije u teretani',
                            style: AppTextStyles.bodySmall),
                      ),
                    )
                  else
                    ...visits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final visit = entry.value;
                      final isHovered = _hoveredRow == index;

                      return MouseRegion(
                        onEnter: (_) =>
                            setState(() => _hoveredRow = index),
                        onExit: (_) =>
                            setState(() => _hoveredRow = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isHovered
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.transparent,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          visit.userFullName.isNotEmpty
                                              ? visit.userFullName
                                                  .split(' ')
                                                  .map((n) => n.isNotEmpty
                                                      ? n[0]
                                                      : '')
                                                  .take(2)
                                                  .join()
                                              : '?',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        visit.userFullName,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatTime(visit.checkInAt),
                                  style: AppTextStyles.body
                                      .copyWith(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _formatDuration(visit.checkInAt),
                                    style:
                                        AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _confirmCheckOut(visit),
                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor: AppColors
                                              .error
                                              .withValues(alpha: 0.12),
                                          foregroundColor:
                                              AppColors.error,
                                          elevation: 0,
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    6),
                                          ),
                                        ),
                                        child: Text('Odjavi',
                                            style: AppTextStyles
                                                .bodySmall
                                                .copyWith(
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: AppColors.error,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int? flex;

  const _HeaderCell(this.label, {this.flex});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTextStyles.label.copyWith(fontSize: 11),
    );
    return Expanded(flex: flex ?? 1, child: child);
  }
}

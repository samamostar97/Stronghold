import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/seminar_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/small_button.dart';
import '../widgets/seminars/seminar_add_dialog.dart';
import '../widgets/seminars/seminar_edit_dialog.dart';
import '../widgets/seminars/seminar_attendees_dialog.dart';
import '../utils/error_handler.dart';

class SeminarsScreen extends ConsumerStatefulWidget {
  const SeminarsScreen({super.key});

  @override
  ConsumerState<SeminarsScreen> createState() => _SeminarsScreenState();
}

class _SeminarsScreenState extends ConsumerState<SeminarsScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seminarListProvider.notifier).load();
    });
  }

  Future<void> _addSeminar() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SeminarAddDialog(
        onCreate: (request) async {
          await ref.read(seminarListProvider.notifier).create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editSeminar(SeminarResponse seminar) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SeminarEditDialog(
        seminar: seminar,
        onUpdate: (request) async {
          await ref
              .read(seminarListProvider.notifier)
              .update(seminar.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _viewDetails(SeminarResponse seminar) async {
    final action = await showDialog<String>(
      context: context,
      builder: (_) => SeminarAttendeesDialog(
        seminar: seminar,
        service: ref.read(seminarServiceProvider),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      _editSeminar(seminar);
    } else if (action == 'cancel') {
      _cancelSeminar(seminar);
    }
  }

  Future<void> _deleteSeminar(SeminarResponse seminar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati seminar "${seminar.topic}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(seminarListProvider.notifier).delete(seminar.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-seminar'),
        );
      }
    }
  }

  Future<void> _cancelSeminar(SeminarResponse seminar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda otkazivanja',
        message:
            'Jeste li sigurni da zelite otkazati seminar "${seminar.topic}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(seminarListProvider.notifier).cancelSeminar(seminar.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'cancel-seminar'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seminarListProvider);
    final notifier = ref.read(seminarListProvider.notifier);

    return CrudListScaffold<SeminarResponse, SeminarQueryFilter>(
          state: state,
          onRefresh: notifier.refresh,
          onSearch: notifier.setSearch,
          onSort: notifier.setOrderBy,
          onPageChanged: notifier.goToPage,
          onAdd: _addSeminar,
          searchHint: 'Pretrazi po temi ili voditelju...',
          addButtonText: '+ Dodaj seminar',
          loadingColumnFlex: const [3, 2, 2, 2, 1, 2, 2],
          extraFilter: _StatusFilter(
            value: _selectedStatus,
            onChanged: (v) {
              setState(() => _selectedStatus = v);
              notifier.setStatus(v);
            },
          ),
          sortOptions: const [
            SortOption(value: null, label: 'Zadano'),
            SortOption(value: 'topic', label: 'Tema (A-Z)'),
            SortOption(value: 'topicdesc', label: 'Tema (Z-A)'),
            SortOption(value: 'speakername', label: 'Voditelj (A-Z)'),
            SortOption(value: 'speakernamedesc', label: 'Voditelj (Z-A)'),
            SortOption(value: 'eventdate', label: 'Najstarije prvo'),
            SortOption(value: 'eventdatedesc', label: 'Najnovije prvo'),
            SortOption(value: 'maxcapacity', label: 'Kapacitet (manji)'),
            SortOption(value: 'maxcapacitydesc', label: 'Kapacitet (veci)'),
          ],
          tableBuilder: (items) => GenericDataTable<SeminarResponse>(
            items: items,
            columns: [
              ColumnDef.text(
                label: 'Naziv teme',
                flex: 3,
                value: (s) => s.topic,
                bold: true,
              ),
              ColumnDef.text(
                label: 'Voditelj',
                flex: 2,
                value: (s) => s.speakerName,
              ),
              ColumnDef<SeminarResponse>(
                label: 'Popunjenost',
                flex: 2,
                cellBuilder: (s) => _CapacityIndicator(
                  current: s.currentAttendees,
                  max: s.maxCapacity,
                ),
              ),
              ColumnDef.text(
                label: 'Datum',
                flex: 2,
                value: (s) => DateFormat('dd.MM.yyyy').format(s.eventDate),
              ),
              ColumnDef.text(
                label: 'Satnica',
                flex: 1,
                value: (s) => DateFormat('HH:mm').format(s.eventDate),
              ),
              ColumnDef<SeminarResponse>(
                label: 'Status',
                flex: 2,
                cellBuilder: (s) => Align(
                  alignment: Alignment.centerLeft,
                  child: switch (s.status.toLowerCase()) {
                    'cancelled' => const StatusPill(
                      label: 'Otkazan',
                      color: AppColors.error,
                    ),
                    'finished' => const StatusPill(
                      label: 'Zavrsen',
                      color: AppColors.textMuted,
                    ),
                    _ => const StatusPill(
                      label: 'Aktivan',
                      color: AppColors.success,
                    ),
                  },
                ),
              ),
              ColumnDef.actions(
                flex: 2,
                builder: (s) => [
                  SmallButton(
                    text: 'Detalji',
                    color: AppColors.primary,
                    onTap: () => _viewDetails(s),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SmallButton(
                    text: 'Obrisi',
                    color: AppColors.error,
                    onTap: () => _deleteSeminar(s),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: Motion.smooth,
          curve: Motion.curve,
        );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text('Status', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium,
          icon: Icon(LucideIcons.filter, color: AppColors.textMuted, size: 16),
          items: const [
            DropdownMenuItem<String?>(value: null, child: Text('Svi')),
            DropdownMenuItem<String?>(value: 'active', child: Text('Aktivni')),
            DropdownMenuItem<String?>(
              value: 'cancelled',
              child: Text('Otkazani'),
            ),
            DropdownMenuItem<String?>(
              value: 'finished',
              child: Text('Zavrseni'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CapacityIndicator extends StatelessWidget {
  const _CapacityIndicator({required this.current, required this.max});
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isFull = current >= max;
    final color = isFull
        ? AppColors.error
        : ratio > 0.8
        ? AppColors.warning
        : AppColors.success;

    return Text(
      '$current/$max',
      style: AppTextStyles.bodySm.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

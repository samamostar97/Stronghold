import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/seminar_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/seminars_table.dart';
import '../widgets/seminar_add_dialog.dart';
import '../widgets/seminar_edit_dialog.dart';
import '../widgets/seminar_attendees_dialog.dart';
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

  Widget _buildStatusFilter(SeminarListNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedStatus,
          hint: Text('Status', style: AppTextStyles.bodyMd),
          dropdownColor: AppColors.surfaceSolid,
          style: AppTextStyles.bodyBold,
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
          onChanged: (value) {
            setState(() => _selectedStatus = value);
            notifier.setStatus(value);
          },
        ),
      ),
    );
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
      extraFilter: _buildStatusFilter(notifier),
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
      tableBuilder: (items) => SeminarsTable(
        seminars: items,
        onViewDetails: _viewDetails,
        onDelete: _deleteSeminar,
      ),
    );
  }
}

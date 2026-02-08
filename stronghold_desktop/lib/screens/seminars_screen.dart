import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/seminar_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/seminars_table.dart';
import '../widgets/seminar_add_dialog.dart';
import '../widgets/seminar_edit_dialog.dart';
import '../utils/error_handler.dart';

class SeminarsScreen extends ConsumerStatefulWidget {
  const SeminarsScreen({super.key});

  @override
  ConsumerState<SeminarsScreen> createState() => _SeminarsScreenState();
}

class _SeminarsScreenState extends ConsumerState<SeminarsScreen> {
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
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-seminar'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seminarListProvider);
    final notifier = ref.read(seminarListProvider.notifier);

    return CrudListScaffold<SeminarResponse, SeminarQueryFilter>(
      title: 'Upravljanje seminarima',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addSeminar,
      searchHint: 'Pretrazi po temi ili voditelju...',
      addButtonText: '+ Dodaj seminar',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'topic', label: 'Tema (A-Z)'),
        SortOption(value: 'speakername', label: 'Voditelj (A-Z)'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => SeminarsTable(
        seminars: items,
        onEdit: _editSeminar,
        onDelete: _deleteSeminar,
      ),
    );
  }
}

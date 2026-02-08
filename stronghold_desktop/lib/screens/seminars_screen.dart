import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/seminar_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';

/// Refactored Seminars Screen using Riverpod + generic patterns
class SeminarsScreen extends ConsumerStatefulWidget {
  const SeminarsScreen({super.key});

  @override
  ConsumerState<SeminarsScreen> createState() => _SeminarsScreenState();
}

class _SeminarsScreenState extends ConsumerState<SeminarsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seminarListProvider.notifier).load();
    });
  }

  Future<void> _addSeminar() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddSeminarDialog(
        onCreate: (request) async {
          await ref.read(seminarListProvider.notifier).create(request);
        },
      ),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _editSeminar(SeminarResponse seminar) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditSeminarDialog(
        seminar: seminar,
        onUpdate: (request) async {
          await ref.read(seminarListProvider.notifier).update(seminar.id, request);
        },
      ),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _deleteSeminar(SeminarResponse seminar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati seminar "${seminar.topic}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(seminarListProvider.notifier).delete(seminar.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-seminar'));
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
      tableBuilder: (items) => _SeminarsTable(
        seminars: items,
        onEdit: _editSeminar,
        onDelete: _deleteSeminar,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SEMINARS TABLE
// -----------------------------------------------------------------------------

abstract class _Flex {
  static const int topic = 3;
  static const int speaker = 2;
  static const int date = 2;
  static const int time = 1;
  static const int actions = 2;
}

class _SeminarsTable extends StatelessWidget {
  const _SeminarsTable({
    required this.seminars,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SeminarResponse> seminars;
  final ValueChanged<SeminarResponse> onEdit;
  final ValueChanged<SeminarResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(
          children: [
            TableHeaderCell(text: 'Naziv teme', flex: _Flex.topic),
            TableHeaderCell(text: 'Voditelj', flex: _Flex.speaker),
            TableHeaderCell(text: 'Datum seminara', flex: _Flex.date),
            TableHeaderCell(text: 'Satnica', flex: _Flex.time),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: seminars.length,
      itemBuilder: (context, i) => _SeminarRow(
        seminar: seminars[i],
        isLast: i == seminars.length - 1,
        onEdit: () => onEdit(seminars[i]),
        onDelete: () => onDelete(seminars[i]),
      ),
    );
  }
}

class _SeminarRow extends StatelessWidget {
  const _SeminarRow({
    required this.seminar,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SeminarResponse seminar;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _formatDate(DateTime dt) => DateFormat('dd.MM.yyyy').format(dt);
  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: seminar.topic, flex: _Flex.topic),
          TableDataCell(text: seminar.speakerName, flex: _Flex.speaker),
          TableDataCell(text: _formatDate(seminar.eventDate), flex: _Flex.date),
          TableDataCell(text: _formatTime(seminar.eventDate), flex: _Flex.time),
          Expanded(
            flex: _Flex.actions,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallButton(text: 'Izmijeni', color: AppColors.editBlue, onTap: onEdit),
                const SizedBox(width: 8),
                SmallButton(text: 'Obrisi', color: AppColors.accent, onTap: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADD SEMINAR DIALOG
// -----------------------------------------------------------------------------

class _AddSeminarDialog extends StatefulWidget {
  const _AddSeminarDialog({required this.onCreate});

  final Future<void> Function(CreateSeminarRequest) onCreate;

  @override
  State<_AddSeminarDialog> createState() => _AddSeminarDialogState();
}

class _AddSeminarDialogState extends State<_AddSeminarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _speakerController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _topicController.dispose();
    _speakerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final eventDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final request = CreateSeminarRequest(
        topic: _topicController.text.trim(),
        speakerName: _speakerController.text.trim(),
        eventDate: eventDate,
      );

      await widget.onCreate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        final errorMessage = ErrorHandler.getContextualMessage(e, 'create-seminar');
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showErrorAnimation(context, message: errorMessage);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dodaj seminar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _topicController,
                    label: 'Naziv teme',
                    validator: (v) => Validators.stringLength(v, 2, 100),
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _speakerController,
                    label: 'Voditelj',
                    validator: (v) => Validators.stringLength(v, 2, 100),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Datum',
                          value: DateFormat('dd.MM.yyyy').format(_selectedDate),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'Satnica',
                          value: _selectedTime.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
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

// -----------------------------------------------------------------------------
// EDIT SEMINAR DIALOG
// -----------------------------------------------------------------------------

class _EditSeminarDialog extends StatefulWidget {
  const _EditSeminarDialog({
    required this.seminar,
    required this.onUpdate,
  });

  final SeminarResponse seminar;
  final Future<void> Function(UpdateSeminarRequest) onUpdate;

  @override
  State<_EditSeminarDialog> createState() => _EditSeminarDialogState();
}

class _EditSeminarDialogState extends State<_EditSeminarDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topicController;
  late final TextEditingController _speakerController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.seminar.topic);
    _speakerController = TextEditingController(text: widget.seminar.speakerName);
    _selectedDate = widget.seminar.eventDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.seminar.eventDate);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _speakerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final eventDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final request = UpdateSeminarRequest(
        topic: _topicController.text.trim(),
        speakerName: _speakerController.text.trim(),
        eventDate: eventDate,
      );

      await widget.onUpdate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        final errorMessage = ErrorHandler.getContextualMessage(e, 'update-seminar');
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showErrorAnimation(context, message: errorMessage);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Izmijeni seminar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _topicController,
                    label: 'Naziv teme',
                    validator: (v) => Validators.stringLength(v, 2, 100),
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _speakerController,
                    label: 'Voditelj',
                    validator: (v) => Validators.stringLength(v, 2, 100),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Datum',
                          value: DateFormat('dd.MM.yyyy').format(_selectedDate),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'Satnica',
                          value: _selectedTime.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
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

// -----------------------------------------------------------------------------
// DATE PICKER FIELD
// -----------------------------------------------------------------------------

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppColors.muted, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

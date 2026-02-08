import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/trainer_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';

/// Refactored Trainers Screen using Riverpod + generic patterns
class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({super.key});

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainerListProvider.notifier).load();
    });
  }

  Future<void> _addTrainer() async {
    final created = await showDialog<Object?>(
      context: context,
      builder: (_) => _AddTrainerDialog(
        onCreate: (request) async {
          await ref.read(trainerListProvider.notifier).create(request);
        },
      ),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    } else if (created is String && mounted) {
      showErrorAnimation(context, message: created);
    }
  }

  Future<void> _editTrainer(TrainerResponse trainer) async {
    final updated = await showDialog<Object?>(
      context: context,
      builder: (_) => _EditTrainerDialog(
        trainer: trainer,
        onUpdate: (request) async {
          await ref.read(trainerListProvider.notifier).update(trainer.id, request);
        },
      ),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    } else if (updated is String && mounted) {
      showErrorAnimation(context, message: updated);
    }
  }

  Future<void> _deleteTrainer(TrainerResponse trainer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati trenera "${trainer.fullName}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(trainerListProvider.notifier).delete(trainer.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-trainer'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainerListProvider);
    final notifier = ref.read(trainerListProvider.notifier);

    return CrudListScaffold<TrainerResponse, TrainerQueryFilter>(
      title: 'Upravljanje trenerima',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addTrainer,
      searchHint: 'Pretrazi po imenu ili prezimenu...',
      addButtonText: '+ Dodaj trenera',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'firstname', label: 'Ime (A-Z)'),
        SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => _TrainersTable(
        trainers: items,
        onEdit: _editTrainer,
        onDelete: _deleteTrainer,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TRAINERS TABLE
// -----------------------------------------------------------------------------

abstract class _Flex {
  static const int firstName = 2;
  static const int lastName = 2;
  static const int email = 2;
  static const int phone = 2;
  static const int actions = 2;
}

class _TrainersTable extends StatelessWidget {
  const _TrainersTable({
    required this.trainers,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TrainerResponse> trainers;
  final ValueChanged<TrainerResponse> onEdit;
  final ValueChanged<TrainerResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Ime', flex: _Flex.firstName),
            TableHeaderCell(text: 'Prezime', flex: _Flex.lastName),
            TableHeaderCell(text: 'Email', flex: _Flex.email),
            TableHeaderCell(text: 'Broj telefona', flex: _Flex.phone),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: trainers.length,
      itemBuilder: (context, i) => _TrainerRow(
        trainer: trainers[i],
        index: i,
        isLast: i == trainers.length - 1,
        onEdit: () => onEdit(trainers[i]),
        onDelete: () => onDelete(trainers[i]),
      ),
    );
  }
}

class _TrainerRow extends StatelessWidget {
  const _TrainerRow({
    required this.trainer,
    required this.index,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final TrainerResponse trainer;
  final int index;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      index: index,
      child: Row(
        children: [
          TableDataCell(text: trainer.firstName, flex: _Flex.firstName, bold: true),
          TableDataCell(text: trainer.lastName, flex: _Flex.lastName, bold: true),
          TableDataCell(text: trainer.email, flex: _Flex.email, muted: true),
          TableDataCell(text: trainer.phoneNumber, flex: _Flex.phone, muted: true),
          TableActionCell(
            flex: _Flex.actions,
            children: [
              SmallButton(text: 'Izmijeni', color: AppColors.editBlue, onTap: onEdit),
              const SizedBox(width: 8),
              SmallButton(text: 'Obrisi', color: AppColors.accent, onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADD TRAINER DIALOG
// -----------------------------------------------------------------------------

class _AddTrainerDialog extends StatefulWidget {
  const _AddTrainerDialog({required this.onCreate});

  final Future<void> Function(CreateTrainerRequest) onCreate;

  @override
  State<_AddTrainerDialog> createState() => _AddTrainerDialogState();
}

class _AddTrainerDialogState extends State<_AddTrainerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateTrainerRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await widget.onCreate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getContextualMessage(e, 'create-trainer');
        Navigator.of(context).pop(errorMessage);
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
                        'Dodaj trenera',
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
                  Row(
                    children: [
                      Expanded(
                        child: DialogTextField(
                          controller: _firstNameController,
                          label: 'Ime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      if (!v.contains('@')) return 'Unesite validan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _phoneController,
                    label: 'Broj telefona',
                    hint: '061 123 456',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      final phoneRegex = RegExp(r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$');
                      if (!phoneRegex.hasMatch(v)) return 'Format: 061 123 456';
                      return null;
                    },
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
// EDIT TRAINER DIALOG
// -----------------------------------------------------------------------------

class _EditTrainerDialog extends StatefulWidget {
  const _EditTrainerDialog({
    required this.trainer,
    required this.onUpdate,
  });

  final TrainerResponse trainer;
  final Future<void> Function(UpdateTrainerRequest) onUpdate;

  @override
  State<_EditTrainerDialog> createState() => _EditTrainerDialogState();
}

class _EditTrainerDialogState extends State<_EditTrainerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.trainer.firstName);
    _lastNameController = TextEditingController(text: widget.trainer.lastName);
    _emailController = TextEditingController(text: widget.trainer.email);
    _phoneController = TextEditingController(text: widget.trainer.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateTrainerRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await widget.onUpdate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getContextualMessage(e, 'update-trainer');
        Navigator.of(context).pop(errorMessage);
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
                        'Izmijeni trenera',
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
                  Row(
                    children: [
                      Expanded(
                        child: DialogTextField(
                          controller: _firstNameController,
                          label: 'Ime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      if (!v.contains('@')) return 'Unesite validan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _phoneController,
                    label: 'Broj telefona',
                    hint: '061 123 456',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      final phoneRegex = RegExp(r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$');
                      if (!phoneRegex.hasMatch(v)) return 'Format: 061 123 456';
                      return null;
                    },
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

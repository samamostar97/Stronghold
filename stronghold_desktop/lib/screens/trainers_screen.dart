import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/trainer_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/trainers/trainers_table.dart';
import '../widgets/trainers/trainer_add_dialog.dart';
import '../widgets/trainers/trainer_edit_dialog.dart';
import '../utils/error_handler.dart';

class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({super.key});

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainerListProvider.notifier).load();
    });
  }

  Future<void> _addTrainer() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => TrainerAddDialog(
        onCreate: (request) async {
          await ref.read(trainerListProvider.notifier).create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editTrainer(TrainerResponse trainer) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => TrainerEditDialog(
        trainer: trainer,
        onUpdate: (request) async {
          await ref
              .read(trainerListProvider.notifier)
              .update(trainer.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteTrainer(TrainerResponse trainer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati trenera "${trainer.fullName}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(trainerListProvider.notifier).delete(trainer.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-trainer'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainerListProvider);
    final notifier = ref.read(trainerListProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('Treneri', style: AppTextStyles.pageTitle),
              ),
              if (!state.isLoading)
                Text(
                  '${state.totalCount} ukupno',
                  style: AppTextStyles.caption,
                ),
            ],
          )
              .animate()
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.06,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: CrudListScaffold<TrainerResponse, TrainerQueryFilter>(
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
              SortOption(value: 'firstnamedesc', label: 'Ime (Z-A)'),
              SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
              SortOption(value: 'lastnamedesc', label: 'Prezime (Z-A)'),
              SortOption(value: 'createdat', label: 'Najstarije prvo'),
              SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
            ],
            tableBuilder: (items) => TrainersTable(
              trainers: items,
              onEdit: _editTrainer,
              onDelete: _deleteTrainer,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
      ],
    );
  }
}

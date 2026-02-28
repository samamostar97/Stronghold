import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../providers/nutritionist_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/appointments/appointment_add_dialog.dart';
import '../widgets/appointments/appointment_edit_dialog.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/small_button.dart';
import '../widgets/nutritionists/nutritionist_add_dialog.dart';
import '../widgets/nutritionists/nutritionist_edit_dialog.dart';
import '../widgets/shared/chrome_tab_bar.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/trainers/trainer_add_dialog.dart';
import '../widgets/trainers/trainer_edit_dialog.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (icon: LucideIcons.dumbbell, label: 'Treneri'),
    (icon: LucideIcons.apple, label: 'Nutricionisti'),
    (icon: LucideIcons.calendarCheck, label: 'Termini'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainerListProvider.notifier).load();
      ref.read(nutritionistListProvider.notifier).load();
      ref.read(appointmentListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _addNutritionist() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => NutritionistAddDialog(
        onCreate: (request) async {
          await ref.read(nutritionistListProvider.notifier).create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editNutritionist(NutritionistResponse nutritionist) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => NutritionistEditDialog(
        nutritionist: nutritionist,
        onUpdate: (request) async {
          await ref
              .read(nutritionistListProvider.notifier)
              .update(nutritionist.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteNutritionist(NutritionistResponse nutritionist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati nutricionistu "${nutritionist.fullName}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(nutritionistListProvider.notifier).delete(nutritionist.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-nutritionist'),
        );
      }
    }
  }

  Future<void> _addAppointment() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => AppointmentAddDialog(
        onCreate: (request) async {
          await ref.read(appointmentListProvider.notifier).create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editAppointment(AdminAppointmentResponse appointment) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => AppointmentEditDialog(
        appointment: appointment,
        onUpdate: (request) async {
          await ref
              .read(appointmentListProvider.notifier)
              .update(appointment.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteAppointment(AdminAppointmentResponse appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati termin korisnika "${appointment.userName}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(appointmentListProvider.notifier).delete(appointment.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-appointment'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.desktopPage,
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          top: chromeTabBarHeight - 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildTrainersTab(),
                                _buildNutritionistsTab(),
                                _buildAppointmentsTab(),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: chromeTabBarHeight,
                          child: ChromeTabBar(
                            controller: _tabController,
                            tabs: _tabs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
    );
  }

  Widget _buildTrainersTab() {
    final state = ref.watch(trainerListProvider);
    final notifier = ref.read(trainerListProvider.notifier);

    return CrudListScaffold<TrainerResponse, TrainerQueryFilter>(
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
      tableBuilder: (items) => GenericDataTable<TrainerResponse>(
        items: items,
        columns: [
          ColumnDef<TrainerResponse>(
            label: '',
            flex: 1,
            cellBuilder: (t) => Align(
              alignment: Alignment.centerLeft,
              child: AvatarWidget(
                initials: _initials(t.firstName, t.lastName),
                size: 32,
              ),
            ),
          ),
          ColumnDef.text(
            label: 'Ime i prezime',
            flex: 3,
            value: (t) => t.fullName,
            bold: true,
          ),
          ColumnDef.text(label: 'Email', flex: 3, value: (t) => t.email),
          ColumnDef.text(
            label: 'Telefon',
            flex: 2,
            value: (t) => t.phoneNumber,
          ),
          ColumnDef.actions(
            flex: 2,
            builder: (t) => [
              SmallButton(
                text: 'Izmijeni',
                color: AppColors.secondary,
                onTap: () => _editTrainer(t),
              ),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                text: 'Obrisi',
                color: AppColors.error,
                onTap: () => _deleteTrainer(t),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionistsTab() {
    final state = ref.watch(nutritionistListProvider);
    final notifier = ref.read(nutritionistListProvider.notifier);

    return CrudListScaffold<NutritionistResponse, NutritionistQueryFilter>(
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addNutritionist,
      searchHint: 'Pretrazi po imenu ili prezimenu...',
      addButtonText: '+ Dodaj nutricionistu',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'firstname', label: 'Ime (A-Z)'),
        SortOption(value: 'firstnamedesc', label: 'Ime (Z-A)'),
        SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
        SortOption(value: 'lastnamedesc', label: 'Prezime (Z-A)'),
        SortOption(value: 'createdat', label: 'Najstarije prvo'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => GenericDataTable<NutritionistResponse>(
        items: items,
        columns: [
          ColumnDef<NutritionistResponse>(
            label: '',
            flex: 1,
            cellBuilder: (n) => Align(
              alignment: Alignment.centerLeft,
              child: AvatarWidget(
                initials: _initials(n.firstName, n.lastName),
                size: 32,
              ),
            ),
          ),
          ColumnDef.text(
            label: 'Ime i prezime',
            flex: 3,
            value: (n) => n.fullName,
            bold: true,
          ),
          ColumnDef.text(label: 'Email', flex: 3, value: (n) => n.email),
          ColumnDef.text(
            label: 'Telefon',
            flex: 2,
            value: (n) => n.phoneNumber,
          ),
          ColumnDef.actions(
            flex: 2,
            builder: (n) => [
              SmallButton(
                text: 'Izmijeni',
                color: AppColors.secondary,
                onTap: () => _editNutritionist(n),
              ),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                text: 'Obrisi',
                color: AppColors.error,
                onTap: () => _deleteNutritionist(n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    final state = ref.watch(appointmentListProvider);
    final notifier = ref.read(appointmentListProvider.notifier);

    return CrudListScaffold<AdminAppointmentResponse, AppointmentQueryFilter>(
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addAppointment,
      searchHint: 'Pretrazi po korisniku, treneru...',
      addButtonText: '+ Dodaj termin',
      loadingColumnFlex: const [3, 2, 3, 2, 1, 2],
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'datedesc', label: 'Najnovije'),
        SortOption(value: 'date', label: 'Najstarije'),
        SortOption(value: 'user', label: 'Korisnik (A-Z)'),
        SortOption(value: 'userdesc', label: 'Korisnik (Z-A)'),
      ],
      tableBuilder: (items) => GenericDataTable<AdminAppointmentResponse>(
        items: items,
        columns: [
          ColumnDef.text(
            label: 'Korisnik',
            flex: 3,
            value: (a) => a.userName,
            bold: true,
          ),
          ColumnDef<AdminAppointmentResponse>(
            label: 'Tip',
            flex: 2,
            cellBuilder: (a) => _TypeChip(type: a.type),
          ),
          ColumnDef.text(
            label: 'Osoblje',
            flex: 3,
            value: (a) => a.trainerName ?? a.nutritionistName ?? '-',
          ),
          ColumnDef.text(
            label: 'Datum',
            flex: 2,
            value: (a) => DateFormat('dd.MM.yyyy').format(a.appointmentDate),
            muted: (a) => a.appointmentDate.isBefore(DateTime.now()),
          ),
          ColumnDef.text(
            label: 'Satnica',
            flex: 1,
            value: (a) => DateFormat('HH:mm').format(a.appointmentDate),
            muted: (a) => a.appointmentDate.isBefore(DateTime.now()),
          ),
          ColumnDef.actions(
            flex: 2,
            builder: (a) => [
              SmallButton(
                text: 'Izmijeni',
                color: AppColors.secondary,
                onTap: () => _editAppointment(a),
              ),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                text: 'Obrisi',
                color: AppColors.error,
                onTap: () => _deleteAppointment(a),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final isTrainer = type == 'Trener';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (isTrainer ? AppColors.primary : AppColors.accent).withValues(
            alpha: 0.15,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isTrainer ? AppColors.primary : AppColors.accent,
          ),
        ),
      ),
    );
  }
}

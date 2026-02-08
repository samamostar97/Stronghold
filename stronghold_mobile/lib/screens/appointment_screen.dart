import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/date_format_utils.dart';
import '../models/appointment_models.dart';
import '../providers/appointment_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  final Set<int> _cancelingIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(myAppointmentsProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(myAppointmentsProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasNextPage) {
      ref.read(myAppointmentsProvider.notifier).nextPage();
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    setState(() {
      _cancelingIds.add(appointmentId);
    });

    try {
      await ref.read(myAppointmentsProvider.notifier).cancel(appointmentId);
      if (mounted) {
        setState(() {
          _cancelingIds.remove(appointmentId);
        });
        await showSuccessFeedback(context, 'Uspjesno ste otkazali termin');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cancelingIds.remove(appointmentId);
        });
        await showErrorFeedback(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(myAppointmentsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Termini',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildContent(appointmentState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MyAppointmentsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }

    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(myAppointmentsProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Nemate zakazanih termina',
        subtitle: 'Vasi nadolazeci termini ce se prikazati ovdje',
      );
    }

    return _buildAppointmentList(state);
  }

  Widget _buildAppointmentList(MyAppointmentsState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(myAppointmentsProvider.notifier).refresh(),
      color: const Color(0xFFe63946),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoading && state.items.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFFe63946)),
              ),
            );
          }
          return _buildAppointmentCard(state.items[index]);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isTrainer = appointment.trainerName != null;
    final personName = isTrainer ? appointment.trainerName : appointment.nutritionistName;
    final personType = isTrainer ? 'Trener' : 'Nutricionist';
    final icon = isTrainer ? Icons.fitness_center : Icons.restaurant_menu;
    final isCancelLoading = _cancelingIds.contains(appointment.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe63946).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFe63946),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      personName ?? 'Nepoznato',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Datum: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                formatDateDDMMYYYY(appointment.appointmentDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: isCancelLoading ? null : () => _cancelAppointment(appointment.id),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isCancelLoading
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCancelLoading
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isCancelLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Otkazi termin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

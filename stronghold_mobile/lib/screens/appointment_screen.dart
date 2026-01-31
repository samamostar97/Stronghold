import 'package:flutter/material.dart';
import '../utils/date_format_utils.dart';
import '../models/appointment_models.dart';
import '../services/appointment_service.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<Appointment>? _appointments;
  bool _isLoading = true;
  String? _error;
  final Set<int> _cancelingIds = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointments = await AppointmentService.getAppointments();
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    setState(() {
      _cancelingIds.add(appointmentId);
    });

    try {
      await AppointmentService.cancelAppointment(appointmentId);
      if (mounted) {
        setState(() {
          _cancelingIds.remove(appointmentId);
        });
        await _showSuccessFeedback('Uspjesno ste otkazali termin');
        await _loadAppointments();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cancelingIds.remove(appointmentId);
        });
        await _showErrorFeedback(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _showSuccessFeedback(String message) async {
    await showSuccessFeedback(context, message);
  }

  Future<void> _showErrorFeedback(String message) async {
    await showErrorFeedback(context, message);
  }

  @override
  Widget build(BuildContext context) {
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
                child: _buildContent(),
              ),
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoadingIndicator();
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _loadAppointments);
    }

    if (_appointments == null || _appointments!.isEmpty) {
      return const AppEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Nemate zakazanih termina',
        subtitle: 'Vasi nadolazeci termini ce se prikazati ovdje',
      );
    }

    return _buildAppointmentList();
  }

  Widget _buildAppointmentList() {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: const Color(0xFFe63946),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments!.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(_appointments![index]);
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

  Widget _buildBookButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // Placeholder - will implement booking logic later
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFe63946),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Zakazi novi termin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

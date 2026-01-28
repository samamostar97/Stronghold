import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_models.dart';
import '../services/appointment_service.dart';

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
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FeedbackDialog(
          isSuccess: true,
          message: message,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _showErrorFeedback(String message) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FeedbackDialog(
          isSuccess: false,
          message: message,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
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
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFe63946),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_appointments == null || _appointments!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAppointmentList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadAppointments,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pokusaj ponovo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nemate zakazanih termina',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vasi nadolazeci termini ce se prikazati ovdje',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
                _formatDate(appointment.appointmentDate),
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

class _FeedbackDialog extends StatefulWidget {
  final bool isSuccess;
  final String message;

  const _FeedbackDialog({
    required this.isSuccess,
    required this.message,
  });

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFe63946);
    final icon = widget.isSuccess ? Icons.check_rounded : Icons.close_rounded;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

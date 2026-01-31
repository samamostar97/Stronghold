import 'package:flutter/material.dart';
import '../models/appointment_models.dart';
import '../services/appointment_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';
import 'book_appointment_screen.dart';

class TrainerListScreen extends StatefulWidget {
  const TrainerListScreen({super.key});

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  List<Trainer>? _trainers;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final trainers = await AppointmentService.getTrainers();
      if (mounted) {
        setState(() {
          _trainers = trainers;
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
          'Treneri',
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
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoadingIndicator();
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _loadTrainers);
    }

    if (_trainers == null || _trainers!.isEmpty) {
      return const AppEmptyState(
        icon: Icons.fitness_center,
        title: 'Nema dostupnih trenera',
      );
    }

    return _buildTrainerList();
  }

  Widget _buildTrainerList() {
    return RefreshIndicator(
      onRefresh: _loadTrainers,
      color: const Color(0xFFe63946),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trainers!.length,
        itemBuilder: (context, index) {
          return _buildTrainerCard(_trainers![index]);
        },
      ),
    );
  }

  Widget _buildTrainerCard(Trainer trainer) {
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFFe63946),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  trainer.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                trainer.phoneNumber,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trainer.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookAppointmentScreen(
                      staffId: trainer.id,
                      staffName: trainer.fullName,
                      staffType: StaffType.trainer,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Napravi termin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

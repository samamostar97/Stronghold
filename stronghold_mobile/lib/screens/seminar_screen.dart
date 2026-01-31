import 'package:flutter/material.dart';
import '../utils/date_format_utils.dart';
import '../models/seminar.dart';
import '../services/seminar_service.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class SeminarScreen extends StatefulWidget {
  const SeminarScreen({super.key});

  @override
  State<SeminarScreen> createState() => _SeminarScreenState();
}

class _SeminarScreenState extends State<SeminarScreen> {
  List<Seminar>? _seminars;
  bool _isLoading = true;
  String? _error;
  final Set<int> _attendingIds = {};
  final Set<int> _cancelingIds = {};

  @override
  void initState() {
    super.initState();
    _loadSeminars();
  }

  Future<void> _loadSeminars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final seminars = await SeminarService.getSeminars();
      if (mounted) {
        setState(() {
          _seminars = seminars;
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

  Future<void> _attendSeminar(int seminarId) async {
    setState(() {
      _attendingIds.add(seminarId);
    });

    try {
      await SeminarService.attendSeminar(seminarId);
      if (mounted) {
        setState(() {
          _attendingIds.remove(seminarId);
        });
        await _showSuccessFeedback('Uspjesno ste se prijavili na seminar');
        await _loadSeminars();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _attendingIds.remove(seminarId);
        });
        await _showErrorFeedback(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _cancelAttendance(int seminarId) async {
    setState(() {
      _cancelingIds.add(seminarId);
    });

    try {
      await SeminarService.cancelAttendance(seminarId);
      if (mounted) {
        setState(() {
          _cancelingIds.remove(seminarId);
        });
        await _showSuccessFeedback('Uspjesno ste se odjavili sa seminara');
        await _loadSeminars();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cancelingIds.remove(seminarId);
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
          'Seminari',
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
      return AppErrorState(message: _error!, onRetry: _loadSeminars);
    }

    if (_seminars == null || _seminars!.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_outlined,
        title: 'Nema dostupnih seminara',
      );
    }

    return _buildSeminarList();
  }

  Widget _buildSeminarList() {
    return RefreshIndicator(
      onRefresh: _loadSeminars,
      color: const Color(0xFFe63946),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seminars!.length,
        itemBuilder: (context, index) {
          return _buildSeminarCard(_seminars![index]);
        },
      ),
    );
  }

  Widget _buildSeminarCard(Seminar seminar) {
    final isAttendLoading = _attendingIds.contains(seminar.id);
    final isCancelLoading = _cancelingIds.contains(seminar.id);
    final isAlreadyRegistered = seminar.isAttending;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  seminar.topic,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isAlreadyRegistered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Prijavljen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Predavac: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Expanded(
                child: Text(
                  seminar.speakerName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                formatDateDDMMYYYY(seminar.eventDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isAlreadyRegistered)
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isCancelLoading ? null : () => _cancelAttendance(seminar.id),
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
                            'Odjavi se',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isAttendLoading ? null : () => _attendSeminar(seminar.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isAttendLoading
                        ? const Color(0xFFe63946).withValues(alpha: 0.5)
                        : const Color(0xFFe63946),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isAttendLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Prijavi se',
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

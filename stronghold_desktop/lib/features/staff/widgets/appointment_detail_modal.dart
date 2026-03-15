import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/appointment_response.dart';
import '../providers/appointments_provider.dart';

class AppointmentDetailModal extends ConsumerStatefulWidget {
  final AppointmentResponse appointment;

  const AppointmentDetailModal({super.key, required this.appointment});

  @override
  ConsumerState<AppointmentDetailModal> createState() =>
      _AppointmentDetailModalState();
}

class _AppointmentDetailModalState
    extends ConsumerState<AppointmentDetailModal> {
  bool _loading = false;

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Na cekanju';
      case 'Approved':
        return 'Odobreno';
      case 'Rejected':
        return 'Odbijeno';
      case 'Completed':
        return 'Zavrseno';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Approved':
        return AppColors.info;
      case 'Rejected':
        return AppColors.error;
      case 'Completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _staffTypeLabel(String type) {
    switch (type) {
      case 'Trainer':
        return 'Trener';
      case 'Nutritionist':
        return 'Nutricionist';
      default:
        return type;
    }
  }

  Future<void> _performAction(Future<void> Function() action, String successMessage) async {
    setState(() => _loading = true);
    try {
      await action();
      ref.invalidate(appointmentsProvider);
      ref.invalidate(appointmentHistoryProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, successMessage);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Greska: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;
    final status = apt.status;

    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Termin #${apt.id}',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),
              const SizedBox(height: 20),

              // Info
              _InfoRow(label: 'Korisnik', value: apt.userName),
              const SizedBox(height: 12),
              _InfoRow(label: 'Osoblje', value: apt.staffName),
              const SizedBox(height: 12),
              _InfoRow(
                  label: 'Tip osoblja',
                  value: _staffTypeLabel(apt.staffType)),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Zakazano za',
                value:
                    '${apt.scheduledAt.day}.${apt.scheduledAt.month}.${apt.scheduledAt.year}. '
                    '${apt.scheduledAt.hour.toString().padLeft(2, '0')}:${apt.scheduledAt.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                  label: 'Trajanje', value: '${apt.durationMinutes} min'),
              if (apt.notes != null && apt.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(label: 'Napomena', value: apt.notes!),
              ],

              // Action buttons
              if (status == 'Pending' || status == 'Approved') ...[
                const SizedBox(height: 24),
                Divider(
                    color: Colors.white.withValues(alpha: 0.06), height: 1),
                const SizedBox(height: 20),

                if (status == 'Pending')
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () => _performAction(
                                      () => ref
                                          .read(appointmentsRepositoryProvider)
                                          .approveAppointment(apt.id),
                                      'Termin #${apt.id} je odobren.',
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Odobri', style: AppTextStyles.button),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _loading
                                ? null
                                : () => _performAction(
                                      () => ref
                                          .read(appointmentsRepositoryProvider)
                                          .rejectAppointment(apt.id),
                                      'Termin #${apt.id} je odbijen.',
                                    ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                  color:
                                      AppColors.error.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Odbij',
                                style: AppTextStyles.button
                                    .copyWith(color: AppColors.error)),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (status == 'Approved')
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () => _performAction(
                                () => ref
                                    .read(appointmentsRepositoryProvider)
                                    .completeAppointment(apt.id),
                                'Termin #${apt.id} je zavrsen.',
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Zavrsi termin',
                              style: AppTextStyles.button),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

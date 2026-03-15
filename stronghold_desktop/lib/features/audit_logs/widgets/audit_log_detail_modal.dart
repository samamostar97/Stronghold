import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/audit_log_response.dart';
import '../providers/audit_logs_provider.dart';

class AuditLogDetailModal extends ConsumerStatefulWidget {
  final AuditLogResponse log;

  const AuditLogDetailModal({super.key, required this.log});

  @override
  ConsumerState<AuditLogDetailModal> createState() =>
      _AuditLogDetailModalState();
}

class _AuditLogDetailModalState extends ConsumerState<AuditLogDetailModal> {
  bool _loading = false;

  String _entityTypeLabel(String type) {
    switch (type) {
      case 'User':
        return 'Korisnik';
      case 'Staff':
        return 'Osoblje';
      case 'Product':
        return 'Proizvod';
      case 'ProductCategory':
        return 'Kategorija';
      case 'Supplier':
        return 'Dobavljac';
      case 'MembershipPackage':
        return 'Paket clanarine';
      case 'UserMembership':
        return 'Clanarina';
      case 'Order':
        return 'Narudzba';
      case 'Appointment':
        return 'Termin';
      case 'Review':
        return 'Recenzija';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}. '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatSnapshot(String snapshot) {
    try {
      final parsed = jsonDecode(snapshot);
      return const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (_) {
      return snapshot;
    }
  }

  String _remainingTime() {
    final remaining = widget.log.canUndoUntil.difference(DateTime.now());
    if (remaining.isNegative) return 'Isteklo';
    final minutes = remaining.inMinutes;
    if (minutes < 1) return 'Manje od minute';
    return '$minutes min';
  }

  Future<void> _undoDelete() async {
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final repo = ref.read(auditLogsRepositoryProvider);
      await repo.undoDelete(widget.log.id);
      ref.invalidate(auditLogsProvider);
      if (mounted) {
        navigator.pop();
        AppSnackbar.successWithMessenger(
          messenger,
          '${_entityTypeLabel(widget.log.entityType)} #${widget.log.entityId} je uspjesno vracen.',
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        AppSnackbar.errorWithMessenger(messenger, 'Greska: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = widget.log;

    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 700),
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
                      'Brisanje: ${_entityTypeLabel(log.entityType)} #${log.entityId}',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: log.canUndo
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.textSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.canUndo ? 'Moze se vratiti' : 'Isteklo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: log.canUndo
                            ? AppColors.warning
                            : AppColors.textSecondary,
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
              _InfoRow(label: 'Akcija', value: 'Brisanje'),
              const SizedBox(height: 10),
              _InfoRow(
                  label: 'Tip entiteta',
                  value: _entityTypeLabel(log.entityType)),
              const SizedBox(height: 10),
              _InfoRow(label: 'ID entiteta', value: '#${log.entityId}'),
              const SizedBox(height: 10),
              _InfoRow(label: 'Admin', value: log.adminUsername),
              const SizedBox(height: 10),
              _InfoRow(label: 'Datum brisanja', value: _formatDate(log.createdAt)),
              const SizedBox(height: 10),
              _InfoRow(
                  label: 'Undo istice',
                  value:
                      '${_formatDate(log.canUndoUntil)} (${_remainingTime()})'),

              const SizedBox(height: 20),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),
              const SizedBox(height: 16),

              // Snapshot header
              Text('Stanje prije brisanja',
                  style: AppTextStyles.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 12),

              // Snapshot content
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _formatSnapshot(log.entitySnapshot),
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Undo button
              if (log.canUndo) ...[
                const SizedBox(height: 20),
                Divider(
                    color: Colors.white.withValues(alpha: 0.06), height: 1),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _undoDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
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
                        : Text('Vrati obrisani entitet',
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

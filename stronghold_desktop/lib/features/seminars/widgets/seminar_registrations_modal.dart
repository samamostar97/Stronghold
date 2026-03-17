import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/seminar_response.dart';
import '../providers/seminars_provider.dart';

class SeminarRegistrationsModal extends ConsumerWidget {
  final SeminarResponse seminar;

  const SeminarRegistrationsModal({super.key, required this.seminar});

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}. '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationsFuture = ref.read(seminarsRepositoryProvider)
        .getRegistrations(seminar.id);

    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(seminar.name, style: AppTextStyles.h2),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Predavac: ${seminar.lecturer}',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                'Datum: ${_formatDate(seminar.startDate)}',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                'Kapacitet: ${seminar.registeredCount}/${seminar.maxCapacity}',
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: 16),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),
              const SizedBox(height: 16),

              Text('Prijavljeni korisnici',
                  style: AppTextStyles.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 12),

              Flexible(
                child: FutureBuilder<List<SeminarRegistrationResponse>>(
                  future: registrationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary)),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Greska pri ucitavanju',
                            style: AppTextStyles.bodySmall),
                      );
                    }

                    final registrations = snapshot.data ?? [];

                    if (registrations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Nema prijavljenih korisnika',
                              style: AppTextStyles.bodySmall),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: registrations.length,
                      separatorBuilder: (_, _) => Divider(
                          color: Colors.white.withValues(alpha: 0.04),
                          height: 1),
                      itemBuilder: (context, index) {
                        final r = registrations[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  r.userFullName.isNotEmpty
                                      ? r.userFullName[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.userFullName,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(fontSize: 13)),
                                    Text(r.userEmail,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(_formatDate(r.createdAt),
                                  style: AppTextStyles.bodySmall
                                      .copyWith(fontSize: 11)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

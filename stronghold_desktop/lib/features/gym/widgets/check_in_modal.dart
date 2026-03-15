import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../data/gym_repository.dart';
import '../models/eligible_member_response.dart';
import '../providers/gym_provider.dart';

class CheckInModal extends ConsumerStatefulWidget {
  const CheckInModal({super.key});

  @override
  ConsumerState<CheckInModal> createState() => _CheckInModalState();
}

class _CheckInModalState extends ConsumerState<CheckInModal> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<EligibleMemberResponse> _members = [];
  bool _loading = true;
  int? _checkingInUserId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadMembers({String? search}) async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(gymRepositoryProvider);
      final result = await repo.getEligibleForCheckIn(search: search);
      if (mounted) {
        setState(() {
          _members = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadMembers(search: value.trim().isEmpty ? null : value.trim());
    });
  }

  Future<void> _checkIn(EligibleMemberResponse member) async {
    setState(() {
      _checkingInUserId = member.userId;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(gymRepositoryProvider);
      await repo.checkIn(userId: member.userId);
      ref.invalidate(activeVisitsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, '${member.userFullName} uspjesno prijavljen/a.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _checkingInUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
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
                      child: Text('Check-in korisnika',
                          style: AppTextStyles.h2)),
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

              // Search
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: AppTextStyles.body.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Pretrazi korisnike...',
                  hintStyle:
                      AppTextStyles.bodySmall.copyWith(fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 18),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // List
              if (_loading)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                )
              else if (_members.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('Nema korisnika sa aktivnom clanarinom',
                        style: AppTextStyles.bodySmall),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _members.length,
                    separatorBuilder: (_, _) => Divider(
                        color: Colors.white.withValues(alpha: 0.04),
                        height: 1),
                    itemBuilder: (_, i) {
                      final member = _members[i];
                      final isCheckingIn =
                          _checkingInUserId == member.userId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 4),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  member.userFullName.isNotEmpty
                                      ? member.userFullName
                                          .split(' ')
                                          .map((n) =>
                                              n.isNotEmpty ? n[0] : '')
                                          .take(2)
                                          .join()
                                      : '?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Name + package
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.userFullName,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    member.membershipPackageName,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Active badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Aktivna',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Check-in button
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: isCheckingIn
                                    ? null
                                    : () => _checkIn(member),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors
                                      .primary
                                      .withValues(alpha: 0.3),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                ),
                                child: isCheckingIn
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text('Check-in',
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        )),
                              ),
                            ),
                          ],
                        ),
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

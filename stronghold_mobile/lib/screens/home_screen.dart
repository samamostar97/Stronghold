import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/seminar_provider.dart';
import '../providers/supplement_provider.dart';
import '../utils/image_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double _homeActionCardMinHeight = 250;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myAppointmentsProvider.notifier).load();
      ref.read(seminarsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final displayName = user?.displayName.trim() ?? '';
    final name = displayName.isNotEmpty
        ? displayName
        : (user?.firstName ?? 'Clan');
    final imageUrl = user?.profileImageUrl;

    final unreadCount = ref.watch(userNotificationProvider).unreadCount;
    final cartCount = ref.watch(cartProvider).itemCount;
    final progressAsync = ref.watch(userProgressProvider);
    final appointmentsState = ref.watch(myAppointmentsProvider);
    final seminarsState = ref.watch(seminarsProvider);
    final homeSupplementsAsync = ref.watch(homeSupplementsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _progressOverviewCard(
                    context,
                    name: name,
                    imageUrl: imageUrl,
                    progressAsync: progressAsync,
                    unreadCount: unreadCount,
                    cartCount: cartCount,
                  )
                  .animate(delay: 40.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.lg),
              _appointmentsOverviewCard(context, appointmentsState)
                  .animate(delay: 110.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.lg),
              _shopFeatureCard(context, homeSupplementsAsync)
                  .animate(delay: 140.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.lg),
              _seminarFeatureCard(context, seminarsState)
                  .animate(delay: 170.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _softPremiumCardDecoration({
    List<Color>? gradientColors,
    Color accentColor = AppColors.primary,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: gradientColors ?? const [Color(0xFFF7FAFF), Color(0xFFEDF3FF)],
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: AppColors.deepBlue.withValues(alpha: 0.06),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _progressOverviewCard(
    BuildContext context, {
    required String name,
    required String? imageUrl,
    required AsyncValue<UserProgressResponse> progressAsync,
    required int unreadCount,
    required int cartCount,
  }) {
    final fullImageUrl = imageUrl != null ? getFullImageUrl(imageUrl) : null;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 360),
      decoration: _softPremiumCardDecoration(
        gradientColors: const [Color(0xFFF2F7FF), Color(0xFFE7F0FF)],
        accentColor: AppColors.primary,
      ),
      child: Stack(
        children: [
          Positioned(
            left: -48,
            top: -56,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 64,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _greeting(),
                        style: AppTextStyles.headingSm.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _headerActionButton(
                      icon: LucideIcons.bell,
                      badgeCount: unreadCount,
                      onTap: () => context.push('/notifications'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _headerActionButton(
                      icon: LucideIcons.shoppingCart,
                      badgeCount: cartCount,
                      onTap: () => context.push('/cart'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 1,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                const SizedBox(height: AppSpacing.md),
                progressAsync.when(
                  loading: () => _progressHeaderRow(
                    name: name,
                    subtitle: 'Napredak se ucitava...',
                    imageUrl: fullImageUrl,
                  ),
                  error: (_, __) => _progressHeaderRow(
                    name: name,
                    subtitle: 'Napredak trenutno nije dostupan',
                    imageUrl: fullImageUrl,
                  ),
                  data: (progress) => _progressHeaderRow(
                    name: name,
                    subtitle:
                        'Level ${progress.level} - ${progress.currentXP} XP',
                    imageUrl: fullImageUrl,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                progressAsync.when(
                  loading: () => _progressBody(
                    progressText: 'Level ... - ... / ... XP',
                    progress: 0,
                    loading: true,
                  ),
                  error: (_, __) => _progressBody(
                    progressText: 'Napredak nije dostupan',
                    progress: 0,
                  ),
                  data: (progress) => _progressBody(
                    progressText:
                        'Level ${progress.level} - ${progress.currentXP} / ${progress.xpForNextLevel} XP',
                    progress: progress.xpForNextLevel <= 0
                        ? 0
                        : (progress.currentXP / progress.xpForNextLevel).clamp(
                            0,
                            1,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: () => context.push('/progress'),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pregled napretka',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 15,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressHeaderRow({
    required String name,
    required String subtitle,
    required String? imageUrl,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 52,
            height: 52,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholderAvatar(name),
                    errorWidget: (_, __, ___) => _placeholderAvatar(name),
                  )
                : _placeholderAvatar(name),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headingSm.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressBody({
    required String progressText,
    required double progress,
    bool loading = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF5F9FF), Color(0xFFEAF1FF)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progressText,
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: loading ? null : progress,
              minHeight: 10,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentsOverviewCard(
    BuildContext context,
    MyAppointmentsState appointmentsState,
  ) {
    final nextSoon = _nextSoonAppointment(appointmentsState.items);
    final loading =
        appointmentsState.isLoading && appointmentsState.items.isEmpty;
    final hasError =
        appointmentsState.error != null && appointmentsState.items.isEmpty;
    final hasSoonAppointment = !loading && !hasError && nextSoon != null;

    final mainText = loading
        ? 'Provjeravamo vase termine...'
        : hasError
        ? 'Termini trenutno nisu dostupni'
        : hasSoonAppointment
        ? _appointmentTypeText(nextSoon)
        : 'Nemate termina danas';

    final helperText = loading
        ? 'Ucitavanje podataka o terminima.'
        : hasError
        ? 'Pokusajte ponovo kroz ekran Termini.'
        : hasSoonAppointment
        ? 'Vrijeme: ${_formatAppointmentDateTime(nextSoon.appointmentDate)}'
        : 'Rezervisite termin sa nasim profesionalnim osobljem.';

    final staffText = hasSoonAppointment
        ? 'Sa: ${_appointmentStaffName(nextSoon)}'
        : null;

    final statusIcon = loading
        ? LucideIcons.loader
        : hasError
        ? LucideIcons.alertCircle
        : hasSoonAppointment
        ? LucideIcons.clock3
        : LucideIcons.calendarDays;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: () => context.go('/appointments'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        splashColor: AppColors.primary.withValues(alpha: 0.07),
        highlightColor: AppColors.primary.withValues(alpha: 0.03),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _homeActionCardMinHeight,
          ),
          child: Ink(
            width: double.infinity,
            decoration: _softPremiumCardDecoration(
              gradientColors: const [Color(0xFFF8FAFC), Color(0xFFF0F4F8)],
              accentColor: const Color(0xFF64748B),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -48,
                  top: -56,
                  child: IgnorePointer(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cyan.withValues(alpha: 0.04),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: 0.06),
                            blurRadius: 64,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: const Icon(
                                        LucideIcons.calendar,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Termini',
                                      style: AppTextStyles.headingSm,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  mainText,
                                  style: AppTextStyles.headingSm.copyWith(
                                    fontSize: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  helperText,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (staffText != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    staffText,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                            ),
                            child: Icon(
                              statusIcon,
                              size: 18,
                              color: AppColors.primary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pregled termina',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 15,
                            color: AppColors.primary.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  UserAppointmentResponse? _nextSoonAppointment(
    List<UserAppointmentResponse> items,
  ) {
    if (items.isEmpty) {
      return null;
    }
    final now = DateTime.now();
    final upcoming =
        items.where((item) => !item.appointmentDate.isBefore(now)).toList()
          ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    if (upcoming.isEmpty) {
      return null;
    }
    return upcoming.first;
  }

  String _appointmentTypeText(UserAppointmentResponse appointment) {
    return _hasValue(appointment.trainerName)
        ? 'Trening sa trenerom'
        : 'Termin sa nutricionistom';
  }

  String _appointmentStaffName(UserAppointmentResponse appointment) {
    if (_hasValue(appointment.trainerName)) {
      return appointment.trainerName!.trim();
    }
    if (_hasValue(appointment.nutritionistName)) {
      return appointment.nutritionistName!.trim();
    }
    return 'Nas tim';
  }

  String _formatAppointmentDateTime(DateTime date) {
    final now = DateTime.now();
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    final sameDay =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (sameDay) {
      return time;
    }
    final dd = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$dd.$month.${date.year} u $time';
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  Widget _shopFeatureCard(
    BuildContext context,
    AsyncValue<List<SupplementResponse>> homeSupplementsAsync,
  ) {
    const accent = Color(0xFFB45309);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: () => context.go('/shop'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        splashColor: accent.withValues(alpha: 0.07),
        highlightColor: accent.withValues(alpha: 0.03),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _homeActionCardMinHeight,
          ),
          child: Ink(
            width: double.infinity,
            decoration: _softPremiumCardDecoration(
              gradientColors: const [Color(0xFFFFFBF5), Color(0xFFFFF2E3)],
              accentColor: accent,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -48,
                  top: -56,
                  child: IgnorePointer(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.08),
                            blurRadius: 64,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    LucideIcons.shoppingBag,
                                    size: 16,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text('Shop', style: AppTextStyles.headingSm),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Icon(
                              LucideIcons.shoppingCart,
                              size: 18,
                              color: accent.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      homeSupplementsAsync.when(
                        loading: () => SizedBox(
                          height: 184,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        error: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Text(
                            'Shop trenutno nije dostupan.',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        data: (items) {
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Text(
                                'Trenutno nema dostupnih proizvoda.',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }
                          final preview = items.take(3).toList();
                          return SizedBox(
                            height: 184,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: preview.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                return _shopPreviewItem(
                                  context,
                                  preview[index],
                                  accent,
                                  isTopPick: index == 0,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Otvori shop',
                            style: AppTextStyles.bodySm.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 15,
                            color: accent.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shopPreviewItem(
    BuildContext context,
    SupplementResponse supplement,
    Color accent, {
    required bool isTopPick,
  }) {
    return SizedBox(
      width: 172,
      child: Material(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: () => context.push('/shop/detail', extra: supplement),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: accent.withValues(alpha: 0.08),
          highlightColor: accent.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: accent.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 84,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child:
                              supplement.imageUrl != null &&
                                  supplement.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: getFullImageUrl(
                                    supplement.imageUrl,
                                  ),
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surfaceAlt,
                                    child: Icon(
                                      LucideIcons.package,
                                      color: accent.withValues(alpha: 0.45),
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surfaceAlt,
                                  child: Icon(
                                    LucideIcons.package,
                                    color: accent.withValues(alpha: 0.45),
                                    size: 24,
                                  ),
                                ),
                        ),
                        if (isTopPick)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Top pick',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  supplement.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${supplement.price.toStringAsFixed(2)} KM',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(supplement);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('${supplement.name} dodan u korpu'),
                            duration: const Duration(milliseconds: 1200),
                          ),
                        );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.26),
                        ),
                      ),
                      child: Icon(
                        LucideIcons.plus,
                        size: 15,
                        color: accent.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _seminarFeatureCard(
    BuildContext context,
    SeminarsState seminarsState,
  ) {
    const accent = Color(0xFF166534);
    final selection = _homeSeminarSelection(seminarsState.items);
    final seminar = selection?.seminar;
    final showingAttending = selection?.isAttending ?? false;
    final loading = seminarsState.isLoading && seminarsState.items.isEmpty;
    final hasError = seminarsState.error != null && seminarsState.items.isEmpty;

    final headline = loading
        ? 'Provjeravamo seminare...'
        : hasError
        ? 'Seminari trenutno nisu dostupni'
        : seminar == null
        ? 'Trenutno nema nikakvih planiranih seminara'
        : showingAttending
        ? 'Vas sljedeci seminar'
        : 'Sljedeci seminar koji dolazi';

    final subtitle = loading
        ? 'Ucitavanje podataka o seminarima.'
        : hasError
        ? 'Pokusajte ponovo kroz ekran Seminari.'
        : seminar == null
        ? null
        : 'Tema: ${seminar.topic}';

    final dateText = seminar == null
        ? null
        : 'Datum: ${_formatAppointmentDateTime(seminar.eventDate)}';
    final remainingText = seminar == null
        ? null
        : 'Preostalo mjesta: ${_seminarRemainingPlaces(seminar)}';

    final statusIcon = loading
        ? LucideIcons.loader
        : hasError
        ? LucideIcons.alertCircle
        : seminar == null
        ? LucideIcons.calendarDays
        : showingAttending
        ? LucideIcons.badgeCheck
        : LucideIcons.presentation;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: () => context.push('/seminars'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        splashColor: accent.withValues(alpha: 0.07),
        highlightColor: accent.withValues(alpha: 0.03),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _homeActionCardMinHeight,
          ),
          child: Ink(
            width: double.infinity,
            decoration: _softPremiumCardDecoration(
              gradientColors: const [Color(0xFFF4FBF7), Color(0xFFE9F6EE)],
              accentColor: accent,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -48,
                  top: -56,
                  child: IgnorePointer(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.08),
                            blurRadius: 64,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: const Icon(
                                        LucideIcons.presentation,
                                        size: 16,
                                        color: accent,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Seminari',
                                      style: AppTextStyles.headingSm,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  headline,
                                  style: AppTextStyles.headingSm.copyWith(
                                    fontSize: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                if (dateText != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    dateText,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                if (remainingText != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    remainingText,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Icon(
                              statusIcon,
                              size: 18,
                              color: accent.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pregled seminara',
                            style: AppTextStyles.bodySm.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 15,
                            color: accent.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _SeminarSelection? _homeSeminarSelection(List<UserSeminarResponse> items) {
    if (items.isEmpty) {
      return null;
    }
    final now = DateTime.now();
    final upcoming =
        items
            .where((item) => !item.isCancelled && !item.eventDate.isBefore(now))
            .toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    if (upcoming.isEmpty) {
      return null;
    }
    final attending = upcoming.where((item) => item.isAttending).toList();
    if (attending.isNotEmpty) {
      return _SeminarSelection(seminar: attending.first, isAttending: true);
    }
    return _SeminarSelection(seminar: upcoming.first, isAttending: false);
  }

  int _seminarRemainingPlaces(UserSeminarResponse seminar) {
    final remaining = seminar.maxCapacity - seminar.currentAttendees;
    return remaining < 0 ? 0 : remaining;
  }

  Widget _headerActionButton({
    required IconData icon,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 18, color: AppColors.textPrimary)),
            if (badgeCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 1,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderAvatar(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (parts.isNotEmpty && parts.first.isNotEmpty
              ? parts.first[0].toUpperCase()
              : '?');

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.accentGradient),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.headingSm.copyWith(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dobro jutro';
    if (hour < 18) return 'Dobar dan';
    return 'Dobro vece';
  }
}

class _SeminarSelection {
  final UserSeminarResponse seminar;
  final bool isAttending;

  const _SeminarSelection({required this.seminar, required this.isAttending});
}

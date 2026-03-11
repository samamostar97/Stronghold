import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/gym_provider.dart';

class VisitHistoryScreen extends ConsumerStatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  ConsumerState<VisitHistoryScreen> createState() =>
      _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends ConsumerState<VisitHistoryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _hoveredRow;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(visitHistoryFilterProvider.notifier).update(VisitHistoryFilter(
            search: value.isEmpty ? null : value,
          ));
    });
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}. ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return '-';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) return '${hours}h ${mins}min';
    return '${mins}min';
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(visitHistoryProvider);
    final filter = ref.watch(visitHistoryFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Historija posjeta', style: AppTextStyles.h2)),
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pretrazi posjete...',
                    hintStyle:
                        AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppColors.sidebar,
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
              ),
            ],
          ),
          const SizedBox(height: 24),
          historyAsync.when(
            loading: () => Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
            error: (e, _) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Greska pri ucitavanju historije',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(visitHistoryProvider),
                      child: Text('Pokusaj ponovo',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
            data: (data) => Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.sidebar,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            _HeaderCell('ID', width: 60),
                            _HeaderCell('Korisnik', flex: 2),
                            _HeaderCell('Check-in', flex: 2),
                            _HeaderCell('Check-out', flex: 2),
                            _HeaderCell('Trajanje', flex: 1),
                          ],
                        ),
                      ),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1),

                      if (data.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text('Nema posjeta',
                                style: AppTextStyles.bodySmall),
                          ),
                        )
                      else
                        ...data.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final visit = entry.value;
                          final isHovered = _hoveredRow == index;

                          return MouseRegion(
                            onEnter: (_) =>
                                setState(() => _hoveredRow = index),
                            onExit: (_) =>
                                setState(() => _hoveredRow = null),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? Colors.white
                                        .withValues(alpha: 0.03)
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      '#${visit.id}',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              visit.userFullName
                                                      .isNotEmpty
                                                  ? visit.userFullName
                                                      .split(' ')
                                                      .map((n) =>
                                                          n.isNotEmpty
                                                              ? n[0]
                                                              : '')
                                                      .take(2)
                                                      .join()
                                                  : '?',
                                              style: AppTextStyles
                                                  .bodySmall
                                                  .copyWith(
                                                color: AppColors.primary,
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            visit.userFullName,
                                            style: AppTextStyles
                                                .bodyMedium
                                                .copyWith(fontSize: 13),
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatDateTime(visit.checkInAt),
                                      style: AppTextStyles.bodySmall
                                          .copyWith(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      visit.checkOutAt != null
                                          ? _formatDateTime(
                                              visit.checkOutAt!)
                                          : '-',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      _formatDuration(
                                          visit.durationMinutes),
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                // Pagination
                if (data.totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: data.currentPage > 1
                              ? () => ref
                                  .read(
                                      visitHistoryFilterProvider.notifier)
                                  .update(filter.copyWith(
                                      pageNumber: data.currentPage - 1))
                              : null,
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: data.currentPage > 1
                                ? AppColors.textPrimary
                                : AppColors.textSecondary
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(data.totalPages, (i) {
                          final page = i + 1;
                          final isActive = page == data.currentPage;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2),
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(
                                      visitHistoryFilterProvider.notifier)
                                  .update(filter.copyWith(
                                      pageNumber: page)),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                          .withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$page',
                                  style:
                                      AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: data.currentPage < data.totalPages
                              ? () => ref
                                  .read(
                                      visitHistoryFilterProvider.notifier)
                                  .update(filter.copyWith(
                                      pageNumber: data.currentPage + 1))
                              : null,
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            color: data.currentPage < data.totalPages
                                ? AppColors.textPrimary
                                : AppColors.textSecondary
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double? width;
  final int? flex;

  const _HeaderCell(this.label, {this.width, this.flex});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTextStyles.label.copyWith(fontSize: 11),
    );
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex ?? 1, child: child);
  }
}

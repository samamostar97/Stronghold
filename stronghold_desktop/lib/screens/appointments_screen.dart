import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/appointment_provider.dart';
import '../providers/list_state.dart';
import '../utils/debouncer.dart';
import '../widgets/appointments_table.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_input.dart';
import '../widgets/shimmer_loading.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      final text = _searchController.text.trim();
      ref
          .read(appointmentListProvider.notifier)
          .setSearch(text.isEmpty ? '' : text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentListProvider);
    final notifier = ref.read(appointmentListProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;

        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
          child: Container(
            padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceSolid,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pregled termina', style: AppTextStyles.headingMd),
                const SizedBox(height: AppSpacing.xxl),
                _buildSearchBar(constraints),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(child: _buildContent(state, notifier)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 600;
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku, treneru...',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSortDropdown(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku, treneru...',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOrderBy,
          hint: Text('Sortiraj', style: AppTextStyles.bodyMd),
          dropdownColor: AppColors.surfaceSolid,
          style: AppTextStyles.bodyBold,
          icon: Icon(LucideIcons.arrowUpDown,
              color: AppColors.textMuted, size: 16),
          items: const [
            DropdownMenuItem(value: null, child: Text('Zadano')),
            DropdownMenuItem(value: 'datedesc', child: Text('Najnovije')),
            DropdownMenuItem(value: 'date', child: Text('Najstarije')),
            DropdownMenuItem(value: 'user', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem(
                value: 'userdesc', child: Text('Korisnik (Z-A)')),
          ],
          onChanged: (value) {
            setState(() => _selectedOrderBy = value);
            ref.read(appointmentListProvider.notifier).setOrderBy(value);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    ListState<AdminAppointmentResponse, AppointmentQueryFilter> state,
    AppointmentListNotifier notifier,
  ) {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [3, 2, 3, 2, 1]);
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
            const SizedBox(height: AppSpacing.sm),
            Text(state.error!,
                style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(text: 'Pokusaj ponovo', onTap: notifier.refresh),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: AppointmentsTable(appointments: state.items)),
        const SizedBox(height: AppSpacing.lg),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: notifier.goToPage,
        ),
      ],
    );
  }
}

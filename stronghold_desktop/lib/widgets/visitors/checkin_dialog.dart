import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/list_state.dart';
import '../../providers/membership_provider.dart';
import '../../providers/visit_provider.dart';
import '../../utils/debouncer.dart';
import '../shared/pagination_controls.dart';
import '../shared/small_button.dart';

class CheckinDialog extends ConsumerStatefulWidget {
  const CheckinDialog({super.key});

  @override
  ConsumerState<CheckinDialog> createState() => _State();
}

class _State extends ConsumerState<CheckinDialog> {
  final _search = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  bool _checkingIn = false;

  @override
  void dispose() {
    _search.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onChanged(String q) =>
      _debouncer.run(() => ref.read(activeMembersProvider.notifier).setSearch(q));

  Future<void> _checkIn(ActiveMemberResponse member) async {
    setState(() => _checkingIn = true);
    try {
      await ref.read(currentVisitorsProvider.notifier).checkIn(member.userId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeMembersProvider);
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: AppSpacing.xl),
              _searchField(),
              const SizedBox(height: AppSpacing.lg),
              Flexible(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(children: [
        Expanded(
            child: Text(
                'Check-in korisnika', style: AppTextStyles.headingMd)),
        IconButton(
          icon: Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ]);

  Widget _searchField() => TextField(
        controller: _search,
        autofocus: true,
        onChanged: _onChanged,
        style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Pretrazite po imenu ili korisnickom imenu...',
          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surfaceSolid,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          prefixIcon:
              Icon(LucideIcons.search, color: AppColors.textMuted, size: 18),
        ),
      );

  Widget _buildBody(ListState<ActiveMemberResponse, ActiveMemberQueryFilter> state) {
    if (_checkingIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text('Prijava u tijeku...',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textPrimary)),
          ]),
        ),
      );
    }
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: CircularProgressIndicator(color: AppColors.primary),
      ));
    }
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Text(state.error!,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
        ),
      );
    }
    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Text(
              _search.text.isNotEmpty
                  ? 'Nema rezultata za "${_search.text}"'
                  : 'Nema korisnika sa aktivnom clanarinom',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center),
        ),
      );
    }
    return Column(children: [
      Expanded(
        child: ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (_, i) => _MemberTile(
            member: state.items[i],
            onCheckIn: () => _checkIn(state.items[i]),
          ),
        ),
      ),
      if (state.totalPages > 1) ...[
        const SizedBox(height: AppSpacing.md),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: (p) =>
              ref.read(activeMembersProvider.notifier).goToPage(p),
        ),
      ],
    ]);
  }
}

class _MemberTile extends StatefulWidget {
  const _MemberTile({required this.member, required this.onCheckIn});
  final ActiveMemberResponse member;
  final VoidCallback onCheckIn;

  @override
  State<_MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<_MemberTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: _hover ? AppColors.surfaceHover : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
              color: _hover ? AppColors.borderHover : Colors.transparent),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.member.firstName.isNotEmpty
                  ? widget.member.firstName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.bodyBold
                  .copyWith(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.member.fullName,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Text(widget.member.username,
                        style: AppTextStyles.bodySm),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(widget.member.packageName,
                          style: AppTextStyles.badge
                              .copyWith(color: AppColors.accent)),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          SmallButton(
            text: 'Check-in',
            color: AppColors.primary,
            onTap: widget.onCheckIn,
          ),
        ]),
      ),
    );
  }
}

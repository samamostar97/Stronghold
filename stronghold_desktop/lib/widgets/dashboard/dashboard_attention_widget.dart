import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/dashboard_attention_provider.dart';

class DashboardAttentionWidget extends StatelessWidget {
  const DashboardAttentionWidget({
    super.key,
    required this.state,
    required this.onRetry,
    this.expand = false,
  });

  final DashboardAttentionState state;
  final VoidCallback onRetry;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Text('Zahtijeva paznju', style: AppTextStyles.headingSm),
        const Spacer(),
        if (!state.isLoading && state.error == null)
          _PulseDot(
            color: state.totalCount > 0 ? AppColors.danger : AppColors.cyan,
          ),
      ],
    );

    Widget content;
    if (state.isLoading && state.totalCount == 0) {
      content = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    } else if (state.error != null && state.totalCount == 0) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.bodyBold),
            const SizedBox(height: AppSpacing.md),
            TextButton(
                onPressed: onRetry, child: const Text('Pokusaj ponovo')),
          ],
        ),
      );
    } else if (state.totalCount == 0) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.checkCircle,
                  color: AppColors.success, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Sve je u redu', style: AppTextStyles.bodyBold),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Nema stavki koje zahtijevaju paznju',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    } else {
      final items = <_AttentionItemData>[
        if (state.pendingOrdersCount > 0)
          _AttentionItemData(
            icon: LucideIcons.shoppingBag,
            color: AppColors.orange,
            label: 'Narudzbe u obradi',
            count: state.pendingOrdersCount,
            path: '/orders',
          ),
        if (state.expiringMembershipsCount > 0)
          _AttentionItemData(
            icon: LucideIcons.award,
            color: AppColors.danger,
            label: 'Clanarine isticu ove sedmice',
            count: state.expiringMembershipsCount,
            path: '/users',
          ),
        if (state.lowStockSupplementsCount > 0)
          _AttentionItemData(
            icon: LucideIcons.alertTriangle,
            color: AppColors.warning,
            label: 'Suplementi s niskim stanjem',
            count: state.lowStockSupplementsCount,
            path: '/supplements',
          ),
      ];

      content = ListView.separated(
        shrinkWrap: !expand,
        physics: expand
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) => _AttentionItem(data: items[i]),
      );
    }

    return GlassCard(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.lg),
          if (expand) Expanded(child: content) else Flexible(child: content),
        ],
      ),
    );
  }
}

class _AttentionItemData {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final String path;

  const _AttentionItemData({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.path,
  });
}

class _AttentionItem extends StatefulWidget {
  const _AttentionItem({required this.data});
  final _AttentionItemData data;

  @override
  State<_AttentionItem> createState() => _AttentionItemState();
}

class _AttentionItemState extends State<_AttentionItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(d.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _hover
                ? d.color.withValues(alpha: 0.08)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:
                  _hover ? d.color.withValues(alpha: 0.25) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: d.color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(d.icon, size: 18, color: d.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  d.label,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: d.color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '${d.count}',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: d.color,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: _hover ? d.color : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}


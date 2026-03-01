import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// Animated shimmer effect for skeleton loading placeholders.
/// Hand-rolled using AnimationController + ShaderMask — no external dependency.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.0 + 3.0 * progress, 0),
              end: Alignment(-0.5 + 3.0 * progress, 0),
              colors: const [
                AppColors.panel,
                AppColors.border,
                AppColors.panel,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a single table row.
class ShimmerTableRow extends StatelessWidget {
  const ShimmerTableRow({super.key, required this.columnFlex});

  final List<int> columnFlex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < columnFlex.length; i++) ...[
            Expanded(
              flex: columnFlex[i],
              child: Align(
                alignment: Alignment.centerLeft,
                child: ShimmerBox(width: i == 0 ? 120 : null, height: 14),
              ),
            ),
            if (i < columnFlex.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

/// Shimmer table skeleton with header + body rows.
class ShimmerTable extends StatelessWidget {
  const ShimmerTable({
    super.key,
    this.rowCount = 8,
    this.columnFlex = const [2, 3, 2, 2],
  });

  final int rowCount;
  final List<int> columnFlex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: Row(
            children: [
              for (int i = 0; i < columnFlex.length; i++) ...[
                Expanded(
                  flex: columnFlex[i],
                  child: ShimmerBox(
                    width: 60 + (i * 10).toDouble(),
                    height: 12,
                  ),
                ),
                if (i < columnFlex.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
        // Body rows
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount,
            itemBuilder: (context, index) =>
                ShimmerTableRow(columnFlex: columnFlex),
          ),
        ),
      ],
    );
  }
}

/// Shimmer placeholder for a stat card.
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.panelRadius,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 40, height: 40, borderRadius: 12),
          SizedBox(height: 16),
          ShimmerBox(width: 80, height: 12),
          SizedBox(height: 12),
          ShimmerBox(width: 120, height: 28),
          SizedBox(height: 10),
          ShimmerBox(width: 100, height: 12),
        ],
      ),
    );
  }
}

/// Full dashboard skeleton: hero header + stat cards + chart areas.
class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(36, 28, 36, 60),
      child: Column(
        children: [
          // Hero header skeleton
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: AppSpacing.heroRadius,
            ),
            padding: const EdgeInsets.all(32),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 200, height: 24),
                SizedBox(height: 12),
                ShimmerBox(width: 160, height: 14),
              ],
            ),
          ),
          // Stat cards overlapping hero
          Transform.translate(
            offset: const Offset(0, -30),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: ShimmerStatCard()),
                  SizedBox(width: 20),
                  Expanded(child: ShimmerStatCard()),
                  SizedBox(width: 20),
                  Expanded(child: ShimmerStatCard()),
                  SizedBox(width: 20),
                  Expanded(child: ShimmerStatCard()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Chart + sidebar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppSpacing.cardRadius,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 200, height: 20),
                      Spacer(),
                      ShimmerBox(height: 160),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppSpacing.cardRadius,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 120, height: 16),
                          Spacer(),
                          ShimmerBox(width: 160, height: 28),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppSpacing.cardRadius,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 140, height: 16),
                          SizedBox(height: 16),
                          ShimmerBox(height: 36, borderRadius: 10),
                          SizedBox(height: 8),
                          ShimmerBox(height: 36, borderRadius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

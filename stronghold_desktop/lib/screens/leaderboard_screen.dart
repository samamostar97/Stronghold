import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/back_button.dart';
import '../widgets/gradient_button.dart';
import '../widgets/hover_icon_button.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/shimmer_loading.dart';

/// Refactored Leaderboard Screen using Riverpod
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    if (embedded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1200
              ? 40.0
              : constraints.maxWidth > 800
                  ? 24.0
                  : 16.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: _buildMainContent(context, ref, constraints, leaderboardAsync),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg1, AppColors.bg2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 1200
                  ? 40.0
                  : constraints.maxWidth > 800
                      ? 24.0
                      : 16.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SharedAdminHeader(),
                    const SizedBox(height: 20),
                    AppBackButton(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildMainContent(context, ref, constraints, leaderboardAsync),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    AsyncValue<List<LeaderboardEntryResponse>> leaderboardAsync,
  ) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFF5757),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Rang lista',
                style: TextStyle(
                  fontSize: constraints.maxWidth > 600 ? 28 : 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              HoverIconButton(
                icon: Icons.refresh,
                onTap: () => ref.invalidate(leaderboardProvider),
                tooltip: 'Osvježi',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: leaderboardAsync.when(
              loading: () => const ShimmerTable(
                columnFlex: [1, 4, 2, 2],
                rowCount: 10,
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Greška pri učitavanju',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(color: AppColors.muted, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Pokušaj ponovo',
                      onTap: () => ref.invalidate(leaderboardProvider),
                    ),
                  ],
                ),
              ),
              data: (leaderboard) => _LeaderboardTable(entries: leaderboard),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTRA COLORS
// ─────────────────────────────────────────────────────────────────────────────

const _gold = Color(0xFFFFD700);
const _silver = Color(0xFFC0C0C0);
const _bronze = Color(0xFFCD7F32);

// ─────────────────────────────────────────────────────────────────────────────
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int rank = 1;
  static const int user = 4;
  static const int level = 2;
  static const int xp = 2;
}

class _LeaderboardTable extends StatelessWidget {
  const _LeaderboardTable({required this.entries});

  final List<LeaderboardEntryResponse> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            if (entries.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Nema podataka za prikaz.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, i) => _LeaderboardTableRow(
                    entry: entries[i],
                    isLast: i == entries.length - 1,
                  )
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        delay: (50 * i).ms,
                      )
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 300.ms,
                        delay: (50 * i).ms,
                        curve: Curves.easeOut,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          _HeaderCell(text: 'Rang', flex: _TableFlex.rank),
          _HeaderCell(text: 'Korisnik', flex: _TableFlex.user),
          _HeaderCell(text: 'Level', flex: _TableFlex.level),
          _HeaderCell(text: 'XP', flex: _TableFlex.xp, alignRight: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex, this.alignRight = false});

  final String text;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _LeaderboardTableRow extends StatefulWidget {
  const _LeaderboardTableRow({
    required this.entry,
    required this.isLast,
  });

  final LeaderboardEntryResponse entry;
  final bool isLast;

  @override
  State<_LeaderboardTableRow> createState() => _LeaderboardTableRowState();
}

class _LeaderboardTableRowState extends State<_LeaderboardTableRow> {
  bool _hover = false;

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return _gold;
      case 2:
        return _silver;
      case 3:
        return _bronze;
      default:
        return AppColors.muted;
    }
  }

  IconData? _getRankIcon(int rank) {
    switch (rank) {
      case 1:
      case 2:
      case 3:
        return Icons.emoji_events;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(widget.entry.rank);
    final rankIcon = _getRankIcon(widget.entry.rank);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            // Rank
            Expanded(
              flex: _TableFlex.rank,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rankIcon != null) ...[
                      Icon(rankIcon, color: rankColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '#${widget.entry.rank}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: rankColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // User
            Expanded(
              flex: _TableFlex.user,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.entry.rank <= 3 ? rankColor : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: widget.entry.profileImageUrl != null &&
                              widget.entry.profileImageUrl!.isNotEmpty
                          ? Image.network(
                              ApiConfig.imageUrl(widget.entry.profileImageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => _buildInitialsAvatar(),
                            )
                          : _buildInitialsAvatar(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.entry.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Level
            Expanded(
              flex: _TableFlex.level,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level ${widget.entry.level}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // XP
            Expanded(
              flex: _TableFlex.xp,
              child: Text(
                '${widget.entry.currentXP} XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final nameParts = widget.entry.fullName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return Container(
      color: AppColors.bg1,
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

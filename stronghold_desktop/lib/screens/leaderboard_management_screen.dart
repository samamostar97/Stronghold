import 'package:flutter/material.dart';
import '../models/leaderboard_dto.dart';
import '../services/leaderboard_api.dart';
import '../config/api_config.dart';
import '../widgets/shared_admin_header.dart';

class LeaderboardManagementScreen extends StatefulWidget {
  const LeaderboardManagementScreen({super.key});

  @override
  State<LeaderboardManagementScreen> createState() =>
      _LeaderboardManagementScreenState();
}

class _LeaderboardManagementScreenState
    extends State<LeaderboardManagementScreen> {
  List<LeaderboardEntryDTO> _leaderboard = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await LeaderboardApi.getLeaderboard();
      setState(() {
        _leaderboard = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_AppColors.bg1, _AppColors.bg2],
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
                    const _Header(),
                    const SizedBox(height: 20),
                    _BackButton(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: 20),
                    Expanded(child: _buildMainContent(constraints)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
      decoration: BoxDecoration(
        color: _AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 28),
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
              _IconButton(
                icon: Icons.refresh,
                onTap: _loadLeaderboard,
                tooltip: 'Osvježi',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildContent(constraints)),
        ],
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _AppColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greška pri učitavanju',
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: _AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _GradientButton(text: 'Pokušaj ponovo', onTap: _loadLeaderboard),
          ],
        ),
      );
    }

    return _buildTable(constraints);
  }

  Widget _buildTable(BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            if (_leaderboard.isEmpty)
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
                  itemCount: _leaderboard.length,
                  itemBuilder: (context, i) => _LeaderboardTableRow(
                    entry: _leaderboard[i],
                    isLast: i == _leaderboard.length - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME COLORS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _AppColors {
  static const bg1 = Color(0xFF1A1D2E);
  static const bg2 = Color(0xFF16192B);
  static const card = Color(0xFF22253A);
  static const panel = Color(0xFF2A2D3E);
  static const border = Color(0xFF3A3D4E);
  static const muted = Color(0xFF8A8D9E);
  static const accent = Color(0xFFFF5757);
  static const accentLight = Color(0xFFFF6B6B);
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const SharedAdminHeader();
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _GradientButton(text: '← Nazad', onTap: onTap),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0.0, _hover ? -2.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_AppColors.accent, _AppColors.accentLight],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _hover ? _AppColors.accent : _AppColors.panel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int rank = 1;
  static const int user = 4;
  static const int level = 2;
  static const int xp = 2;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _AppColors.border, width: 2)),
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
  const _HeaderCell(
      {required this.text, required this.flex, this.alignRight = false});

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

  final LeaderboardEntryDTO entry;
  final bool isLast;

  @override
  State<_LeaderboardTableRow> createState() => _LeaderboardTableRowState();
}

class _LeaderboardTableRowState extends State<_LeaderboardTableRow> {
  bool _hover = false;

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return _AppColors.gold;
      case 2:
        return _AppColors.silver;
      case 3:
        return _AppColors.bronze;
      default:
        return _AppColors.muted;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiConfig.baseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(widget.entry.rank);
    final rankEmoji = _getRankEmoji(widget.entry.rank);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover
              ? _AppColors.panel.withValues(alpha: 0.5)
              : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: _AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            // Rank
            Expanded(
              flex: _TableFlex.rank,
              child: Row(
                children: [
                  if (rankEmoji.isNotEmpty) ...[
                    Text(rankEmoji, style: const TextStyle(fontSize: 18)),
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
                        color: widget.entry.rank <= 3
                            ? rankColor
                            : _AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: widget.entry.profileImageUrl != null &&
                              widget.entry.profileImageUrl!.isNotEmpty
                          ? Image.network(
                              _getFullImageUrl(widget.entry.profileImageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildInitialsAvatar(),
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
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level ${widget.entry.level}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.accent,
                  ),
                  textAlign: TextAlign.center,
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
      color: _AppColors.bg1,
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _AppColors.accent,
          ),
        ),
      ),
    );
  }
}

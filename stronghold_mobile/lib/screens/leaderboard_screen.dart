import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../constants/app_colors.dart';
import '../models/progress_models.dart';
import '../services/progress_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  List<LeaderboardEntry>? _leaderboard;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final leaderboard = await ProgressService.getLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiConfig.baseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const AppLoadingIndicator()
                    : _error != null
                    ? AppErrorState(message: _error!, onRetry: _loadLeaderboard)
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0f0f1a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFe63946).withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.emoji_events, color: Color(0xFFf4a261), size: 28),
          const SizedBox(width: 8),
          const Text(
            'Hall of Fame',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadLeaderboard,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pokusaj ponovo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_leaderboard == null || _leaderboard!.isEmpty) {
      return const AppEmptyState(
        icon: Icons.emoji_events,
        title: 'Nema podataka za prikaz',
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPodium(),
            const SizedBox(height: 30),
            if (_leaderboard!.length > 3) ...[
              _buildRemainingList(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _leaderboard!.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (top3.length > 1)
          _buildPodiumItem(top3[1], 2, 100)
        else
          const SizedBox(width: 100),
        const SizedBox(width: 8),
        _buildPodiumItem(top3[0], 1, 130),
        const SizedBox(width: 8),
        if (top3.length > 2)
          _buildPodiumItem(top3[2], 3, 80)
        else
          const SizedBox(width: 100),
      ],
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, int position, double height) {
    final color = AppColors.primary;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child:
                entry.profileImageUrl != null &&
                    entry.profileImageUrl!.isNotEmpty
                ? Image.network(
                    _getFullImageUrl(entry.profileImageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitialsAvatar(entry),
                  )
                : _buildInitialsAvatar(entry),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            entry.fullName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Level ${entry.level}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                position == 1
                    ? '1st'
                    : position == 2
                    ? '2nd'
                    : '3rd',
                style: TextStyle(
                  fontSize: position == 1 ? 28 : 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.currentXP} XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(LeaderboardEntry entry) {
    final nameParts = entry.fullName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return Container(
      color: const Color(0xFF1a1a2e),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFe63946),
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingList() {
    final remaining = _leaderboard!.skip(3).toList();

    return Column(
      children: remaining.map((entry) => _buildListItem(entry)).toList(),
    );
  }

  Widget _buildListItem(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f1a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe63946).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFe63946).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFe63946),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFe63946).withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child:
                  entry.profileImageUrl != null &&
                      entry.profileImageUrl!.isNotEmpty
                  ? Image.network(
                      _getFullImageUrl(entry.profileImageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitialsAvatar(entry),
                    )
                  : _buildInitialsAvatar(entry),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${entry.currentXP} XP',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFe63946).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LVL ${entry.level}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFe63946),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

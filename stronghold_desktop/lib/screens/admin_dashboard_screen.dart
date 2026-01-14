import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - MediaQuery.of(context).size.width * 0.06,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      _buildDashboardGrid(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;

    return Row(
      children: [
        Icon(
          Icons.fitness_center,
          size: isSmall ? 24 : 32,
          color: const Color(0xFFe63946),
        ),
        SizedBox(width: isSmall ? 8 : 12),
        Text(
          'STRONGHOLD',
          style: TextStyle(
            fontSize: isSmall ? 18 : 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 16,
            vertical: isSmall ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0f0f1a),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: isSmall ? 14 : 18,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(width: isSmall ? 6 : 8),
              Text(
                'Admin',
                style: TextStyle(
                  fontSize: isSmall ? 12 : 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200
            ? 4
            : width > 800
                ? 3
                : width > 500
                    ? 2
                    : 2;

        final spacing = width * 0.02;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.95,
          children: const [
            _DashboardCard(
              icon: Icons.notifications_outlined,
              label: 'Notifikacije',
            ),
            _DashboardCard(
              icon: Icons.people_outline,
              label: 'Korisnici',
            ),
            _DashboardCard(
              icon: Icons.card_membership_outlined,
              label: 'Produžavanje članarina',
            ),
            _DashboardCard(
              icon: Icons.local_pharmacy_outlined,
              label: 'Suplementi',
            ),
            _DashboardCard(
              icon: Icons.badge_outlined,
              label: 'Članarine',
            ),
            _DashboardCard(
              icon: Icons.fitness_center,
              label: 'Treneri',
            ),
            _DashboardCard(
              icon: Icons.restaurant_outlined,
              label: 'Nutricionisti',
            ),
            _DashboardCard(
              icon: Icons.analytics_outlined,
              label: 'Biznis report',
            ),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String label;

  const _DashboardCard({
    required this.icon,
    required this.label,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = constraints.maxWidth;
        final iconCircleSize = cardSize * (_isHovered ? 0.55 : 0.5);
        final iconSize = cardSize * (_isHovered ? 0.35 : 0.3);
        final padding = cardSize * 0.08;
        final fontSize = (cardSize * 0.07).clamp(12.0, 16.0);
        final buttonFontSize = (cardSize * 0.06).clamp(11.0, 14.0);
        final buttonPadding = cardSize * 0.04;
        final spacing = cardSize * 0.05;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -8.0 : 0.0, 0.0),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: const Color(0xFF0f0f1a),
              borderRadius: BorderRadius.circular(cardSize * 0.08),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFFe63946).withOpacity(0.5)
                    : Colors.white.withOpacity(0.05),
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFFe63946).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: iconCircleSize,
                  height: iconCircleSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe63946)
                        .withOpacity(_isHovered ? 0.2 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: iconSize,
                    color: const Color(0xFFe63946),
                  ),
                ),
                SizedBox(height: spacing),

                // Label
                Flexible(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: spacing),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe63946),
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardSize * 0.04),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Odaberi',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

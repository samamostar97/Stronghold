import 'package:flutter/material.dart';
import 'package:stronghold_desktop/services/token_storage.dart';
import 'package:stronghold_desktop/screens/login_screen.dart';
import 'package:stronghold_desktop/screens/users_management_screen.dart';
import 'package:stronghold_desktop/screens/membership_extension_screen.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _bg1 = Color(0xFF1A1D2E);
  static const _bg2 = Color(0xFF16192B);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bg1, _bg2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              // mimic CSS breakpoints:
              // >1200 => 3 cols, <=1200 => 2 cols, <=800 => 1 col
              final cols = width <= 800 ? 1 : (width <= 1200 ? 2 : 3);

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 700 ? 16 : 50,
                  vertical: width < 700 ? 16 : 30,
                ),
                child: ConstrainedBox(
                  // Ensure content fills at least the full screen height
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (width < 700 ? 32 : 60),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(),
                      const SizedBox(height: 24),
                      _DashboardGrid(
                        columns: cols,
                        children: [
                        _SectionCard(
                          icon: "🏋️",
                          title: "Trenutno u teretani",
                          items: const [
                            _MenuItemData(icon: "👁️", text: "Pogledaj aktivne članove"),
                          ],
                          onTapIndex: (i) {

                          },
                        ),
                        _SectionCard(
                          icon: "🎫",
                          title: "Članarine",
                          items: const [
                            _MenuItemData(icon: "➕", text: "Produžavanje članarina"),
                            _MenuItemData(icon: "📋", text: "Upravljanje paketima"),
                          ],
                          onTapIndex: (i) {
                            if (i == 0) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MembershipManagementScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        _SectionCard(
                          icon: "👥",
                          title: "Korisnici i osoblje",
                          items: const [
                            _MenuItemData(icon: "👤", text: "Upravljanje korisnicima"),
                            _MenuItemData(icon: "🏃", text: "Treneri"),
                            _MenuItemData(icon: "🍴", text: "Nutricionisti"),
                          ],
                          onTapIndex: (i) {
                            if (i == 0) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const UsersManagementScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        _SectionCard(
                          icon: "🛒",
                          title: "Prodavnica",
                          items: const [
                            _MenuItemData(icon: "💊", text: "Suplementi"),
                            _MenuItemData(icon: "📁", text: "Kategorije"),
                            _MenuItemData(icon: "🚚", text: "Dobavljači"),
                            _MenuItemData(icon: "📦", text: "Kupovine"),
                          ],
                          onTapIndex: (i) {

                          },
                          
                        ),
                        _SectionCard(
                          icon: "📝",
                          title: "Sadržaj",
                          items: const [
                            _MenuItemData(icon: "❓", text: "FAQ"),
                            _MenuItemData(icon: "⭐", text: "Recenzije"),
                            _MenuItemData(icon: "🎓", text: "Seminari"),
                          ],
                          onTapIndex: (i) {
                          },
                        ),
                        _SectionCard(
                          icon: "📊",
                          title: "Izvještaji",
                          items: const [
                            _MenuItemData(icon: "📈", text: "Biznis report"),
                          ],
                          onTapIndex: (i) {
                            
                          },
                        ),
                        ],
                      ),
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
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Logo(),
        const Spacer(),
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFF22253A),
          onSelected: (value) async {
            if (value == 'logout') {
              await TokenStorage.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Profil', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Color(0xFFFF5757), size: 20),
                  SizedBox(width: 12),
                  Text('Odjavi se', style: TextStyle(color: Color(0xFFFF5757))),
                ],
              ),
            ),
          ],
          child: const _AdminBadge(),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text(
          "🏋️",
          style: TextStyle(fontSize: 34),
        ),
        SizedBox(width: 12),
        Text(
          "STRONGHOLD",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AdminBadge extends StatelessWidget {
  const _AdminBadge();

  static const _bg = Color(0xFF22253A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: const [
          Text("👤", style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Text(
            "Admin",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({
    required this.columns,
    required this.children,
  });

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const spacing = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card width based on number of columns and spacing
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(
                    width: cardWidth,
                    child: child,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.onTapIndex,
  });

  final String icon;
  final String title;
  final List<_MenuItemData> items;
  final void Function(int index) onTapIndex;

  static const _card = Color(0xFF22253A);
  static const _accent = Color(0xFFFF5757);
  static const _accent2 = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    return _HoverCard(
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent, width: 1),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_accent, _accent2],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _MenuRow(
                    icon: items[i].icon,
                    text: items[i].text,
                    onTap: () => onTapIndex(i),
                  ),
                  if (i != items.length - 1) const SizedBox(height: 6),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final String icon;
  final String text;
  const _MenuItemData({required this.icon, required this.text});
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final String icon;
  final String text;
  final VoidCallback onTap;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;

  static const _accent = Color(0xFFFF5757);

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? _accent.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.03);
    final leftPad = _hover ? 24.0 : 18.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(leftPad, 16, 18, 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: _hover ? 1 : 0.8,
                  child: SizedBox(
                    width: 24,
                    child: Text(
                      widget.icon,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _hover ? Colors.white : Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 180),
                  offset: _hover ? const Offset(0.1, 0) : Offset.zero,
                  child: Text(
                    "→",
                    style: TextStyle(
                      fontSize: 16,
                      color: _hover ? _accent : Colors.white.withValues(alpha: 0.30),
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
}

class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child});

  final Widget child;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hover = false;

  static const _accent = Color(0xFFFF5757);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _hover ? -4.0 : 0.0, 0.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ]
                : const [],
            border: Border.all(
              color: _hover ? _accent.withValues(alpha: 0.30) : Colors.transparent,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

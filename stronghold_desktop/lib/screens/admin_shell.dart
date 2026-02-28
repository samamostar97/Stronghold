import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart'
    show ParticleBackground, TokenStorage;
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/notification_provider.dart';
import '../widgets/shell/app_sidebar.dart';
import '../widgets/shell/command_palette.dart';
import '../widgets/shared/success_animation.dart';

const _idToPath = <String, String>{
  'dashboardHome': '/dashboard',
  'audit': '/audit',
  'users': '/users',
  'staff': '/staff',
  'supplements': '/supplements',
  'orders': '/orders',
  'reviews': '/reviews',
  'seminars': '/seminars',
  'businessReport': '/reports',
  'settings': '/settings',
};

final _pathToId = {for (final e in _idToPath.entries) e.value: e.key};

String _activeIdFromLocation(String location) {
  if (location.startsWith('/users/')) return 'users';
  return _pathToId[location] ?? 'dashboardHome';
}

class _PageMeta {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PageMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const _pageMetaById = <String, _PageMeta>{
  'dashboardHome': _PageMeta(
    title: 'Kontrolna ploca',
    subtitle: 'Pregled kljucnih KPI metrika i hitnih stavki',
    icon: LucideIcons.layoutDashboard,
  ),
  'audit': _PageMeta(
    title: 'Audit centar',
    subtitle: 'Globalni pregled uplata clanarina i admin aktivnosti',
    icon: LucideIcons.shieldCheck,
  ),
  'users': _PageMeta(
    title: 'Korisnici',
    subtitle: 'Clanovi, profili, rang lista i korisnicka historija',
    icon: LucideIcons.users,
  ),
  'staff': _PageMeta(
    title: 'Osoblje',
    subtitle: 'Treneri, nutricionisti i zakazani termini',
    icon: LucideIcons.briefcase,
  ),
  'supplements': _PageMeta(
    title: 'Suplementi',
    subtitle: 'Katalog proizvoda i stanje ponude',
    icon: LucideIcons.pill,
  ),
  'orders': _PageMeta(
    title: 'Kupovine',
    subtitle: 'Narudzbe, status isporuke i kontrola procesa',
    icon: LucideIcons.shoppingBag,
  ),
  'reviews': _PageMeta(
    title: 'Recenzije',
    subtitle: 'Moderacija korisnickih ocjena i komentara',
    icon: LucideIcons.star,
  ),
  'seminars': _PageMeta(
    title: 'Seminari',
    subtitle: 'Raspored, kapacitet i status edukativnih dogadjaja',
    icon: LucideIcons.graduationCap,
  ),
  'businessReport': _PageMeta(
    title: 'Biznis izvjestaji',
    subtitle: 'Prihodi, osoblje i trendovi posjeta',
    icon: LucideIcons.trendingUp,
  ),
  'settings': _PageMeta(
    title: 'Sistem i katalog',
    subtitle: 'Paketi, kategorije, dobavljaci i FAQ konfiguracija',
    icon: LucideIcons.settings,
  ),
};

const _navGroups = [
  NavGroup(
    label: 'Kontrola',
    items: [
      NavItem(
        id: 'dashboardHome',
        label: 'Kontrolna ploca',
        icon: LucideIcons.layoutDashboard,
      ),
      NavItem(
        id: 'audit',
        label: 'Audit centar',
        icon: LucideIcons.shieldCheck,
      ),
    ],
  ),
  NavGroup(
    label: 'Clanstvo',
    items: [
      NavItem(id: 'users', label: 'Korisnici', icon: LucideIcons.users),
      NavItem(id: 'staff', label: 'Osoblje', icon: LucideIcons.briefcase),
    ],
  ),
  NavGroup(
    label: 'Prodaja',
    items: [
      NavItem(id: 'supplements', label: 'Suplementi', icon: LucideIcons.pill),
      NavItem(id: 'orders', label: 'Kupovine', icon: LucideIcons.shoppingBag),
    ],
  ),
  NavGroup(
    label: 'Sadrzaj',
    items: [
      NavItem(id: 'reviews', label: 'Recenzije', icon: LucideIcons.star),
      NavItem(
        id: 'seminars',
        label: 'Seminari',
        icon: LucideIcons.graduationCap,
      ),
    ],
  ),
  NavGroup(
    label: 'Analitika',
    items: [
      NavItem(
        id: 'businessReport',
        label: 'Biznis izvjestaji',
        icon: LucideIcons.trendingUp,
      ),
    ],
  ),
  NavGroup(
    label: 'Sistem',
    items: [
      NavItem(
        id: 'settings',
        label: 'Sistem i katalog',
        icon: LucideIcons.settings,
      ),
    ],
  ),
];

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _collapsed = false;
  bool? _userCollapse;
  int _prevUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).startPolling();
    });
  }

  void _toggleCollapse() {
    setState(() {
      _collapsed = !_collapsed;
      _userCollapse = _collapsed;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clear();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeId = _activeIdFromLocation(location);
    final pageMeta = _pageMetaById[activeId] ?? _pageMetaById['dashboardHome']!;

    ref.listen<NotificationState>(notificationProvider, (prev, next) {
      if (prev != null &&
          next.unreadCount > _prevUnreadCount &&
          _prevUnreadCount >= 0) {
        final diff = next.unreadCount - _prevUnreadCount;
        if (diff > 0 && prev.unreadCount > 0) {
          showSuccessAnimation(context, message: 'Nova obavjestenja ($diff)');
        }
      }
      _prevUnreadCount = next.unreadCount;
    });

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showCommandPalette(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.deepBlue,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
              ),
              const ParticleBackground(
                particleColor: Color(0xFF38BDF8),
                particleCount: 60,
                connectDistance: 130,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final collapsed =
                      _userCollapse ?? constraints.maxWidth < 1200;

                  return SafeArea(
                    child: Row(
                      children: [
                        AppSidebar(
                          groups: _navGroups,
                          activeId: activeId,
                          onSelect: (id) {
                            final path = _idToPath[id];
                            if (path != null) context.go(path);
                          },
                          collapsed: collapsed,
                          onToggleCollapse: _toggleCollapse,
                          onLogout: () => _logout(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _ShellTopBar(
                                meta: pageMeta,
                                currentPath: location,
                                onNavigate: (path) => context.go(path),
                              ),
                              Expanded(child: widget.child),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar({
    required this.meta,
    required this.currentPath,
    required this.onNavigate,
  });

  final _PageMeta meta;
  final String currentPath;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    const quickLinks = [
      (
        path: '/dashboard',
        label: 'Kontrola',
        icon: LucideIcons.layoutDashboard,
      ),
      (path: '/users', label: 'Korisnici', icon: LucideIcons.users),
      (path: '/audit', label: 'Audit', icon: LucideIcons.shieldCheck),
      (path: '/reports', label: 'Izvjestaji', icon: LucideIcons.trendingUp),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: AppSpacing.panelRadius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 940;

            final titleBlock = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(meta.icon, size: 19, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      meta.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            );

            final quickActions = Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final item in quickLinks)
                  _QuickLinkChip(
                    icon: item.icon,
                    label: item.label,
                    active: currentPath == item.path,
                    onTap: () => onNavigate(item.path),
                  ),
                _QuickLinkChip(
                  icon: LucideIcons.command,
                  label: 'Komande (Ctrl+K)',
                  active: false,
                  onTap: () => showCommandPalette(context),
                ),
              ],
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  const SizedBox(height: AppSpacing.md),
                  quickActions,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: AppSpacing.lg),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: quickActions,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickLinkChip extends StatelessWidget {
  const _QuickLinkChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.deepBlue : Colors.white,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.deepBlue : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

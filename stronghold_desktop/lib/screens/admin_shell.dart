import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart' show TokenStorage;
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/notification_provider.dart';
import '../widgets/shell/app_sidebar.dart';
import '../widgets/shell/command_palette.dart';
import '../widgets/shared/success_animation.dart';

const _idToPath = <String, String>{
  'dashboardHome': '/dashboard',
  'visitors': '/visitors',
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
  const _PageMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const _pageMetaById = <String, _PageMeta>{
  'dashboardHome': _PageMeta(
    title: 'Kontrolna ploca',
    subtitle: 'Pregled metrika i kljucnih operacija',
    icon: LucideIcons.layoutDashboard,
  ),
  'visitors': _PageMeta(
    title: 'Trenutno u teretani',
    subtitle: 'Aktivni posjetioci i check-in pregled',
    icon: LucideIcons.footprints,
  ),
  'audit': _PageMeta(
    title: 'Audit centar',
    subtitle: 'Uplate clanarina i administratorske aktivnosti',
    icon: LucideIcons.shieldCheck,
  ),
  'users': _PageMeta(
    title: 'Korisnici',
    subtitle: 'Clanovi, profili i rang lista',
    icon: LucideIcons.users,
  ),
  'staff': _PageMeta(
    title: 'Osoblje',
    subtitle: 'Treneri, nutricionisti i termini',
    icon: LucideIcons.briefcase,
  ),
  'supplements': _PageMeta(
    title: 'Suplementi',
    subtitle: 'Katalog i zalihe proizvoda',
    icon: LucideIcons.pill,
  ),
  'orders': _PageMeta(
    title: 'Narudzbe',
    subtitle: 'Statusi isporuke i finansijski tok',
    icon: LucideIcons.shoppingCart,
  ),
  'reviews': _PageMeta(
    title: 'Recenzije',
    subtitle: 'Moderacija i uvid u feedback',
    icon: LucideIcons.star,
  ),
  'seminars': _PageMeta(
    title: 'Seminari',
    subtitle: 'Raspored i upravljanje kapacitetom',
    icon: LucideIcons.graduationCap,
  ),
  'businessReport': _PageMeta(
    title: 'Izvjestaji',
    subtitle: 'Prihodi, trendovi i operativna analiza',
    icon: LucideIcons.trendingUp,
  ),
  'settings': _PageMeta(
    title: 'Sistem i katalog',
    subtitle: 'Konfiguracije i osnovni sifarnici',
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
    ],
  ),
  NavGroup(
    label: 'Ljudi',
    items: [
      NavItem(id: 'users', label: 'Korisnici', icon: LucideIcons.users),
      NavItem(id: 'staff', label: 'Osoblje', icon: LucideIcons.briefcase),
    ],
  ),
  NavGroup(
    label: 'Katalog',
    items: [
      NavItem(id: 'supplements', label: 'Suplementi', icon: LucideIcons.pill),
      NavItem(
        id: 'seminars',
        label: 'Seminari',
        icon: LucideIcons.graduationCap,
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
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeId = _activeIdFromLocation(location);
    final pageMeta = _pageMetaById[activeId] ?? _pageMetaById['dashboardHome']!;
    final notificationState = ref.watch(notificationProvider);

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
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final collapsed = _userCollapse ?? constraints.maxWidth < 1180;

              return Row(
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
                    child: SafeArea(
                      child: Column(
                        children: [
                          _ShellTopBar(
                            meta: pageMeta,
                            currentPath: location,
                            unreadCount: notificationState.unreadCount,
                            onNavigate: (path) => context.go(path),
                            onOpenCommandPalette: () =>
                                showCommandPalette(context),
                            onLogout: () => _logout(context),
                          ),
                          Expanded(child: widget.child),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
    required this.unreadCount,
    required this.onNavigate,
    required this.onOpenCommandPalette,
    required this.onLogout,
  });

  final _PageMeta meta;
  final String currentPath;
  final int unreadCount;
  final ValueChanged<String> onNavigate;
  final VoidCallback onOpenCommandPalette;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const quickLinks = [
      (
        path: '/visitors',
        label: 'Trenutno u teretani',
        icon: LucideIcons.footprints,
      ),
      (path: '/audit', label: 'Audit centar', icon: LucideIcons.shieldCheck),
      (path: '/orders', label: 'Narudzbe', icon: LucideIcons.shoppingBag),
      (path: '/reviews', label: 'Recenzije', icon: LucideIcons.star),
      (path: '/reports', label: 'Izvjestaji', icon: LucideIcons.trendingUp),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.panelRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 1040;

          final titleBlock = Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Icon(
                  meta.icon,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.title, style: AppTextStyles.sectionTitle),
                  Text(meta.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ],
          );

          final tools = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final item in quickLinks)
                _TopChip(
                  icon: item.icon,
                  label: item.label,
                  active: currentPath == item.path,
                  onTap: () => onNavigate(item.path),
                ),
              _TopChip(
                icon: LucideIcons.command,
                label: 'Ctrl+K',
                active: false,
                onTap: onOpenCommandPalette,
              ),
              _NotificationChip(unreadCount: unreadCount),
              _UserChip(onLogout: onLogout),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [titleBlock, const SizedBox(height: 10), tools],
            );
          }

          return Row(
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 12),
              Flexible(child: tools),
            ],
          );
        },
      ),
    );
  }
}

class _TopChip extends StatefulWidget {
  const _TopChip({
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
  State<_TopChip> createState() => _TopChipState();
}

class _TopChipState extends State<_TopChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.active
        ? AppColors.primaryDim
        : (_hover ? AppColors.surfaceHover : AppColors.surface);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: widget.active ? AppColors.primaryBorder : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.active
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style:
                    (widget.active
                            ? AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                              )
                            : AppTextStyles.caption)
                        .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationChip extends StatelessWidget {
  const _NotificationChip({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.bell,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            unreadCount > 99 ? '99+' : '$unreadCount',
            style: AppTextStyles.caption.copyWith(
              color: unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Korisnik',
      onSelected: (value) {
        if (value == 'logout') onLogout();
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(LucideIcons.logOut, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Odjavi se', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceAlt,
              ),
              alignment: Alignment.center,
              child: Text(
                'A',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              LucideIcons.chevronDown,
              size: 13,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

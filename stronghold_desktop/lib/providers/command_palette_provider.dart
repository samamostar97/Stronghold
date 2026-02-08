import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/admin_dashboard_screen.dart';

/// A single entry in the command palette.
class CommandEntry {
  final String label;
  final String sublabel;
  final IconData icon;
  final AdminScreen? screen;
  final VoidCallback? action;
  final List<String> keywords;

  const CommandEntry({
    required this.label,
    required this.sublabel,
    required this.icon,
    this.screen,
    this.action,
    this.keywords = const [],
  });
}

/// All available commands (navigation entries).
const List<CommandEntry> _allCommands = [
  CommandEntry(
    label: 'Kontrolna ploca',
    sublabel: 'Navigacija',
    icon: LucideIcons.layoutDashboard,
    screen: AdminScreen.dashboardHome,
    keywords: ['dashboard', 'pocetna', 'home'],
  ),
  CommandEntry(
    label: 'Trenutno u teretani',
    sublabel: 'Upravljanje',
    icon: LucideIcons.activity,
    screen: AdminScreen.currentVisitors,
    keywords: ['visitors', 'check-in', 'prijava', 'posjetioci'],
  ),
  CommandEntry(
    label: 'Clanarine',
    sublabel: 'Upravljanje',
    icon: LucideIcons.creditCard,
    screen: AdminScreen.memberships,
    keywords: ['membership', 'pretplata', 'clanarina'],
  ),
  CommandEntry(
    label: 'Paketi clanarina',
    sublabel: 'Upravljanje',
    icon: LucideIcons.package2,
    screen: AdminScreen.membershipPackages,
    keywords: ['package', 'paket', 'plan'],
  ),
  CommandEntry(
    label: 'Korisnici',
    sublabel: 'Upravljanje',
    icon: LucideIcons.users,
    screen: AdminScreen.users,
    keywords: ['users', 'clanovi', 'members', 'korisnik'],
  ),
  CommandEntry(
    label: 'Treneri',
    sublabel: 'Osoblje',
    icon: LucideIcons.dumbbell,
    screen: AdminScreen.trainers,
    keywords: ['trainer', 'trener', 'coach'],
  ),
  CommandEntry(
    label: 'Nutricionisti',
    sublabel: 'Osoblje',
    icon: LucideIcons.apple,
    screen: AdminScreen.nutritionists,
    keywords: ['nutritionist', 'nutricionista', 'ishrana'],
  ),
  CommandEntry(
    label: 'Suplementi',
    sublabel: 'Prodavnica',
    icon: LucideIcons.pill,
    screen: AdminScreen.supplements,
    keywords: ['supplement', 'proizvod', 'product'],
  ),
  CommandEntry(
    label: 'Kategorije',
    sublabel: 'Prodavnica',
    icon: LucideIcons.tag,
    screen: AdminScreen.categories,
    keywords: ['category', 'kategorija'],
  ),
  CommandEntry(
    label: 'Dobavljaci',
    sublabel: 'Prodavnica',
    icon: LucideIcons.truck,
    screen: AdminScreen.suppliers,
    keywords: ['supplier', 'dobavljac'],
  ),
  CommandEntry(
    label: 'Kupovine',
    sublabel: 'Prodavnica',
    icon: LucideIcons.shoppingBag,
    screen: AdminScreen.orders,
    keywords: ['order', 'kupovina', 'narudzba'],
  ),
  CommandEntry(
    label: 'FAQ',
    sublabel: 'Sadrzaj',
    icon: LucideIcons.helpCircle,
    screen: AdminScreen.faq,
    keywords: ['faq', 'pitanja', 'pomoc'],
  ),
  CommandEntry(
    label: 'Recenzije',
    sublabel: 'Sadrzaj',
    icon: LucideIcons.star,
    screen: AdminScreen.reviews,
    keywords: ['review', 'recenzija', 'ocjena'],
  ),
  CommandEntry(
    label: 'Seminari',
    sublabel: 'Sadrzaj',
    icon: LucideIcons.graduationCap,
    screen: AdminScreen.seminars,
    keywords: ['seminar', 'edukacija', 'workshop'],
  ),
  CommandEntry(
    label: 'Biznis izvjestaji',
    sublabel: 'Analitika',
    icon: LucideIcons.trendingUp,
    screen: AdminScreen.businessReport,
    keywords: ['report', 'izvjestaj', 'statistika', 'analiza'],
  ),
  CommandEntry(
    label: 'Rang lista',
    sublabel: 'Analitika',
    icon: LucideIcons.trophy,
    screen: AdminScreen.leaderboard,
    keywords: ['leaderboard', 'rang', 'top'],
  ),
];

/// Command palette state.
class CommandPaletteState {
  final bool isOpen;
  final String query;
  final List<CommandEntry> filteredResults;
  final int selectedIndex;

  const CommandPaletteState({
    this.isOpen = false,
    this.query = '',
    this.filteredResults = _allCommands,
    this.selectedIndex = 0,
  });

  CommandPaletteState copyWith({
    bool? isOpen,
    String? query,
    List<CommandEntry>? filteredResults,
    int? selectedIndex,
  }) {
    return CommandPaletteState(
      isOpen: isOpen ?? this.isOpen,
      query: query ?? this.query,
      filteredResults: filteredResults ?? this.filteredResults,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

/// Command palette notifier.
class CommandPaletteNotifier extends StateNotifier<CommandPaletteState> {
  CommandPaletteNotifier() : super(const CommandPaletteState());

  void open() {
    state = const CommandPaletteState(isOpen: true);
  }

  void close() {
    state = const CommandPaletteState(isOpen: false);
  }

  void updateQuery(String query) {
    final lowerQuery = query.toLowerCase().trim();
    final filtered = lowerQuery.isEmpty
        ? _allCommands
        : _allCommands.where((cmd) {
            return cmd.label.toLowerCase().contains(lowerQuery) ||
                cmd.sublabel.toLowerCase().contains(lowerQuery) ||
                cmd.keywords.any((kw) => kw.contains(lowerQuery));
          }).toList();

    state = state.copyWith(
      query: query,
      filteredResults: filtered,
      selectedIndex: 0,
    );
  }

  void moveSelection(int delta) {
    if (state.filteredResults.isEmpty) return;
    final newIndex =
        (state.selectedIndex + delta) % state.filteredResults.length;
    state = state.copyWith(
      selectedIndex: newIndex < 0
          ? state.filteredResults.length + newIndex
          : newIndex,
    );
  }

  CommandEntry? getSelectedEntry() {
    if (state.filteredResults.isEmpty) return null;
    if (state.selectedIndex >= state.filteredResults.length) return null;
    return state.filteredResults[state.selectedIndex];
  }
}

/// Command palette provider.
final commandPaletteProvider =
    StateNotifierProvider<CommandPaletteNotifier, CommandPaletteState>((ref) {
  return CommandPaletteNotifier();
});

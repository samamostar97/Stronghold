import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A single entry in the command palette.
class CommandEntry {
  final String label;
  final String sublabel;
  final IconData icon;
  final String? path;
  final VoidCallback? action;
  final List<String> keywords;

  const CommandEntry({
    required this.label,
    required this.sublabel,
    required this.icon,
    this.path,
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
    path: '/dashboard',
    keywords: ['dashboard', 'pocetna', 'home'],
  ),
  CommandEntry(
    label: 'Audit centar',
    sublabel: 'Kontrola',
    icon: LucideIcons.shieldCheck,
    path: '/audit',
    keywords: ['audit', 'uplate', 'clanarina', 'aktivnosti', 'log'],
  ),
  CommandEntry(
    label: 'Korisnici',
    sublabel: 'Upravljanje',
    icon: LucideIcons.users,
    path: '/users',
    keywords: ['users', 'clanovi', 'members', 'korisnik'],
  ),
  CommandEntry(
    label: 'Osoblje',
    sublabel: 'Osoblje',
    icon: LucideIcons.users,
    path: '/staff',
    keywords: ['trainer', 'trener', 'coach', 'nutritionist', 'nutricionista', 'ishrana', 'termin', 'appointment'],
  ),
  CommandEntry(
    label: 'Suplementi',
    sublabel: 'Prodavnica',
    icon: LucideIcons.pill,
    path: '/supplements',
    keywords: ['supplement', 'proizvod', 'product'],
  ),
  CommandEntry(
    label: 'Kupovine',
    sublabel: 'Prodavnica',
    icon: LucideIcons.shoppingBag,
    path: '/orders',
    keywords: ['order', 'kupovina', 'narudzba'],
  ),
  CommandEntry(
    label: 'Recenzije',
    sublabel: 'Sadrzaj',
    icon: LucideIcons.star,
    path: '/reviews',
    keywords: ['review', 'recenzija', 'ocjena'],
  ),
  CommandEntry(
    label: 'Seminari',
    sublabel: 'Sadrzaj',
    icon: LucideIcons.graduationCap,
    path: '/seminars',
    keywords: ['seminar', 'edukacija', 'workshop'],
  ),
  CommandEntry(
    label: 'Biznis izvjestaji',
    sublabel: 'Analitika',
    icon: LucideIcons.trendingUp,
    path: '/reports',
    keywords: ['report', 'izvjestaj', 'statistika', 'analiza'],
  ),
  CommandEntry(
    label: 'Rang lista',
    sublabel: 'Korisnici',
    icon: LucideIcons.trophy,
    path: '/users',
    keywords: ['leaderboard', 'rang', 'top'],
  ),
  CommandEntry(
    label: 'Sistem i katalog',
    sublabel: 'Konfiguracija',
    icon: LucideIcons.settings,
    path: '/settings',
    keywords: ['settings', 'postavke', 'konfiguracija', 'paket', 'kategorija', 'dobavljac', 'faq'],
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

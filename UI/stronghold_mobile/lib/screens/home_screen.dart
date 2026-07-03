import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../providers/appointments_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import 'book_appointment_screen.dart';
import 'leaderboard_screen.dart';
import 'notifications_screen.dart';
import 'shell_screen.dart';

/// Pocetni ekran - pregled informacija clana, XP napredak i notifikacije.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
      context.read<AppointmentsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final unread = context.watch<NotificationsProvider>().unreadCount;
    final progress = profileProvider.progress;
    final occupancy = profileProvider.gymOccupancy;
    final nextAppointment =
        _nextAppointment(context.watch<AppointmentsProvider>().appointments);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stronghold'),
        actions: [
          IconButton(
            tooltip: 'Rang lista',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Notifikacije',
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Odjava',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: profileProvider.loading && progress == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => Future.wait([
                profileProvider.load(),
                context.read<AppointmentsProvider>().load(),
              ]),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Zdravo, ${profileProvider.profile?.firstName ?? ''}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (progress != null) ...[
                    // hero kartica napretka - puna navy podloga, prsten oko nivoa
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.navy,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: progress.levelProgressPercent / 100,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                  color: Colors.white,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.18),
                                ),
                                Center(
                                  child: Text(
                                    '${progress.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NIVO ${progress.level}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${progress.xp} XP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${progress.levelProgressPercent}% do sljedećeg nivoa',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context,
                            Icons.fitness_center,
                            '${progress.totalVisits}',
                            'ukupno posjeta',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context,
                            Icons.timer_outlined,
                            '${(progress.monthlyMinutes / 60).toStringAsFixed(1)}h',
                            'zadnjih 30 dana',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  _nextAppointmentCard(context, nextAppointment),
                  if (occupancy != null) _occupancyCard(context, occupancy),
                ],
              ),
            ),
    );
  }

  /// Najraniji buduci termin koji nije otkazan/odrzan.
  Appointment? _nextAppointment(List<Appointment> appointments) {
    final now = DateTime.now();
    Appointment? next;
    DateTime? nextSlot;
    for (final appointment in appointments) {
      if (appointment.status != 'Pending' && appointment.status != 'Confirmed') {
        continue;
      }
      final slot = DateTime(appointment.date.year, appointment.date.month,
          appointment.date.day, appointment.startHour);
      if (slot.isBefore(now)) continue;
      if (nextSlot == null || slot.isBefore(nextSlot)) {
        next = appointment;
        nextSlot = slot;
      }
    }
    return next;
  }

  Widget _nextAppointmentCard(BuildContext context, Appointment? appointment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Sljedeći termin',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (appointment != null)
                  TextButton(
                    onPressed: () => ShellScreen.switchTab(context, 2),
                    child: const Text('Svi termini'),
                  ),
              ],
            ),
            if (appointment == null) ...[
              const SizedBox(height: 4),
              Text('Nemate zakazanih termina.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Zakaži termin'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const BookAppointmentScreen()),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.navyTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      appointment.staffType == 'Trainer'
                          ? Icons.fitness_center
                          : Icons.restaurant_menu,
                      size: 22,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.staffFullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.date(appointment.date)} u ${appointment.startHour}:00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: Formatters.appointmentStatus(appointment.status),
                    tone: appointment.status == 'Confirmed'
                        ? StatusTone.success
                        : StatusTone.warning,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _occupancyCard(BuildContext context, int count) {
    final color = _occupancyColor(count);
    const segments = 14;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Stanje u teretani',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                StatusChip(
                  label: _occupancyLabel(count),
                  tone: _occupancyTone(count),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.groups_rounded, size: 24, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count == 0
                            ? 'Nema nikoga'
                            : '$count ${_memberWord(count)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        count == 0
                            ? 'teretana je trenutno prazna'
                            : 'trenutno trenira u teretani',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // segmentirana traka popunjenosti - jedan segment po clanu
            Row(
              children: [
                for (var i = 0; i < segments; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: i < count ? color : AppTheme.navyTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  StatusTone _occupancyTone(int count) {
    if (count == 0) return StatusTone.neutral;
    if (count <= 5) return StatusTone.success;
    if (count <= 12) return StatusTone.warning;
    return StatusTone.danger;
  }

  String _occupancyLabel(int count) {
    if (count == 0) return 'Prazno';
    if (count <= 5) return 'Slobodno';
    if (count <= 12) return 'Umjerena gužva';
    return 'Velika gužva';
  }

  Color _occupancyColor(int count) {
    if (count == 0) return AppTheme.textSecondary;
    if (count <= 5) return AppTheme.success;
    if (count <= 12) return AppTheme.warning;
    return AppTheme.danger;
  }

  String _memberWord(int count) {
    final mod100 = count % 100;
    final mod10 = count % 10;
    if (mod10 == 1 && mod100 != 11) return 'član';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'člana';
    }
    return 'članova';
  }

  Widget _statCard(BuildContext context, IconData icon, String value, String label) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.navyTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: AppTheme.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

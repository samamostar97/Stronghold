import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/seminar.dart';
import '../providers/seminars_provider.dart';
import '../utils/api_client.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';

class SeminarsScreen extends StatefulWidget {
  const SeminarsScreen({super.key});

  @override
  State<SeminarsScreen> createState() => _SeminarsScreenState();
}

class _SeminarsScreenState extends State<SeminarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SeminarsProvider>().load(),
    );
  }

  Future<void> _register(Seminar seminar) async {
    try {
      await context.read<SeminarsProvider>().register(seminar.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prijavljeni ste na "${seminar.topic}".')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _unregister(Seminar seminar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Odjava sa seminara'),
        content: Text('Odjaviti se sa "${seminar.topic}"? '
            'Vaše mjesto postaje dostupno drugima.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Odjavi se'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<SeminarsProvider>().unregister(seminar.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Odjavljeni ste sa "${seminar.topic}".')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeminarsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Seminari')),
      body: provider.loading && provider.seminars.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.seminars.isEmpty
              ? const Center(child: Text('Trenutno nema nadolazećih seminara.'))
              : RefreshIndicator(
                  onRefresh: () => provider.load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.seminars.length,
                    itemBuilder: (context, index) {
                      final seminar = provider.seminars[index];
                      final full = seminar.remainingCapacity <= 0;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(seminar.topic,
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Row(children: [
                                const Icon(Icons.person_outline,
                                    size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(seminar.speaker),
                              ]),
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.event,
                                    size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(Formatters.dateTime(seminar.scheduledAt)),
                              ]),
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.group_outlined,
                                    size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Preostalo mjesta: ${seminar.remainingCapacity}/${seminar.maxCapacity}',
                                  style: TextStyle(
                                    color: full
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                    fontWeight: full ? FontWeight.w600 : null,
                                  ),
                                ),
                              ]),
                              if (seminar.isCancelled &&
                                  seminar.cancellationReason != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Razlog: ${seminar.cancellationReason}',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: seminar.isCancelled
                                    ? const StatusChip(
                                        label: 'Otkazan',
                                        tone: StatusTone.danger,
                                      )
                                    : seminar.isCurrentUserRegistered
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const StatusChip(
                                                label: 'Prijavljeni ste',
                                                tone: StatusTone.success,
                                              ),
                                              const SizedBox(width: 8),
                                              // odjava do pocetka oslobadja mjesto
                                              TextButton(
                                                onPressed: () =>
                                                    _unregister(seminar),
                                                child: const Text('Odjavi se'),
                                              ),
                                            ],
                                          )
                                        : Tooltip(
                                            message: full
                                                ? 'Seminar je popunjen'
                                                : 'Prijava jednim klikom',
                                            child: FilledButton(
                                              onPressed: full
                                                  ? null
                                                  : () => _register(seminar),
                                              child: const Text('Prijavi se'),
                                            ),
                                          ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

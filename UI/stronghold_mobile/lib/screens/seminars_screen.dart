import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/seminar.dart';
import '../providers/seminars_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';

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
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.person_outline, size: 16),
                                const SizedBox(width: 4),
                                Text(seminar.speaker),
                              ]),
                              Row(children: [
                                const Icon(Icons.event, size: 16),
                                const SizedBox(width: 4),
                                Text(Formatters.dateTime(seminar.scheduledAt)),
                              ]),
                              Row(children: [
                                const Icon(Icons.group_outlined, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Preostalo mjesta: ${seminar.remainingCapacity}/${seminar.maxCapacity}',
                                  style: TextStyle(
                                    color: full
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: seminar.isCurrentUserRegistered
                                    ? Chip(
                                        avatar: Icon(Icons.check,
                                            size: 18,
                                            color: Colors.green.shade700),
                                        label: const Text('Prijavljeni ste'),
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

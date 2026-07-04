import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/staff_member.dart';
import '../providers/appointments_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';

/// Booking flow: odabir osoblja -> datum -> slobodna satnica -> potvrda.
class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  List<StaffMember> _staff = [];
  StaffMember? _selectedStaff;
  DateTime? _selectedDate;
  List<int>? _freeSlots;
  int? _selectedHour;
  String? _error;
  bool _booking = false;
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final staff = await context.read<AppointmentsProvider>().loadStaff();
    if (mounted) setState(() => _staff = staff);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _selectedHour = null;
      _freeSlots = null;
    });
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (_selectedStaff == null || _selectedDate == null) return;
    setState(() {
      _loadingSlots = true;
      _error = null;
    });
    try {
      final slots = await context
          .read<AppointmentsProvider>()
          .loadFreeSlots(_selectedStaff!.id, _selectedDate!);
      if (mounted) setState(() => _freeSlots = slots);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _book() async {
    if (_selectedStaff == null || _selectedDate == null || _selectedHour == null) {
      return;
    }
    setState(() {
      _booking = true;
      _error = null;
    });
    try {
      await context.read<AppointmentsProvider>().book(
            staffMemberId: _selectedStaff!.id,
            date: _selectedDate!,
            startHour: _selectedHour!,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Termin kod ${_selectedStaff!.fullName} '
              '(${Formatters.date(_selectedDate!)} u $_selectedHour:00) je zatražen.',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
      // satnica je mozda upravo zauzeta - osvjezi ponudu
      await _loadSlots();
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zakazivanje termina')),
      body: _staff.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('1. Odaberite trenera ili nutricionistu',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final staff in _staff)
                  Card(
                    color: _selectedStaff?.id == staff.id
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: ListTile(
                      leading: Icon(staff.staffType == 'Trainer'
                          ? Icons.fitness_center
                          : Icons.restaurant_menu),
                      title: Text(staff.fullName),
                      subtitle: Text(
                        '${staff.typeLabel} - radno vrijeme '
                        '${staff.workStartHour}:00-${staff.workEndHour}:00',
                      ),
                      trailing: _selectedStaff?.id == staff.id
                          ? const Icon(Icons.check_circle)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedStaff = staff;
                          _selectedHour = null;
                          _freeSlots = null;
                        });
                        if (_selectedDate != null) _loadSlots();
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text('2. Odaberite datum',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Odaberite datum'
                      : Formatters.date(_selectedDate!)),
                  onPressed: _selectedStaff == null ? null : _pickDate,
                ),
                if (_selectedStaff == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Prvo odaberite osobu.',
                        style: TextStyle(fontSize: 12)),
                  ),
                const SizedBox(height: 16),
                if (_selectedDate != null) ...[
                  Text('3. Odaberite slobodnu satnicu',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_loadingSlots)
                    const Center(child: CircularProgressIndicator())
                  else if (_freeSlots != null && _freeSlots!.isEmpty)
                    const Text('Nema slobodnih satnica za odabrani datum.')
                  else if (_freeSlots != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final hour in _freeSlots!)
                          ChoiceChip(
                            label: Text('$hour:00'),
                            selected: _selectedHour == hour,
                            onSelected: (_) =>
                                setState(() => _selectedHour = hour),
                          ),
                      ],
                    ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      _selectedHour == null || _booking ? null : _book,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _booking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Potvrdi termin'),
                  ),
                ),
              ],
            ),
    );
  }
}

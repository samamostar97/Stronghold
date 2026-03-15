import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/staff_response.dart';
import '../providers/appointments_provider.dart';
import '../providers/staff_provider.dart';
import '../../users/data/users_repository.dart';

class CreateAppointmentModal extends ConsumerStatefulWidget {
  const CreateAppointmentModal({super.key});

  @override
  ConsumerState<CreateAppointmentModal> createState() =>
      _CreateAppointmentModalState();
}

class _CreateAppointmentModalState
    extends ConsumerState<CreateAppointmentModal> {
  // User search
  final _userSearchController = TextEditingController();
  Timer? _userDebounce;
  List<Map<String, dynamic>> _userResults = [];
  bool _userSearching = false;
  Map<String, dynamic>? _selectedUser;

  // Staff selection
  StaffResponse? _selectedStaff;
  List<StaffResponse> _staffList = [];
  bool _loadingStaff = true;

  // Date & slot
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _slots = [];
  bool _loadingSlots = false;
  DateTime? _selectedSlot;

  // Notes
  final _notesController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _userDebounce?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    try {
      final repo = ref.read(staffRepositoryProvider);
      final result = await repo.getStaff(pageSize: 100);
      if (mounted) {
        setState(() {
          _staffList = result.items.where((s) => s.isActive).toList();
          _loadingStaff = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStaff = false);
    }
  }

  void _onUserSearch(String value) {
    _userDebounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _userResults = []);
      return;
    }
    _userDebounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _userSearching = true);
      try {
        final repo = ref.read(usersRepositoryProvider);
        final results = await repo.searchUsers(value.trim());
        if (mounted) setState(() => _userResults = results);
      } catch (_) {}
      if (mounted) setState(() => _userSearching = false);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.sidebar,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
        _slots = [];
      });
      _loadSlots();
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedStaff == null || _selectedDate == null) return;
    setState(() => _loadingSlots = true);
    try {
      final repo = ref.read(appointmentsRepositoryProvider);
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final result = await repo.getAvailableSlots(
        staffId: _selectedStaff!.id,
        date: dateStr,
      );
      if (mounted) setState(() => _slots = result);
    } catch (_) {}
    if (mounted) setState(() => _loadingSlots = false);
  }

  Future<void> _submit() async {
    if (_selectedUser == null ||
        _selectedStaff == null ||
        _selectedSlot == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(appointmentsRepositoryProvider);
      await repo.adminCreateAppointment(
        userId: _selectedUser!['id'] as int,
        staffId: _selectedStaff!.id,
        scheduledAt: _selectedSlot!.toIso8601String(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      ref.invalidate(appointmentsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Termin uspjesno kreiran.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Greska: $e');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                        child: Text('Dodaj termin', style: AppTextStyles.h2)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                    color: Colors.white.withValues(alpha: 0.06), height: 1),
                const SizedBox(height: 20),

                // User search
                Text('Korisnik',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                if (_selectedUser != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedUser!['firstName']} ${_selectedUser!['lastName']}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedUser = null;
                            _userSearchController.clear();
                          }),
                          child: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 16),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      TextField(
                        controller: _userSearchController,
                        onChanged: _onUserSearch,
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Pretrazi korisnike...',
                          hintStyle:
                              AppTextStyles.bodySmall.copyWith(fontSize: 13),
                          prefixIcon: _userSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  ),
                                )
                              : const Icon(Icons.search,
                                  color: AppColors.textSecondary, size: 18),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primary
                                    .withValues(alpha: 0.4)),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      if (_userResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _userResults.length,
                            itemBuilder: (_, i) {
                              final user = _userResults[i];
                              return InkWell(
                                onTap: () => setState(() {
                                  _selectedUser = user;
                                  _userResults = [];
                                  _userSearchController.clear();
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Text(
                                    '${user['firstName']} ${user['lastName']} (${user['email']})',
                                    style: AppTextStyles.body
                                        .copyWith(fontSize: 13),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Staff dropdown
                Text('Osoblje',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                if (_loadingStaff)
                  const SizedBox(
                    height: 44,
                    child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedStaff?.id,
                        hint: Text('Odaberi osoblje',
                            style: AppTextStyles.bodySmall
                                .copyWith(fontSize: 13)),
                        isExpanded: true,
                        dropdownColor: AppColors.background,
                        items: _staffList.map((s) {
                          final typeLabel = s.staffType == 'Trainer'
                              ? 'Trener'
                              : 'Nutricionist';
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              '${s.firstName} ${s.lastName} ($typeLabel)',
                              style:
                                  AppTextStyles.body.copyWith(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          final staff =
                              _staffList.firstWhere((s) => s.id == id);
                          setState(() {
                            _selectedStaff = staff;
                            _selectedSlot = null;
                            _slots = [];
                          });
                          if (_selectedDate != null) _loadSlots();
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Date picker
                Text('Datum',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.textSecondary, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}.'
                              : 'Odaberi datum',
                          style: _selectedDate != null
                              ? AppTextStyles.body.copyWith(fontSize: 13)
                              : AppTextStyles.bodySmall
                                  .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                // Slots
                if (_selectedStaff != null && _selectedDate != null) ...[
                  const SizedBox(height: 16),
                  Text('Dostupni termini',
                      style:
                          AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  if (_loadingSlots)
                    const SizedBox(
                      height: 44,
                      child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary)),
                      ),
                    )
                  else if (_slots.isEmpty)
                    Text('Nema dostupnih termina',
                        style: AppTextStyles.bodySmall)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _slots.map((slot) {
                        final slotTime =
                            DateTime.tryParse(slot['slotTime'] ?? '');
                        final isAvailable =
                            slot['isAvailable'] as bool? ?? false;
                        if (slotTime == null) return const SizedBox();

                        final isSelected = _selectedSlot != null &&
                            _selectedSlot!.hour == slotTime.hour;
                        final label =
                            '${slotTime.hour.toString().padLeft(2, '0')}:00';

                        return GestureDetector(
                          onTap: isAvailable
                              ? () =>
                                  setState(() => _selectedSlot = slotTime)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: !isAvailable
                                  ? AppColors.surface
                                      .withValues(alpha: 0.4)
                                  : isSelected
                                      ? AppColors.primary
                                          .withValues(alpha: 0.15)
                                      : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !isAvailable
                                    ? Colors.white
                                        .withValues(alpha: 0.03)
                                    : isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.5)
                                        : Colors.white
                                            .withValues(alpha: 0.06),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  label,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13,
                                    color: !isAvailable
                                        ? AppColors.textSecondary
                                            .withValues(alpha: 0.4)
                                        : isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                if (!isAvailable)
                                  Text(
                                    'Zauzeto',
                                    style:
                                        AppTextStyles.bodySmall.copyWith(
                                      fontSize: 9,
                                      color: AppColors.error
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],

                const SizedBox(height: 16),

                // Notes
                Text('Napomena (opcionalno)',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color:
                              AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: (_submitting ||
                            _selectedUser == null ||
                            _selectedStaff == null ||
                            _selectedSlot == null)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Kreiraj termin',
                            style: AppTextStyles.button),
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

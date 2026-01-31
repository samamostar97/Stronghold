import 'package:flutter/material.dart';
import '../utils/date_format_utils.dart';
import '../models/membership_models.dart';
import '../services/membership_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class MembershipHistoryScreen extends StatefulWidget {
  const MembershipHistoryScreen({super.key});

  @override
  State<MembershipHistoryScreen> createState() => _MembershipHistoryScreenState();
}

class _MembershipHistoryScreenState extends State<MembershipHistoryScreen> {
  List<MembershipPayment>? _payments;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payments = await MembershipService.getPaymentHistory();
      if (mounted) {
        setState(() {
          _payments = payments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} KM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historija članarine',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoadingIndicator();
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _loadPaymentHistory);
    }

    if (_payments == null || _payments!.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Nemate evidentirane uplate',
        subtitle: 'Vasa historija placanja ce se prikazati ovdje',
      );
    }

    return _buildPaymentList();
  }

  Widget _buildPaymentList() {
    return RefreshIndicator(
      onRefresh: _loadPaymentHistory,
      color: const Color(0xFFe63946),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments!.length,
        itemBuilder: (context, index) {
          return _buildPaymentCard(_payments![index]);
        },
      ),
    );
  }

  Widget _buildPaymentCard(MembershipPayment payment) {
    final isActive = payment.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe63946).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment.packageName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                      : const Color(0xFFe63946).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Aktivna' : 'Istekla',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFe63946),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(payment.amountPaid),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFe63946),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datum uplate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateDDMMYYYY(payment.paymentDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period clanarine',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateDDMMYYYY(payment.startDate)} - ${formatDateDDMMYYYY(payment.endDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

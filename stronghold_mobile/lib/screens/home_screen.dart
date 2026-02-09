import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/home_hall_of_fame_teaser.dart';
import '../widgets/home_header.dart';
import '../widgets/home_membership_card.dart';
import '../widgets/home_next_appointment.dart';
import '../widgets/home_progress_bar.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String? userImageUrl;
  final bool hasActiveMembership;

  const HomeScreen({
    super.key,
    required this.userName,
    this.userImageUrl,
    required this.hasActiveMembership,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                userName: userName,
                userImageUrl: userImageUrl,
              ),
              const SizedBox(height: AppSpacing.xl),
              HomeMembershipCard(
                hasActiveMembership: hasActiveMembership,
              ),
              const SizedBox(height: AppSpacing.xl),
              const HomeNextAppointment(),
              const SizedBox(height: AppSpacing.lg),
              const HomeProgressBar(),
              const SizedBox(height: AppSpacing.xl),
              const HomeHallOfFameTeaser(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

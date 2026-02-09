import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/home_header.dart';
import '../widgets/home_hub_grid.dart';
import '../widgets/home_membership_card.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String? userImageUrl;
  final bool hasActiveMembership;
  final ValueChanged<int> onTabSwitch;

  const HomeScreen({
    super.key,
    required this.userName,
    this.userImageUrl,
    required this.hasActiveMembership,
    required this.onTabSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
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
              Expanded(
                child: HomeHubGrid(onTabSwitch: onTabSwitch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

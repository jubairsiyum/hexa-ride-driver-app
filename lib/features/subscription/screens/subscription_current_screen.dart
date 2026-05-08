import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_plans_screen.dart';

class SubscriptionCurrentScreen extends StatefulWidget {
  const SubscriptionCurrentScreen({super.key});

  @override
  State<SubscriptionCurrentScreen> createState() =>
      _SubscriptionCurrentScreenState();
}

class _SubscriptionCurrentScreenState extends State<SubscriptionCurrentScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SubscriptionController>().getCurrentSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Subscription'),
        centerTitle: false,
      ),
      body: GetBuilder<SubscriptionController>(
        builder: (controller) {
          // 1) Stop infinite/incorrect loading: if loading, show spinner.
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) If not subscribed, show required empty-state UI.
          if (!controller.hasActiveSubscription || controller.currentSubscription == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currently Not Subscribed',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose a plan and subscribe to unlock your account features.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const SubscriptionPlansScreen());
                      },
                      child: const Text('Buy Now'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => controller.getCurrentSubscription(notify: true),
                      child: const Text('Refresh'),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3) Active subscription UI
          final String status = controller.currentStatus ?? 'active';
          final String expiresAt =
              controller.currentSubscription?['subscription']?['expires_at']?.toString() ?? '—';

          return RefreshIndicator(
            onRefresh: () => controller.getCurrentSubscription(notify: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Status: $status',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Days remaining: ${controller.daysRemaining}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Expires at: $expiresAt',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

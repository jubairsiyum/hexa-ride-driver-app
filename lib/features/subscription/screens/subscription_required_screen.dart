import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/buy_subscription_screen.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_current_screen.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_history_screen.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_plans_screen.dart';

class SubscriptionRequiredScreen extends StatefulWidget {
  const SubscriptionRequiredScreen({super.key});

  @override
  State<SubscriptionRequiredScreen> createState() =>
      _SubscriptionRequiredScreenState();
}

class _SubscriptionRequiredScreenState
    extends State<SubscriptionRequiredScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SubscriptionController>().getPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Required'),
        centerTitle: false,
      ),
      body: GetBuilder<SubscriptionController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your account does not have an active subscription.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please subscribe to continue using driver features.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available Plans',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: controller.plans.isEmpty
                    ? const Text(
                        'No active subscription plans available right now.')
                    : ListView.separated(
                        itemCount: controller.plans.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (_, int index) {
                          final plan = controller.plans[index];
                          final String name =
                              plan['name']?.toString() ?? 'Plan';
                          final String price = plan['price']?.toString() ?? '0';
                          final String currency =
                              plan['currency']?.toString() ?? '';
                          final String days =
                              plan['duration_days']?.toString() ?? '0';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(name),
                            subtitle: Text('$price $currency / $days days'),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await controller.getCurrentSubscription();
                        if (controller.hasActiveSubscription &&
                            mounted &&
                            Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Refresh Status'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const SubscriptionPlansScreen());
                      },
                      child: const Text('Plans'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const SubscriptionCurrentScreen());
                      },
                      child: const Text('Current'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const SubscriptionHistoryScreen());
                      },
                      child: const Text('History'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await Get.find<AuthController>().logOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

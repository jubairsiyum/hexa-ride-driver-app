import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/buy_subscription_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SubscriptionController>().getPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        centerTitle: false,
      ),
      body: GetBuilder<SubscriptionController>(
        builder: (controller) {
          if (controller.isLoading && controller.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.plans.isEmpty) {
            return const Center(
              child: Text('No plans available right now.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.getPlans(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, int index) {
                final plan = controller.plans[index];
                final String name = plan['name']?.toString() ?? 'Plan';
                final String price = plan['price']?.toString() ?? '0';
                final String currency = plan['currency']?.toString() ?? '';
                final String days = plan['duration_days']?.toString() ?? '0';

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text('$price $currency / $days days'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    onTap: () async {
                      final result = await Get.to<bool>(
                        () => BuySubscriptionScreen(plan: plan),
                      );

                      if ((result ?? false) == true &&
                          controller.hasActiveSubscription &&
                          mounted) {
                        // Optional: keep user here or refresh.
                        await controller.getCurrentSubscription();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

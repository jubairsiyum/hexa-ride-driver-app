import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';

class BuySubscriptionScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const BuySubscriptionScreen({
    super.key,
    required this.plan,
  });

  @override
  State<BuySubscriptionScreen> createState() => _BuySubscriptionScreenState();
}

class _BuySubscriptionScreenState extends State<BuySubscriptionScreen> {
  String paymentMethod = 'card';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    final String planId = widget.plan['id']?.toString() ??
        widget.plan['plan_id']?.toString() ??
        '';
    final String name = widget.plan['name']?.toString() ?? 'Plan';
    final String currency = widget.plan['currency']?.toString() ?? '';
    final String price = widget.plan['price']?.toString() ?? '0';
    final String days =
        widget.plan['duration_days']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Subscription'),
        centerTitle: false,
      ),
      body: GetBuilder<SubscriptionController>(
        builder: (c) {
          final isBusy = c.isLoading;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '$price $currency / $days days',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'wallet', child: Text('Wallet')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => paymentMethod = v);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            if (planId.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Plan id is missing in plan data.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade700,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            await controller.subscribe(
                              planId: planId,
                              paymentMethod: paymentMethod,
                              notify: true,
                            );

                            if (controller.hasActiveSubscription && mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                    child: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Subscribe'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

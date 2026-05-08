import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SubscriptionController>().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription History'),
        centerTitle: false,
      ),
      body: GetBuilder<SubscriptionController>(
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => c.getHistory(notify: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Subscription history response is not yet mapped into controller state. '
                  'API call is wired; once you share the response shape, we’ll render it here properly.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => c.getHistory(notify: true),
                    child: const Text('Refresh History'),
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

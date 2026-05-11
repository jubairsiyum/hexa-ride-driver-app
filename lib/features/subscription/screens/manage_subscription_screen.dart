import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_plans_screen.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SubscriptionController>().getCurrentSubscription(
      notify: false,
    );
  }

  String _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = _readByPossiblePath(data, key);
      if (value == null) continue;
      final s = value.toString().trim();
      if (s.isEmpty || s == 'null') continue;
      return s;
    }
    return '—';
  }

  Object? _readByPossiblePath(Map<String, dynamic> data, String keyPath) {
    // Supports "a.b.c" style.
    if (!keyPath.contains('.')) {
      return data[keyPath];
    }

    final parts = keyPath.split('.');
    Object? current = data;
    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
      if (current == null) return null;
    }
    return current;
  }

  String _readExpiresAt(Map<String, dynamic> data) {
    // Try the controller’s commonly observed places.
    final candidates = [
      'expires_at',
      'expiresAt',
      'subscription.expires_at',
      'subscription.expiresAt',
      'current_subscription.expires_at',
      'current_subscription.expiresAt',
      'subscription.subscription.expires_at',
      'subscription.subscription.expiresAt',
    ];
    return _readString(data, candidates);
  }

  DateTime? _tryParseDate(Object? raw) {
    final s = raw?.toString().trim();
    if (s == null || s.isEmpty || s == 'null') return null;
    return DateTime.tryParse(s);
  }

  bool _isActive(SubscriptionController c) {
    return c.hasActiveSubscription && c.currentSubscription != null;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscription'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.getCurrentSubscription(notify: true),
        child: GetBuilder<SubscriptionController>(
          builder: (c) {
            if (c.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (c.currentSubscription == null || !_isActive(c)) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No active subscription found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Subscribe to unlock your driver features.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const SubscriptionPlansScreen()),
                        child: const Text('Browse Plans'),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = c.currentSubscription!;
            final status = (c.currentStatus ?? 'active').toString();

            final planName = _readString(data, [
              'subscription.plan.name',
              'subscription.plan_name',
              'subscription.plan',
              'plan.name',
              'plan_name',
              'name',
              'current_subscription.plan.name',
              'current_subscription.plan_name',
            ]);

            final paymentMethod = _readString(data, [
              'payment_method',
              'subscription.payment_method',
              'current_subscription.payment_method',
              'payment.payment_method',
              'subscription.payment.payment_method',
            ]);

            final renewalDateRaw = _tryParseDate(
              _readByPossiblePath(data, 'renewal_date') ??
                  _readByPossiblePath(data, 'next_renewal_date') ??
                  _readByPossiblePath(data, 'subscription.renewal_date') ??
                  _readByPossiblePath(data, 'subscription.next_renewal_date') ??
                  _readByPossiblePath(data, 'current_subscription.renewal_date'),
            );

            final renewalDate = renewalDateRaw != null
                ? '${renewalDateRaw.toLocal()}'
                : '—';

            final expiresAt = _readExpiresAt(data);

            // If backend uses different nesting, we still show a status + dates.
            final nextRenewalHint = renewalDate != '—' ? renewalDate : expiresAt;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Subscription',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        _infoRow('Current plan', planName),
                        _infoRow('Subscription status', status),
                        _infoRow('Renewal / Expiry', nextRenewalHint),
                        _infoRow('Expires at', expiresAt),
                        _infoRow(
                          'Days remaining',
                          c.daysRemaining.toString(),
                        ),
                        _infoRow('Payment method', paymentMethod),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Actions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),

                // Upgrade
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await c.getPlans();
                      if (!mounted) return;
                      Get.to(() => const SubscriptionPlansScreen());
                    },
                    icon: const Icon(Icons.upgrade_rounded),
                    label: const Text('Upgrade Plan'),
                  ),
                ),
                const SizedBox(height: 12),

                // Renew
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await c.renew(notify: true);
                      if (!mounted) return;
                      Get.snackbar(
                        'Renewal',
                        c.hasActiveSubscription
                            ? 'Subscription renewed successfully.'
                            : 'Renewal completed, but no active subscription is available.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Renew'),
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Cancel subscription'),
                            content: const Text(
                              'Are you sure you want to cancel? Your subscription access will depend on the backend policy.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Yes, cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed != true) return;

                      await c.cancel(notify: true);
                      if (!mounted) return;

                      Get.snackbar(
                        'Cancellation',
                        c.hasActiveSubscription
                            ? 'Cancellation request completed. Please check status.'
                            : 'Subscription cancelled.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                    label: const Text(
                      'Cancel Subscription',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Manual refresh
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => c.getCurrentSubscription(notify: true),
                    child: const Text('Refresh Status'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

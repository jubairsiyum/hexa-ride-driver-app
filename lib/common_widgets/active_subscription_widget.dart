import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ActiveSubscriptionWidget extends StatelessWidget {
  const ActiveSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (controller) {
        if (controller.isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        if (!controller.hasActiveSubscription || controller.currentSubscription == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'No active subscription',
                style: textRegular.copyWith(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.75),
                ),
              ),
            ),
          );
        }

        final String status = controller.currentStatus ?? 'active';
        final String expiresAt = controller.currentSubscription?['subscription']?['expires_at']?.toString() ?? '—';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Subscription',
                  style: textBold.copyWith(color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: $status',
                  style: textRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: 0.85)),
                ),
                Text(
                  'Days remaining: ${controller.daysRemaining}',
                  style: textRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: 0.85)),
                ),
                Text(
                  'Expires: $expiresAt',
                  style: textRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: 0.65)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

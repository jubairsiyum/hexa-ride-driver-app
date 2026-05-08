import 'package:ride_sharing_user_app/features/subscription/domain/repositories/subscription_repository_interface.dart';
import 'package:ride_sharing_user_app/features/subscription/domain/services/subscription_service_interface.dart';

class SubscriptionService implements SubscriptionServiceInterface {
  final SubscriptionRepositoryInterface subscriptionRepositoryInterface;
  SubscriptionService({required this.subscriptionRepositoryInterface});

  @override
  Future getPlans() {
    return subscriptionRepositoryInterface.getPlans();
  }

  @override
  Future getCurrentSubscription() {
    return subscriptionRepositoryInterface.getCurrentSubscription();
  }

  @override
  Future getHistory() {
    return subscriptionRepositoryInterface.getHistory();
  }

  @override
  Future subscribe(String planId, String paymentMethod) {
    return subscriptionRepositoryInterface.subscribe(planId, paymentMethod);
  }

  @override
  Future renew() {
    return subscriptionRepositoryInterface.renew();
  }

  @override
  Future cancel() {
    return subscriptionRepositoryInterface.cancel();
  }

  @override
  Future checkFeature(String feature) {
    return subscriptionRepositoryInterface.checkFeature(feature);
  }
}

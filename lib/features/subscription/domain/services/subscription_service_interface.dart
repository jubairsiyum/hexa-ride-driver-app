abstract class SubscriptionServiceInterface {
  Future<dynamic> getPlans();
  Future<dynamic> getCurrentSubscription();
  Future<dynamic> getHistory();
  Future<dynamic> subscribe(String planId, String paymentMethod);
  Future<dynamic> renew();
  Future<dynamic> cancel();
  Future<dynamic> checkFeature(String feature);
}

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/subscription/domain/repositories/subscription_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class SubscriptionRepository implements SubscriptionRepositoryInterface {
  final ApiClient apiClient;
  SubscriptionRepository({required this.apiClient});

  @override
  Future<Response?> getPlans() async {
    return await apiClient.getData(AppConstants.subscriptionPlans);
  }

  @override
  Future<Response?> getCurrentSubscription() async {
    return await apiClient.getData(AppConstants.subscriptionCurrent);
  }

  @override
  Future<Response?> getHistory() async {
    return await apiClient.getData(AppConstants.subscriptionHistory);
  }

  @override
  Future<Response?> subscribe(String planId, String paymentMethod) async {
    return await apiClient.postData(AppConstants.subscriptionSubscribe, {
      'plan_id': planId,
      'payment_method': paymentMethod,
    });
  }

  @override
  Future<Response?> renew() async {
    return await apiClient.postData(AppConstants.subscriptionRenew, {});
  }

  @override
  Future<Response?> cancel() async {
    return await apiClient.postData(AppConstants.subscriptionCancel, {});
  }

  @override
  Future<Response?> checkFeature(String feature) async {
    return await apiClient.postData(AppConstants.subscriptionCheckFeature, {
      'feature': feature,
    });
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }
}

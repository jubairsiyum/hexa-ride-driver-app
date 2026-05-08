import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/interface/repository_interface.dart';

abstract class SubscriptionRepositoryInterface implements RepositoryInterface {
  Future<Response?> getPlans();
  Future<Response?> getCurrentSubscription();
  Future<Response?> getHistory();
  Future<Response?> subscribe(String planId, String paymentMethod);
  Future<Response?> renew();
  Future<Response?> cancel();
  Future<Response?> checkFeature(String feature);
}

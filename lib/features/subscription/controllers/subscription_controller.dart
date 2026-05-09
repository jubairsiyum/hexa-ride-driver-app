import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/subscription/domain/services/subscription_service_interface.dart';

class SubscriptionController extends GetxController implements GetxService {
  final SubscriptionServiceInterface subscriptionServiceInterface;
  SubscriptionController({required this.subscriptionServiceInterface});

  bool isLoading = false;
  bool hasActiveSubscription = false;
  int daysRemaining = 0;
  Map<String, dynamic>? currentSubscription;
  List<Map<String, dynamic>> plans = <Map<String, dynamic>>[];
  String? currentStatus;

  Future<void> getPlans({bool notify = true}) async {
    Response response = await subscriptionServiceInterface.getPlans();
    plans = <Map<String, dynamic>>[];

    if (response.statusCode == 200 && response.body is Map) {
      final Map body = response.body as Map;
      final Object? dataRaw = body['data'];
      if (body['success'] == true && dataRaw is List) {
        plans = dataRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    if (notify) {
      update();
    }
  }

  Future<void> getCurrentSubscription({bool notify = true}) async {
    isLoading = true;
    if (notify) {
      update();
    }

    Response response =
        await subscriptionServiceInterface.getCurrentSubscription();

    if (response.statusCode == 200 && response.body is Map) {
      final Map body = response.body as Map;
      if (body['success'] == true) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(body['data'] ?? {});
        _applyCurrentSubscription(data);
      } else {
        hasActiveSubscription = false;
        currentSubscription = null;
        currentStatus = null;
        daysRemaining = 0;
      }
    } else {
      ApiChecker.checkApi(response);
      hasActiveSubscription = false;
      currentSubscription = null;
      currentStatus = null;
      daysRemaining = 0;
    }

    isLoading = false;
    if (notify) {
      update();
    }
  }

  Future<void> getHistory({bool notify = true}) async {
    isLoading = true;
    if (notify) update();

    try {
      final Response response =
          await subscriptionServiceInterface.getHistory();

      if (response.statusCode == 200) {
        // The app currently doesn't persist history in state.
        // We keep this method for wiring UI/actions later.
        // If you want, we can add `history` model/state in the controller.
      } else {
        ApiChecker.checkApi(response);
      }
    } finally {
      // Always reset loading flag to prevent infinite spinners.
      isLoading = false;
      if (notify) update();
    }
  }

  Future<void> subscribe({
    required String planId,
    required String paymentMethod,
    bool notify = true,
  }) async {
    isLoading = true;
    if (notify) update();

    final Response response =
        await subscriptionServiceInterface.subscribe(planId, paymentMethod);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // After successful subscribe, refresh current subscription status
      await getCurrentSubscription(notify: notify);
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    if (notify) update();
  }

  Future<void> renew({bool notify = true}) async {
    isLoading = true;
    if (notify) update();

    final Response response = await subscriptionServiceInterface.renew();

    if (response.statusCode == 200 || response.statusCode == 201) {
      await getCurrentSubscription(notify: notify);
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    if (notify) update();
  }

  Future<void> cancel({bool notify = true}) async {
    isLoading = true;
    if (notify) update();

    final Response response = await subscriptionServiceInterface.cancel();

    if (response.statusCode == 200 || response.statusCode == 201) {
      await getCurrentSubscription(notify: notify);
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    if (notify) update();
  }

  Future<bool> checkFeature({
    required String feature,
    bool notify = false,
  }) async {
    isLoading = true;
    if (notify) update();

    final Response response =
        await subscriptionServiceInterface.checkFeature(feature);

    if (response.statusCode == 200 && response.body is Map) {
      final Map body = response.body as Map;
      // Typical Laravel shape: { success: true, data: { enabled: true } }
      // We'll handle a couple of likely keys safely.
      final Object? dataRaw = body['data'];
      if (dataRaw is Map) {
        final Object? enabledRaw = dataRaw['enabled'] ?? dataRaw['value'];
        if (enabledRaw is bool) {
          return enabledRaw;
        }
        if (enabledRaw is num) {
          return enabledRaw != 0;
        }
        final Object? hasRaw = dataRaw['has_feature'] ?? dataRaw['has'];
        if (hasRaw is bool) return hasRaw;
      }
      // Fallback: if success true but data parsing fails, assume false.
      return body['success'] == true;
    }

    ApiChecker.checkApi(response);
    return false;
  }

  void _applyCurrentSubscription(Map<String, dynamic> data) {
    currentSubscription = data;

    // Helper to read "num/string/date-like" safely.
    DateTime? _parseDate(Object? raw) {
      final String? s = raw?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    // 1) Days remaining (support multiple nesting)
    final Object? daysRaw =
        data['days_remaining'] ??
        (data['subscription'] is Map ? (data['subscription'] as Map)['days_remaining'] : null) ??
        (data['current_subscription'] is Map
            ? (data['current_subscription'] as Map)['days_remaining']
            : null);

    if (daysRaw is num) {
      daysRemaining = daysRaw.toInt();
    } else {
      daysRemaining = 0;
    }

    // 2) Subscription object (support multiple keys)
    final Object? subscriptionRaw =
        data['subscription'] ?? data['current_subscription'];

    Map<String, dynamic>? subscription;
    if (subscriptionRaw is Map) {
      subscription = Map<String, dynamic>.from(subscriptionRaw);
    }

    // Some backends return: data.subscription.subscription.{status, expires_at}
    // So we try to "drill" one level if that nested object exists.
    final Map<String, dynamic>? nestedSubscription = subscription?['subscription'] is Map
        ? Map<String, dynamic>.from(subscription!['subscription'] as Map)
        : null;

    final Map<String, dynamic>? effectiveSubscription =
        nestedSubscription ?? subscription;

    // 3) Status/expires_at (support at root or inside subscription)
    final Object? statusRaw =
        effectiveSubscription?['status'] ?? data['status'];
    currentStatus = statusRaw?.toString();

    final Object? expiresAtRaw = effectiveSubscription?['expires_at'] ??
        effectiveSubscription?['expiresAt'] ??
        data['expires_at'] ??
        data['expiresAt'];
    final DateTime? expiresAt = _parseDate(expiresAtRaw);

    // Be tolerant: sometimes backend may not return `status`, but does return `expires_at`.
    bool isActive = currentStatus == 'active';

    if (expiresAt != null) {
      // If expires_at is present and not expired, consider it active even if status is missing.
      final bool notExpired = expiresAt.isAfter(DateTime.now());
      isActive = notExpired && (isActive || currentStatus == null);
    }

    hasActiveSubscription = isActive;
  }
}

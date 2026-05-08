import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_bottomsheet_widget.dart';
import 'package:ride_sharing_user_app/features/html/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/safety_setup/screens/safety_setup_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/payment_info_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/chat/screens/chat_screen.dart';
import 'package:ride_sharing_user_app/features/help_and_support/screens/help_and_support_screen.dart';
import 'package:ride_sharing_user_app/features/html/screens/policy_viewer_screen.dart';
import 'package:ride_sharing_user_app/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_level_widget.dart';
import 'package:ride_sharing_user_app/features/review/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/setting/screens/setting_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/controllers/subscription_controller.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/buy_subscription_screen.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_current_screen.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_history_screen.dart';
import 'package:ride_sharing_user_app/features/subscription/screens/subscription_plans_screen.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  @override
  void initState() {
    Get.find<RideController>().updateRoute(true, notify: false);
    super.initState();
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        14,
        Dimensions.paddingSizeDefault,
        10,
      ),
      child: Text(
        text,
        style: textSemiBold.copyWith(
          color: Get.isDarkMode
              ? Theme.of(context).textTheme.bodyMedium?.color
              : Theme.of(context).cardColor,
          fontSize: Dimensions.fontSizeLarge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          const ProfileLevelWidgetWidget(),
          const SizedBox(height: 25),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Images.profileIcon,
                    title: 'Profile',
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),
                  ProfileMenuItem(
                    icon: Images.message,
                    title: 'Messages',
                    onTap: () => Get.to(() => const ChatScreen()),
                  ),
                  ProfileMenuItem(
                    icon: Images.destinationIcon,
                    title: 'My Reviews',
                    onTap: () => Get.to(() => const ReviewScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'Safety',
                    icon: Images.privacyPolicy,
                    onTap: () => Get.to(() => const SafetySetupScreen()),
                  ),
                  ProfileMenuItem(
                    icon: Images.leaderBoardIcon,
                    title: 'Leaderboard',
                    onTap: () => Get.to(() => const LeaderboardScreen()),
                  ),
                  if ((Get.find<SplashController>().config?.referralEarningStatus ?? false) ||
                      ((Get.find<ProfileController>().profileInfo?.wallet?.referralEarn ?? 0) > 0))
                    ProfileMenuItem(
                      icon: Images.referralIcon1,
                      title: 'Refer & Earn',
                      onTap: () => Get.to(() => const ReferAndEarnScreen()),
                    ),
                  ProfileMenuItem(
                    icon: Images.leaderBoardIcon,
                    title: 'Add Withdrawal Info',
                    onTap: () => Get.to(() => const PaymentInfoScreen()),
                  ),
                  ProfileMenuItem(
                    icon: Images.helpAndSupportIcon,
                    title: 'Help & Support',
                    onTap: () => Get.to(() => const HelpAndSupportScreen()),
                  ),
                  ProfileMenuItem(
                    icon: Images.setting,
                    title: 'Settings',
                    onTap: () => Get.to(() => const SettingScreen()),
                  ),

                  // Policies
                  _sectionTitle('Policies'),
                  ProfileMenuItem(
                    icon: Images.privacyPolicy,
                    title: 'Privacy Policy',
                    onTap: () => Get.to(
                      () => PolicyViewerScreen(
                        htmlType: HtmlType.privacyPolicy,
                        image: Get.find<SplashController>().config?.privacyPolicy?.image ?? '',
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Images.termsAndCondition,
                    title: 'Terms & Conditions',
                    onTap: () => Get.to(
                      () => PolicyViewerScreen(
                        htmlType: HtmlType.termsAndConditions,
                        image: Get.find<SplashController>().config?.termsAndConditions?.image ?? '',
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Images.termsAndCondition,
                    title: 'Refund Policy',
                    onTap: () => Get.to(
                      () => PolicyViewerScreen(
                        htmlType: HtmlType.refundPolicy,
                        image: Get.find<SplashController>().config?.refundPolicy?.image ?? '',
                      ),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Images.privacyPolicy,
                    title: 'Legal',
                    onTap: () => Get.to(
                      () => PolicyViewerScreen(
                        htmlType: HtmlType.legal,
                        image: Get.find<SplashController>().config?.legal?.image ?? '',
                      ),
                    ),
                  ),

                  // Subscription (grouped + user-friendly text)
                  _sectionTitle('Subscriptions'),
                  GetBuilder<SubscriptionController>(
                    builder: (s) {
                      final bool isActive = s.hasActiveSubscription;

                      return ProfileMenuItem(
                        icon: Images.paymentIcon,
                        title: isActive ? 'My Subscription' : 'Buy Subscription',
                        onTap: () async {
                          // Keep existing functionality exactly as-is, only user-facing labels change.
                          if (!isActive) {
                            await s.getPlans();
                            Get.to(() => const SubscriptionPlansScreen());
                          } else {
                            await s.getCurrentSubscription(notify: false);
                            Get.to(() => const SubscriptionCurrentScreen());
                          }
                        },
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Images.calenderIcon,
                    title: 'Subscription History',
                    onTap: () => Get.to(() => const SubscriptionHistoryScreen()),
                  ),
                  ProfileMenuItem(
                    icon: Images.loyaltyPoint,
                    title: 'Subscription Plans',
                    onTap: () => Get.to(() => const SubscriptionPlansScreen()),
                  ),

                  // Logout
                  _sectionTitle('Account'),
                  ProfileMenuItem(
                    icon: Images.logOutIcon,
                    title: 'Logout',
                    onTap: () {
                      Get.bottomSheet(
                        GetBuilder<AuthController>(
                          builder: (authController) {
                            return ConfirmationBottomsheetWidget(
                              icon: Images.exitIcon,
                              iconColor: Theme.of(context).cardColor,
                              isLoading: authController.logging,
                              title: 'logout'.tr,
                              description: 'do_you_want_to_log_out_this_account'.tr,
                              onYesPressed: () => authController.logOut(),
                              onNoPressed: () => Get.back(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Images.logOutIcon,
                    title: 'Permanently Delete Account',
                    onTap: () {
                      Get.bottomSheet(
                        GetBuilder<AuthController>(
                          builder: (authController) {
                            return ConfirmationBottomsheetWidget(
                              icon: Images.exitIcon,
                              isLoading: authController.logging,
                              iconColor: Theme.of(context).cardColor,
                              isLogOut: true,
                              title: 'delete_account'.tr,
                              description: 'permanently_delete_confirm_msg'.tr,
                              onNoPressed: () => Get.back(),
                              onYesPressed: () => authController.permanentDelete(),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final Function()? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
          ),
          child: Row(
            children: [
              SizedBox(
                width: Dimensions.iconSizeLarge,
                child: Image.asset(
                  icon,
                  color: Get.isDarkMode
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Text(
                title,
                style: textSemiBold.copyWith(
                  color: Get.isDarkMode
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).cardColor,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

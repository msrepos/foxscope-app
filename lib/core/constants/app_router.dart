import 'package:flutter/material.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:foxscope/features/auth/presentation/pages/forget_password_page.dart';
import 'package:foxscope/features/auth/presentation/pages/signup_module/create_account.dart';
import 'package:foxscope/features/auth/presentation/pages/signup_module/create_password.dart';
import 'package:foxscope/features/auth/presentation/pages/signup_module/setup_profile.dart';
import 'package:foxscope/features/auth/presentation/pages/verify_account_signin_page.dart';
import 'package:foxscope/features/market/presentation/pages/paying_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/profile_module/change_email_address.dart';
import '../../features/auth/presentation/pages/profile_module/change_email_p2.dart';
import '../../features/auth/presentation/pages/profile_module/change_password.dart';
import '../../features/auth/presentation/pages/profile_module/change_password_p2.dart';
import '../../features/auth/presentation/pages/profile_module/edit_profile.dart';
import '../../features/auth/presentation/pages/signup_module/verify_account.dart';
import '../../features/home/presentation/pages/qr_code_page.dart';
import '../../features/market/presentation/pages/profile_market_place.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/scope/presentation/pages/edit_saved_scope.dart';
import '../../features/scope/presentation/pages/edit_scope.dart';
import '../../features/scope/presentation/pages/scope_page.dart';
import '../../features/scope/presentation/pages/saved_page.dart';
import '../../features/group/presentation/pages/group_page.dart';
import '../../features/scope/presentation/pages/status_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/scope/presentation/pages/create_page.dart';
import '../../features/scope/presentation/pages/map_page.dart';
import '../../features/scope/presentation/pages/send_page.dart';
import '../../features/scope/presentation/pages/scan_page.dart';
import '../../features/market/presentation/pages/market_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/settings/presentation/pages/privacy_page.dart';
import '../../features/settings/presentation/pages/policy_page.dart';
import '../../features/settings/presentation/pages/terms_page.dart';
import '../../features/settings/presentation/pages/help_page.dart';
import '../../features/settings/presentation/pages/language_page.dart';
import '../../main.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [
      routeObserver,
    ],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final userId = state.extra as String?;
          return HomeScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverPage(),
      ),
      GoRoute(
        path: '/scopes',
        builder: (context, state) {
          final initialTab = state.extra as int? ?? 0;
          return ScopePage(initialTabIndex: initialTab);
        },
      ),
      GoRoute(
        path: '/scope-create',
        builder: (context, state) {
          final selectedLocation = state.extra as GeoLocation; //must pass this value
          return CreateScopePage(selectedLocation: selectedLocation);
        },
      ),

      GoRoute(
        path: '/scope-map',
        builder: (context, state) {
          final bool returnOnly = state.extra == true;

          return MapScopePage(
            returnLocationOnly: returnOnly,
          );
        },
      ),

      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedPage(),
      ),
      GoRoute(
        path: '/status',
        builder: (context, state) => const StatusPage(),
      ),
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupPage(),
      ),
      GoRoute(
        path: '/send',
        builder: (context, state) => const SendPage(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanPage(),
      ),
      GoRoute(
        path: '/market',
        builder: (context, state) {
          final initialTab = state.extra as int? ?? 0;
          return MarketPage(initialTabIndex: initialTab);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final initialIndex = state.extra as int? ?? 0; // 0 = chats, 1 = favourites
          return ChatPage(initialTabIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/policy',
        builder: (context, state) => const PolicyPage(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsPage(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguagePage(),
      ),

      //Hagar -- Profile==================================
      GoRoute(
        path: '/editProfile',
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: '/changeEmailS1',
        builder: (context, state) => const ChangeEmailScreen1(),
      ),
      GoRoute(
        path: '/changePasswordS1',
        builder: (context, state) => const ChangePasswordScreen1(),
      ),
      GoRoute(
        path: '/changePasswordS2',
        builder: (context, state) => const ChangePasswordScreen2(),
      ),
      GoRoute(
        path: '/changeEmailS2',
        builder: (context, state) => const ChangeEmailScreen2(),
      ),
      GoRoute(
        path: '/forgetPassword',
        builder: (context, state) => const ForgetPasswordPage(),
      ),
      GoRoute(
        path: '/verifyAccountSignIn',
        builder: (context, state) => const VerifyAccountSignIn(),
      ),
      GoRoute(
        path: '/setUpProfile',
        builder: (context, state) => const SetupProfilePage(),
      ),
      GoRoute(
        path: '/verifyAccountSignUp',
        builder: (context, state) => const VerifyAccount(),
      ),
      GoRoute(
        path: '/createPassword',
        builder: (context, state) => const CreatePassword(),
      ),
      GoRoute(
        path: '/createAccount',
        builder: (context, state) => const CreateAccount(),
      ),
      GoRoute(
        path: '/QrCodePage',
        builder: (context, state) => const QrCodePage(),
      ),
      GoRoute(
        path: '/ProfileMarketPlace',
        builder: (context, state) => const ProfileCard(myItems: false,),
      ),
      // GoRoute(
      //   path: '/PaymentGateway',
      //   builder: (context, state) => const PaymentGateway(),
      // ),
      // GoRoute(
      //   path: '/EditScope',
      //   builder: (context, state) => const EditScope(),
      // ),
      GoRoute(
        path: '/scope/:identifier/:id',
        builder: (context, state) {
          final identifier = state.pathParameters['identifier']!;
          final id = state.pathParameters['id']!;

          debugPrint('🧭 GoRouter matched /scope/$identifier');

          return EditScope(
            identifier: identifier, // ✅ STRING, NO PARSING
            id: id,
          );
        },
      ),



      GoRoute(
        path: '/savedScope/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];

          debugPrint('🧭 GoRouter matched /scope/$id');

          return EditSavedScope(
            scopeId: int.parse(id!),
          );
        },
      ),


    ],
  );
}

import 'package:flutter/material.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
          final userId = state.extra as int?;   // <-- allow null
          return HomeScreen(userId: userId);   // <-- pass nullable
        },
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverPage(),
      ),
      GoRoute(
        path: '/scope',
        builder: (context, state) => const ScopePage(),
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
        builder: (context, state) => const MapScopePage(),
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
        builder: (context, state) => const MarketPage(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatPage(),
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
    ],
  );
}

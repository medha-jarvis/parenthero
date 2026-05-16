import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/dashboard/screens/parent_dashboard.dart';
import 'features/campaign/screens/campaign_list_screen.dart';
import 'features/campaign/screens/campaign_detail_screen.dart';
import 'features/campaign/screens/day_view_screen.dart';
import 'features/teaching/screens/teaching_script_screen.dart';
import 'features/practice/screens/practice_pad_screen.dart';
import 'features/quiz/screens/quiz_screen.dart';
import 'features/quiz/screens/quiz_review_screen.dart';
import 'features/beat_parent/screens/beat_parent_screen.dart';
import 'features/certificate/screens/certificate_screen.dart';
import 'features/certificate/screens/certificate_share_sheet.dart';
import 'features/arcade/screens/arcade_screen.dart';
import 'features/arcade/screens/number_rush_game.dart';
import 'features/arcade/screens/sort_it_game.dart';
import 'features/arcade/screens/word_builder_game.dart';
import 'features/subscription/screens/plans_screen.dart';
import 'features/subscription/screens/paywall_screen.dart';
import 'features/parent_dashboard/screens/analytics_screen.dart';
import 'features/search/screens/topic_search_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'providers/auth_provider.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation.startsWith('/auth');
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplash) return null;

      if (!isLoggedIn && !isAuth && !isOnboarding) {
        return '/auth/sign-in';
      }

      if (isLoggedIn && isAuth) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/campaigns',
        builder: (context, state) => const CampaignListScreen(),
      ),
      GoRoute(
        path: '/campaign/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CampaignDetailScreen(campaignId: id);
        },
      ),
      GoRoute(
        path: '/campaign/:id/day/:day',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final day = int.parse(state.pathParameters['day']!);
          return DayViewScreen(campaignId: id, day: day);
        },
      ),
      GoRoute(
        path: '/teaching/:topicId/:day',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final day = int.parse(state.pathParameters['day']!);
          return TeachingScriptScreen(topicId: topicId, day: day);
        },
      ),
      GoRoute(
        path: '/practice/:topicId/:day',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final day = int.parse(state.pathParameters['day']!);
          return PracticePadScreen(topicId: topicId, day: day);
        },
      ),
      GoRoute(
        path: '/quiz/:topicId/:day',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final day = int.parse(state.pathParameters['day']!);
          return QuizScreen(topicId: topicId, day: day);
        },
      ),
      GoRoute(
        path: '/quiz/:topicId/:day/review',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final day = int.parse(state.pathParameters['day']!);
          return QuizReviewScreen(topicId: topicId, day: day);
        },
      ),
      GoRoute(
        path: '/beat-parent/:topicId/:day',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          final day = int.parse(state.pathParameters['day']!);
          return BeatParentScreen(topicId: topicId, day: day);
        },
      ),
      GoRoute(
        path: '/certificate/:campaignId',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return CertificateScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/certificate/:campaignId/share',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return CertificateShareSheet(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/arcade',
        builder: (context, state) => const ArcadeScreen(),
      ),
      GoRoute(
        path: '/arcade/number-rush',
        builder: (context, state) => const NumberRushGame(),
      ),
      GoRoute(
        path: '/arcade/sort-it',
        builder: (context, state) => const SortItGame(),
      ),
      GoRoute(
        path: '/arcade/word-builder',
        builder: (context, state) => const WordBuilderGame(),
      ),
      GoRoute(
        path: '/subscription/plans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: '/subscription/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const TopicSearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class ParentHeroApp extends ConsumerWidget {
  const ParentHeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'ParentHero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}

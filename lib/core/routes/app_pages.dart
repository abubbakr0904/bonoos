import 'package:bonoos/features/on_boarding/first_enter_screen.dart';
import 'package:bonoos/features/auth/login_phone_screen.dart';
import 'package:bonoos/features/auth/otp_screen.dart';
import 'package:bonoos/features/questions/question_screen.dart';
import 'package:bonoos/features/home/message_of_day_screen.dart';
import 'package:bonoos/features/home/self_talk_topics_screen.dart';
import 'package:bonoos/features/home/self_talk_questions_screen.dart';
import 'package:bonoos/features/home/audio_screen.dart';
import 'package:bonoos/features/notification/notifications_screen.dart';
import 'package:bonoos/features/playlist/playlist_screen.dart';
import 'package:bonoos/features/breath/breath_session_screen.dart';
import 'package:bonoos/features/splash/splash_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:bonoos/features/breath/breathing_practices_screen.dart';
import 'package:bonoos/features/chat/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class RouteGenerate {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashScreen.routeName,
    routes: <RouteBase>[
      GoRoute(
        path: SplashScreen.routeName,
        name: SplashScreen.routeName,
        builder: (_, __) => const SplashScreen(),
      ),

      GoRoute(
        path: FirstEnterScreen.routeName,
        name: FirstEnterScreen.routeName,
        builder: (_, __) => const FirstEnterScreen(),
      ),

      GoRoute(
        path: QuestionScreen.routeName,
        name: QuestionScreen.routeName,
        builder: (_, __) => const QuestionScreen(),
      ),

      GoRoute(
        path: LoginPhoneScreen.routeName,
        name: LoginPhoneScreen.routeName,
        builder: (_, __) => const LoginPhoneScreen(),
      ),

      GoRoute(
        path: OtpScreen.routeName,
        name: OtpScreen.routeName,
        builder: (_, state) {
          final args = state.extra as OtpArgs?;
          return OtpScreen(
            args: args ?? const OtpArgs(phone: '+998', phoneDigits: ''),
          );
        },
      ),

      GoRoute(
        path: TabBoxScreen.routeName,
        name: TabBoxScreen.routeName,
        builder: (_, __) => const TabBoxScreen(),
      ),

      GoRoute(
        path: MessageOfDayScreen.routeName,
        name: MessageOfDayScreen.routeName,
        builder: (_, state) {
          final key = state.extra as Key?;
          return MessageOfDayScreen(key: key);
        },
      ),

      GoRoute(
        path: NotificationsScreen.routeName,
        name: NotificationsScreen.routeName,
        builder: (_, __) => const NotificationsScreen(),
      ),

      GoRoute(
        path: PlaylistScreen.routeName,
        name: PlaylistScreen.routeName,
        builder: (_, state) => PlaylistScreen(initialCategoryId: state.extra as int?),
      ),

      GoRoute(
        path: SelfTalkTopicsScreen.routeName,
        name: SelfTalkTopicsScreen.routeName,
        builder: (_, __) => const SelfTalkTopicsScreen(),
      ),

      GoRoute(
        path: SelfTalkQuestionsScreen.routeName,
        name: SelfTalkQuestionsScreen.routeName,
        builder: (_, state) {
          final extra = state.extra as TopicSwipeArgs?;
          return SelfTalkQuestionsScreen(
            args: extra ?? const TopicSwipeArgs(topicId: 0, title: ''),
          );
        },
      ),

      GoRoute(
        path: AudioScreen.routeName,
        name: AudioScreen.routeName,
        builder: (_, state) {
          final args = state.extra as AudioScreenArgs?;
          return AudioScreen(
            title: args?.title ?? "Audio",
            durationLabel: args?.durationLabel ?? "15 Minutes",
            audioUrl: args?.audioUrl ??
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            auditionId: args?.auditionId,
            auditionType: args?.auditionType,
            durationSeconds: args?.durationSeconds,
            initialFavorited: args?.initialFavorited,
            categoryIdForSync: args?.categoryIdForSync,
            onAuditionsSynced: args?.onAuditionsSynced,
            syncHomeAuditionsAfterFavorite:
                args?.syncHomeAuditionsAfterFavorite ?? false,
          );
        },
      ),

      GoRoute(
        path: BreathSessionScreen.routeName,
        name: BreathSessionScreen.routeName,
        builder: (_, state) {
          final args = state.extra as BreathSessionArgs?;
          return BreathSessionScreen(
            title: args?.title ?? '',
            duration: args?.duration ?? 1,
            themeKey: args?.themeKey ?? 3,
          );
        },
      ),

      GoRoute(
        path: BreathingPracticesScreen.routeName,
        name: BreathingPracticesScreen.routeName,
        builder: (_, state) {
          final openFavorites = state.extra as bool? ?? false;
          return BreathingPracticesScreen(
            openFavoritesOnStart: openFavorites,
          );
        },
      ),

      GoRoute(
        path: ChatScreen.routeName,
        name: ChatScreen.routeName,
        builder: (_, __) => const ChatScreen(),
      ),

      ///navBar
      // StatefulShellRoute.indexedStack(
      //    builder:
      //        (
      //          BuildContext context,
      //          GoRouterState state,
      //          StatefulNavigationShell navigationShell,
      //        ) {
      //          return MainPage(child: navigationShell);
      //        },
      //    branches: <StatefulShellBranch>[
      //      // StatefulShellBranch(
      //      //   navigatorKey: _sectionANavigatorKey,
      //      //   routes: <RouteBase>[
      //      //     GoRoute(
      //      //       path: AppRoutes.home,
      //      //       name: AppRoutes.home,
      //      //       pageBuilder: (BuildContext context, GoRouterState state) {
      //      //         return buildPageWithDefaultTransition<void>(
      //      //           context: context,
      //      //           state: state,
      //      //           child: const HomeScreen(),
      //      //         );
      //      //       },
      //      //     ),
      //      //   ],
      //      // ),
      //    ],
      //  ),
    ],
  );
}

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 0),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

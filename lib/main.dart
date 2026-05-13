import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:bonoos/core/routes/app_pages.dart';
import 'package:bonoos/core/services/app_version/app_update_service.dart';
import 'package:bonoos/core/utils/pref_manager.dart';
import 'package:bonoos/features/alarm/alarm_service.dart';
import 'package:bonoos/features/medicine/medicine_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/utils/last_listened_manager.dart';
import 'core/values/app_theme.dart';
import 'core/values/app_colors.dart';
import 'di.dart';
import 'features/common/cubit/settings_cubit.dart';
import 'package:bonoos/features/splash/splash_screen.dart';
import 'package:bonoos/features/profile/security_service.dart';
import 'package:bonoos/features/profile/passcode_screen.dart';
import 'package:go_router/go_router.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppUpdateService.getCloudVersion();
  await dotenv.load(fileName: "assets/.env");

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDi();
  await Alarm.init();
  await MedicineService.init();
  await AlarmService.syncAlarmsWithEngine();
  await MedicineService.syncMedicinesWithEngine();

  await LastListenedManager.init(inject<SharedPreferences>());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => inject<SettingsCubit>())],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ScreenUtilInit(
            minTextAdapt: true,
            designSize: const Size(375, 812),
            builder: (context, c) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SafeArea(
                  top: false,
                  bottom: Platform.isAndroid,
                  child: MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    title: "Bonoos",
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: ThemeMode.light,
                    locale: state.language,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      S.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'),
                      Locale('ru'),
                      Locale('uz'),
                      Locale('uz', 'Cyrl'),
                    ],
                    routerConfig: RouteGenerate.router,
                    builder: (context, child) {
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: AuthWrapper(child: child!),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _authenticated = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    SecurityService.splashActive.addListener(_onSplashChanged);
    RouteGenerate.router.routerDelegate.addListener(_onRouteChanged);
  }

  void _onSplashChanged() {
    if (mounted) setState(() {});
  }

  void _onRouteChanged() {
    if (mounted) {
      // Use post-frame callback to avoid "setState during build" error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuth();
      });
    }
  }

  @override
  void dispose() {
    SecurityService.splashActive.removeListener(_onSplashChanged);
    RouteGenerate.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _checkAuth() async {
    final pref = inject<PrefManager>();
    final hasToken = pref.token != null && pref.token!.isNotEmpty;
    
    final pinEnabled = await SecurityService.isPinEnabled();
    final pinSet = await SecurityService.isPinSet();
    
    // Lock ONLY if user is logged in AND PIN is enabled AND set
    final shouldLock = hasToken && pinEnabled && pinSet;
    
    debugPrint('AuthWrapper: hasToken=$hasToken, pinEnabled=$pinEnabled, pinSet=$pinSet, shouldLock=$shouldLock');
    
    if (mounted) {
      if (_authenticated != !shouldLock || _checking) {
        setState(() {
          _authenticated = !shouldLock;
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return Scaffold(backgroundColor: AppColors.mainBgColor);

    // 1. If Splash is active, ALWAYS show it first.
    if (SecurityService.splashActive.value) {
      return widget.child;
    }

    // 2. If PIN is enabled and not yet authenticated, show PasscodeScreen
    if (!_authenticated) {
      return Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => PasscodeScreen(
            mode: PasscodeMode.verify,
            onSuccess: () {
              setState(() => _authenticated = true);
            },
          ),
        ),
      );
    }

    // 3. Otherwise show the actual content
    return widget.child;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}

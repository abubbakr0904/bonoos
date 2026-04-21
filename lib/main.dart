import 'dart:io';

import 'package:bonoos/core/routes/app_pages.dart';
import 'package:bonoos/core/services/app_version/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/last_listened_manager.dart';
import 'core/values/app_theme.dart';
import 'di.dart';
import 'features/common/cubit/settings_cubit.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppUpdateService.getCloudVersion();

  await dotenv.load(fileName: "assets/.env");

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDi();

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
                    // navigatorKey: navigatorKey,
                    builder: (context, child) {
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: child!,
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

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

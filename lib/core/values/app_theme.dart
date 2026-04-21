import 'package:bonoos/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_text_styles.dart';

/// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  cardColor: AppColors.white,

  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.primaryGreen, brightness: Brightness.light),
  fontFamily: "Roboto",
  iconTheme: const IconThemeData(color: AppColors.black),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      // backgroundColor: AppColors.grey200,
      shape: const CircleBorder(),
    ),
  ),
  tabBarTheme: const TabBarThemeData(dividerColor: AppColors.transparent),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: AppColors.white),
  checkboxTheme: const CheckboxThemeData(side: BorderSide(color: AppColors.borderSecondary)),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    surfaceTintColor: AppColors.white,
    backgroundColor: AppColors.white,
    iconTheme: IconThemeData(color: Colors.black),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
    centerTitle: true,
  ),
  textTheme: TextTheme(
    displayLarge: AppTextStyles.body24w5.copyWith(color: AppColors.black),
    displayMedium: AppTextStyles.body14w4.copyWith(color: AppColors.textBrand),
    displaySmall: AppTextStyles.body10w4.copyWith(color: AppColors.textSecondary),
    headlineMedium: AppTextStyles.body24w4.copyWith(color: AppColors.black),
    headlineLarge: AppTextStyles.body18w5.copyWith(color: AppColors.black),
    headlineSmall: AppTextStyles.body16w4.copyWith(color: AppColors.black),
    titleLarge: AppTextStyles.body20w5.copyWith(color: AppColors.black),
    titleMedium: AppTextStyles.body16w4.copyWith(color: AppColors.black),
    titleSmall: AppTextStyles.body12w4.copyWith(color: AppColors.textSecondary),
    bodyLarge: AppTextStyles.body16w4.copyWith(color: AppColors.black),
    bodyMedium: AppTextStyles.body16w4,
    bodySmall: AppTextStyles.body12w4.copyWith(color: AppColors.textSecondary),
  ),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppColors.white),
datePickerTheme: DatePickerThemeData(
  todayBackgroundColor: WidgetStateProperty.fromMap({
    MaterialState.selected: AppColors.primaryGreen,
    MaterialState.any: AppColors.primaryGreenLight,
    MaterialState.pressed: AppColors.primaryGreenLight,

  }),
  cancelButtonStyle: ButtonStyle(
    foregroundColor: MaterialStateProperty.all(AppColors.primaryGreen.withValues(alpha: 0.8)),
  ),
  confirmButtonStyle: ButtonStyle(
    foregroundColor: MaterialStateProperty.all(AppColors.primaryGreen),
  ),
  dayBackgroundColor: WidgetStateProperty.fromMap({
    MaterialState.selected: AppColors.primaryGreen,
    MaterialState.any: AppColors.white,
    MaterialState.pressed: AppColors.primaryGreenLight,

  }),

),
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primarySwatch: Colors.red,
  canvasColor: AppColors.white,
  primaryColor: AppColors.primaryGreen,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);

/// Dark Theme
final ThemeData darkTheme = ThemeData(
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      // backgroundColor: AppColors.tertiary,
      shape: const CircleBorder(),
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.white),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.primaryGreen, brightness: Brightness.dark),
  checkboxTheme: const CheckboxThemeData(side: BorderSide(color: AppColors.borderSecondary)),
  canvasColor: AppColors.c404040,
  fontFamily: "Roboto",
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.black,
    surfaceTintColor
        : AppColors.black,
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
    centerTitle: true,
  ),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppColors.black),
  textTheme: TextTheme(
    displayLarge: AppTextStyles.body24w4.copyWith(color: AppColors.white),
    displayMedium: AppTextStyles.body14w4.copyWith(color: AppColors.textPrimaryLight),
    displaySmall: AppTextStyles.body10w4.copyWith(color: AppColors.textSecondary),
    headlineMedium: AppTextStyles.body24w4.copyWith(color: AppColors.white),
    headlineLarge: AppTextStyles.body18w4.copyWith(color: AppColors.white),
    headlineSmall: AppTextStyles.body16w4.copyWith(color: AppColors.white),
    titleLarge: AppTextStyles.body20w4.copyWith(color: AppColors.white),
    titleMedium: AppTextStyles.body16w4.copyWith(color: AppColors.white),
    titleSmall: AppTextStyles.body12w4.copyWith(color: AppColors.textSecondary),
    bodyLarge: AppTextStyles.body16w4.copyWith(color: AppColors.white),
    bodyMedium: AppTextStyles.body16w4,
    bodySmall: AppTextStyles.body12w4.copyWith(color: AppColors.textSecondary),
  ),
  cardColor: AppColors.darkCardColor,
  scaffoldBackgroundColor: AppColors.black,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primarySwatch: Colors.red,
  primaryColor: AppColors.primaryGreen,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);

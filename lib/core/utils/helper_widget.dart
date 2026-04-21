import 'package:bonoos/core/extension/for_context.dart';
import 'package:bonoos/core/routes/app_pages.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:flutter/material.dart';

String elon =
    "https://www.gipr.uz/files/01-2024/ad20104/bannierlarda-rieklama-riek-1305947804_large.webp";
String news =
    "https://static.1tv.ru/uploads/video/material/splash/2024/11/12/913099/_original/913099_2fa85cecc2.jpg";
String elon1 =
    'https://nurobod.takm.uz/media/k2/items/cache/0a47a31ecf1649c40be3821bbc214aed_L.jpg';

final double customButtonPadding =
    MediaQuery.of(rootNavigatorKey.currentState!.context).padding.bottom + 20;
final double customBarPadding = MediaQuery.of(
  rootNavigatorKey.currentState!.context,
).padding.top;

Widget get customDivider => Divider(
  color: rootNavigatorKey.currentState!.context.isDarkMode ? AppColors.grey808080 : AppColors.grey200,
  thickness: 1,
  height: 0,
);

// // ignore_for_file: use_build_context_synchronously
//
//
// import 'package:axy_driver/core/routes/app_routes.dart';
// import 'package:axy_driver/core/utils/helper_widget.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// class CheckConnection {
//   CheckConnection._();
//
//   static Future<void> scheduleRequest() async {
//     var connectivity = Connectivity();
//
//     connectivity.onConnectivityChanged.listen((connectivityResult) async {
//       if (connectivityResult == ConnectivityResult.wifi ||
//           connectivityResult == ConnectivityResult.mobile ||
//           connectivityResult == ConnectivityResult.ethernet) {
//         // If there is connectivity, close any open no internet screens
//         if (navigatorKey.currentState?.canPop() ?? false) {
//           Navigator.pushNamedAndRemoveUntil(
//             navigatorKey.currentState!.context, AppRoutes.mainScreen, (route) => false);
//         }
//       } else {
//         // Wait for a second and check again
//         await Future.delayed(const Duration(milliseconds: 1000));
//         final doubleCheck = await connectivity.checkConnectivity();
//         if (doubleCheck != ConnectivityResult.wifi &&
//             doubleCheck != ConnectivityResult.mobile &&
//             doubleCheck != ConnectivityResult.ethernet) {
//           // Navigate to the no internet screen
//           Navigator.pushNamed(navigatorKey.currentState!.context, AppRoutes.noInternet);
//         }
//       }
//     });
//   }
// }

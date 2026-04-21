// import 'dart:async';
// import 'dart:io';
//
// import 'package:bonoos/features/common/widget/custom_empty_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
//
// class NoInternetScreen extends StatefulWidget {
//   const NoInternetScreen({super.key, this.fullPath, this.extra});
//
//   static const String routeName = "/no_internet";
//
//
//   final String? fullPath;
//   final Object? extra;
//
//   @override
//   State<NoInternetScreen> createState() => _NoInternetScreenState();
// }
//
// class _NoInternetScreenState extends State<NoInternetScreen> {
//   bool hasInternet = false;
//   late StreamSubscription<InternetConnectionStatus> sub;
//
//   @override
//   void initState() {
//     final checker = InternetConnectionChecker.createInstance();
//     sub = checker.onStatusChange.listen((status) {
//       if (status == InternetConnectionStatus.connected) {
//         setState(() {
//           hasInternet = true;
//           context.goNamed(widget.fullPath!, extra: widget.extra);
//         });
//       } else {
//         setState(() {
//           hasInternet = false;
//         });
//       }
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     sub.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, _) async {
//         final response = await showExitDialog(context);
//         if (response == true) {
//           exit(0);
//         }
//         return;
//       },
//       child: Scaffold(
//         body: Center(
//           child: CustomEmptyWidget(
//             iconBig: true,
//             icon: AppImages.man,
//             title: hasInternet ? context.tr.internetConnected : context.tr.noInternet,
//             onTap: () {},
//             buttonText: context.tr.refresh,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// Future<bool?> showExitDialog(BuildContext context, {bool doubleCheck = false}) {
//   final loc = context.tr;
//
//   return showDialog<bool>(
//     context: context,
//
//     barrierDismissible: false,
//     builder: (ctx) {
//       return AlertDialog(
//         insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text(
//           doubleCheck ? loc.exitDoubleCheckTitle : loc.exitTitle,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: Text(doubleCheck ? loc.exitDoubleCheckMessage : loc.exitMessage),
//         actions: [
//           Row(
//             spacing: 10,
//             children: <Widget>[
//               Expanded(
//                 child: CustomButton(
//                   onTap: () => Navigator.of(ctx).pop(false),
//                   text: loc.exitCancel,
//                   fontSize: 13,
//                   paddingV: 12,
//                   textColor: AppColors.textPrimaryDark,
//                   bgColor: AppColors.primaryOpacity,
//                 ),
//               ),
//
//               Expanded(
//                 child: CustomButton(
//                   onTap: () => Navigator.of(ctx).pop(true),
//                   text: loc.exitConfirm,
//                   fontSize: 13,
//                   paddingV: 12,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

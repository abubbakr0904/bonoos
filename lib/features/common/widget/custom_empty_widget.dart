// import 'package:animate_do/animate_do.dart';
// import 'package:bonoos/core/resources/assets/images/app_images.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'custom_button.dart';
//
// class CustomEmptyWidget extends StatelessWidget {
//   final String title;
//   final String? subTitle;
//   final String? buttonText;
//   final String? icon;
//   final Function()? onTap;
//   final bool? iconBig;
//
//   const CustomEmptyWidget({
//     super.key,
//     required this.title,
//     this.subTitle,
//     this.buttonText,
//     this.onTap,
//     this.icon,
//     this.iconBig = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeIn(
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width / 1.4,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               icon ?? AppImages.icon,
//               width: iconBig != null && iconBig == true ? 50.w : 24.w,
//               fit: BoxFit.cover,
//               colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
//             ),
//             SizedBox(height: 18.h),
//             Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
//             buttonText == null ? SizedBox(height: 4.h) : SizedBox(height: 18.h),
//             if (subTitle != null)
//               Text(subTitle ?? "", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
//             if (subTitle != null) SizedBox(height: 18.h),
//             buttonText == null ? const SizedBox.shrink() : CustomButton(text: buttonText ?? "", onTap: onTap ?? () {}),
//           ],
//         ),
//       ),
//     );
//   }
// }

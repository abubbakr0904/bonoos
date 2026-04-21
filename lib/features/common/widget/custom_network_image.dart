// import 'package:bonoos/core/resources/assets/images/app_images.dart';
// import 'package:bonoos/core/values/app_colors.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shimmer/shimmer.dart';
//
// class CustomCachedNetworkImage extends StatelessWidget {
//   final String imageUrl;
//   final double height;
//   final double width;
//   final BorderRadius? radius;
//   final double iconSize;
//   final String? title;
//   final bool border;
//   final BoxFit? fit;
//   final String? errorIcon;
//   final bool isLoading;
//   final Color? color;
//
//   const CustomCachedNetworkImage({
//     super.key,
//     required this.imageUrl,
//     required this.height,
//     required this.width,
//     this.radius,
//     this.border = false,
//     this.iconSize = 60,
//     this.title,
//     this.fit,
//     this.errorIcon,
//     this.isLoading = false,
//     this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: radius ?? BorderRadius.circular(8),
//       child: CachedNetworkImage(
//         imageUrl: imageUrl,
//         height: height,
//         width: width,
//         fit: fit ?? BoxFit.cover,
//         placeholder: (context, url) => Shimmer.fromColors(
//           period: const Duration(milliseconds: 300),
//           baseColor: color ?? AppColors.grey1,
//           highlightColor: AppColors.secondary,
//           child: CustomErrorWidget(
//             color: color,
//             height: height,
//             width: width,
//             border: border,
//             iconSize: iconSize,
//             title: title,
//             errorIcon: errorIcon,
//           ),
//         ),
//         errorWidget: (context, url, error) => CustomErrorWidget(
//           height: height,
//           width: width,
//           border: border,
//           color: color,
//           iconSize: iconSize,
//           radius: radius,
//           title: title,
//           errorIcon: errorIcon,
//         ),
//       ),
//     );
//   }
// }
//
// class CustomErrorWidget extends StatelessWidget {
//   final double height;
//   final double width;
//   final bool border;
//   final double iconSize;
//   final String? title;
//   final String? errorIcon;
//   final BorderRadius? radius;
//   final Color? color;
//
//   const CustomErrorWidget({
//     super.key,
//     required this.height,
//     required this.width,
//     this.border = false,
//     this.iconSize = 60,
//     this.title,
//     this.errorIcon,
//     this.radius,
//     this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       width: width,
//       decoration: BoxDecoration(
//         borderRadius: radius ?? BorderRadius.circular(8),
//         color: color ?? AppColors.se condary,
//         border: border ? Border.all(color: AppColors.grey1) : null,
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SvgPicture.asset(
//               errorIcon ?? AppImages.icon,
//               height: iconSize,
//               width: iconSize,
//               colorFilter: ColorFilter.mode(AppColors.grey600, BlendMode.srcIn),
//             ),
//             title == null ? const SizedBox.shrink() : const SizedBox.shrink(),
//           ],
//         ),
//       ),
//     );
//   }
// }

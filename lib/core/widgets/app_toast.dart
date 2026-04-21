import 'dart:async';

import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showAppToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);

  late final OverlayEntry entry;
  final controller = StreamController<bool>();

  entry = OverlayEntry(
    builder: (context) {
      return _ToastOverlay(
        message: message,
        visibleStream: controller.stream,
      );
    },
  );

  overlay.insert(entry);
  controller.add(true);

  Future<void>.delayed(duration).then((_) {
    controller.add(false);
    Future<void>.delayed(const Duration(milliseconds: 220)).then((_) {
      entry.remove();
      controller.close();
    });
  });
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.visibleStream,
  });

  final String message;
  final Stream<bool> visibleStream;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> {
  bool _visible = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.visibleStream.listen((v) {
      if (!mounted) return;
      setState(() => _visible = v);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: _visible ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                constraints: BoxConstraints(maxWidth: 0.88.sw),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.c842D5F,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14w6.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


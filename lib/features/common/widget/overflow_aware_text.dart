import 'package:flutter/material.dart';

class OverflowAwareText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;
  final void Function(bool isOverflowing)? onOverflowChanged;

  const OverflowAwareText(this.text, {this.style, this.maxLines = 1, this.onOverflowChanged, super.key, this.textAlign});

  @override
  State<OverflowAwareText> createState() => _OverflowAwareTextState();
}

class _OverflowAwareTextState extends State<OverflowAwareText> {
  bool? _isOverflowing;
  bool isFirstTime = true;

  @override
  void didUpdateWidget(covariant OverflowAwareText oldWidget) {
    if (oldWidget.text.length != widget.text.length) {
      isFirstTime = true;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isFirstTime) {
          isFirstTime = false;
          final span = TextSpan(text: widget.text, style: widget.style);
          final tp = TextPainter(text: span, maxLines: widget.maxLines, textDirection: TextDirection.ltr)
            ..layout(maxWidth: constraints.maxWidth);

          final overflowing = tp.didExceedMaxLines;
          if (_isOverflowing != overflowing) {
            _isOverflowing = overflowing;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onOverflowChanged?.call(overflowing);
            });
          }
        }
        return Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign ?? TextAlign.center,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

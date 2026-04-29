import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyListeningChartCard extends StatelessWidget {
  const WeeklyListeningChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.values,
    required this.labels,
  });

  final String title;
  final String subtitle;
  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20842D5F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body16w7.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            subtitle,
            style: AppTextStyles.body12w4.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 132.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(
                values: values,
                lineColor: Colors.white.withValues(alpha: 0.90),
                glowColor: const Color(0xFF842D5F),
                fillColor: Colors.white.withValues(alpha: 0.08),
                gridColor: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (i) {
              return Text(
                labels[i],
                style: AppTextStyles.body10w6.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.glowColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color glowColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs() < 0.0001 ? 1.0 : (maxVal - minVal);

    const paddingLeft = 6.0;
    const paddingRight = 6.0;
    const paddingTop = 8.0;
    const paddingBottom = 10.0;

    final chartW =
        (size.width - paddingLeft - paddingRight).clamp(1.0, double.infinity);
    final chartH =
        (size.height - paddingTop - paddingBottom).clamp(1.0, double.infinity);

    final dx = values.length == 1 ? 0.0 : chartW / (values.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final t = (v - minVal) / range;
      final x = paddingLeft + dx * i;
      final y = paddingTop + (1 - t) * chartH;
      points.add(Offset(x, y));
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final y = paddingTop + (chartH / 2) * i;
      canvas.drawLine(Offset(paddingLeft, y),
          Offset(size.width - paddingRight, y), gridPaint);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, paddingTop + chartH)
      ..lineTo(points.first.dx, paddingTop + chartH)
      ..close();
    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(fillPath, fillPaint);

    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    for (final p in points) {
      canvas.drawCircle(p, 2.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}

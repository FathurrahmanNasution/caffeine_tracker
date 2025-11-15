import 'package:flutter/material.dart';
import 'dart:math';

enum ChartType { weekly, monthly, yearly }

double _getMaxCaffeineForType(ChartType type) {
  switch (type) {
    case ChartType.weekly:
      return 600;
    case ChartType.monthly:
      return 3500;
    case ChartType.yearly:
      return 10000;
  }
}

class CaffeineChart extends StatelessWidget {
  final Map<dynamic, double> data;
  final ChartType type;
  final List<String> labels;
  final Function(dynamic key) onTap;
  final bool Function(dynamic key)? shouldShowPoint;

  const CaffeineChart({
    super.key,
    required this.data,
    required this.type,
    required this.labels,
    required this.onTap,
    this.shouldShowPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 45, right: 15, top: 10, bottom: 10),
      child: SizedBox(
        height: 200,
        child: GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = details.localPosition;

            const double labelOffset = 25.0;
            final sortedKeys = data.keys.toList()..sort();

            // Hitung maxCaffeine untuk normalisasi Y
            double maxCaffeine = _getMaxCaffeineForType(type);
            final maxFromData = data.values.fold(0.0, (max, val) => val > max ? val : max);
            if (maxFromData > maxCaffeine) {
              maxCaffeine = ((maxFromData / 50).ceil() * 50).toDouble();
            }

            double minDistance = double.infinity;
            dynamic closestKey;

            final totalPoints = labels.length;

            for (int i = 0; i < sortedKeys.length; i++) {
              final key = sortedKeys[i];

              if (shouldShowPoint != null && !shouldShowPoint!(key)) {
                continue;
              }

              int keyIndex = type == ChartType.yearly ? (key as int) - 1 : i;

              double pointX = (keyIndex * (box.size.width - labelOffset * 2) / (totalPoints - 1)) + labelOffset;

              double caffeine = data[key] ?? 0;
              double normalizedValue = maxCaffeine > 0 ? caffeine / maxCaffeine : 0;
              double pointY = box.size.height - (normalizedValue * box.size.height);

              double distanceX = localPosition.dx - pointX;
              double distanceY = localPosition.dy - pointY;
              double distance = sqrt(pow(distanceX, 2) + pow(distanceY, 2));

              if (distance < minDistance && distance < 30) {
                minDistance = distance;
                closestKey = key;
              }
            }

            if (closestKey != null) {
              onTap(closestKey);
            }
          },
          child: CustomPaint(
            painter: CaffeineChartPainter(
              data: data,
              labels: labels,
              type: type,
              shouldShowPoint: shouldShowPoint,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class CaffeineChartPainter extends CustomPainter {
  final Map<dynamic, double> data;
  final List<String> labels;
  final ChartType type;
  final bool Function(dynamic key)? shouldShowPoint;

  CaffeineChartPainter({
    required this.data,
    required this.labels,
    required this.type,
    this.shouldShowPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[300]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.brown[300]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.7;

    final pointPaint = Paint()
      ..color = Colors.brown[800]!
      ..style = PaintingStyle.fill;

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      double y = size.height - (i * size.height / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const double labelOffset = 25.0;

    double maxCaffeine = _getMaxCaffeineForType(type);
    final maxFromData = data.values.fold(0.0, (max, val) => val > max ? val : max);
    if (maxFromData > maxCaffeine) {
      maxCaffeine = ((maxFromData / 50).ceil() * 50).toDouble();
    }

    final path = Path();
    final List<Offset> points = [];

    final sortedKeys = data.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      double caffeine = data[sortedKeys[i]] ?? 0;
      double normalizedValue = maxCaffeine > 0 ? caffeine / maxCaffeine : 0;
      double y = size.height - (normalizedValue * size.height);
      double x = (i * (size.width - labelOffset * 2) / (sortedKeys.length - 1)) + labelOffset;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      for (int i = 0; i < points.length; i++) {
        final dayKey = sortedKeys[i];
        bool canShow = shouldShowPoint == null || shouldShowPoint!(dayKey);

        if (canShow) {
          canvas.drawCircle(points[i], 5, pointPaint);
        }
      }
    }

    // Draw Y-axis labels
    final yLabels = _getYAxisLabels(maxCaffeine);
    for (int i = 0; i < yLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(-40, size.height - (i * size.height / (yLabels.length - 1)) - 6),
      );
    }

    // Draw X-axis labels
    for (int i = 0; i < labels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      final labelWidth = labelPainter.width;
      final pointX = (i * (size.width - labelOffset * 2) / (labels.length - 1)) + labelOffset;

      labelPainter.paint(
        canvas,
        Offset(pointX - (labelWidth / 2), size.height + 10),
      );
    }
  }

  List<String> _getYAxisLabels(double maxCaffeine) {
    final step = (maxCaffeine / 5).ceil();
    return List.generate(6, (i) => (i * step).toString());
  }

  @override
  bool shouldRepaint(CaffeineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.labels != labels ||
        oldDelegate.type != type ||
        oldDelegate.shouldShowPoint != shouldShowPoint;
  }
}
import 'package:flutter/material.dart';

enum ChartType { weekly, monthly, yearly }

class CaffeineChart extends StatelessWidget {
  final Map<dynamic, double> data;
  final ChartType type;
  final List<String> labels;
  final Function(dynamic key) onTap;

  const CaffeineChart({
    super.key,
    required this.data,
    required this.type,
    required this.labels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 6),
      child: SizedBox(
        height: 200,
        child: GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = details.localPosition;

            const double labelOffset = 25.0;
            final double spacingDivisor = labels.length.toDouble();
            const double chartPadding = 30.0;

            final chartWidth = box.size.width - chartPadding - 6;

            for (int i = 0; i < labels.length; i++) {
              double pointX = (i * chartWidth / spacingDivisor) + labelOffset + chartPadding;

              if ((localPosition.dx - pointX).abs() < 20) {
                // For weekly: pass day index (0-6)
                // For monthly: pass month index (0-11)
                // For yearly: pass year string
                final key = data.keys.toList()[i];
                onTap(key);
                break;
              }
            }
          },
          child: CustomPaint(
            painter: CaffeineChartPainter(
              data: data,
              labels: labels,
              type: type,
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

  CaffeineChartPainter({
    required this.data,
    required this.labels,
    required this.type,
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
    final double spacingDivisor = labels.length.toDouble();

    // Find max value untuk scaling
    double maxCaffeine = _getMaxCaffeineForType();
    final maxFromData = data.values.fold(0.0, (max, val) => val > max ? val : max);
    if (maxFromData > maxCaffeine) {
      maxCaffeine = ((maxFromData / 50).ceil() * 50).toDouble();
    }

    // Generate points from data
    final path = Path();
    final List<Offset> points = [];

    final sortedKeys = data.keys.toList();
    for (int i = 0; i < sortedKeys.length; i++) {
      double caffeine = data[sortedKeys[i]] ?? 0;
      double normalizedValue = maxCaffeine > 0 ? caffeine / maxCaffeine : 0;
      double y = size.height - (normalizedValue * size.height);
      double x = (i * size.width / spacingDivisor) + labelOffset;
      points.add(Offset(x, y));
    }

    // Draw path
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      // Fill area
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // Draw points (circles) on each data point
      for (var point in points) {
        canvas.drawCircle(point, 5, pointPaint);
      }
    }

    // Draw Y-axis labels
    final yLabels = _getYAxisLabels(maxCaffeine);
    for (int i = 0; i < yLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(-30, size.height - (i * size.height / (yLabels.length - 1)) - 5),
      );
    }

    // Draw X-axis labels
    for (int i = 0; i < labels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      // Center the label under each point
      final labelWidth = labelPainter.width;
      final pointX = (i * size.width / spacingDivisor) + labelOffset;

      labelPainter.paint(
        canvas,
        Offset(pointX - (labelWidth / 2), size.height + 10),
      );
    }
  }

  double _getMaxCaffeineForType() {
    switch (type) {
      case ChartType.weekly:
        return 250;
      case ChartType.monthly:
        return 500;
      case ChartType.yearly:
        return 1000;
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
        oldDelegate.type != type;
  }
}
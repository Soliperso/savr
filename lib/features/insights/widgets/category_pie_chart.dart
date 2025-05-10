import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategoryPieChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return Center(
        child: Text(
          'No category data available',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    final total = categoryData.values.reduce((a, b) => a + b);
    final sortedCategories =
        categoryData.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        // Pie Chart
        SizedBox(
          width: 150.w,
          height: 150.w,
          child: CustomPaint(
            painter: PieChartPainter(
              categories: sortedCategories,
              total: total,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Legend
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                sortedCategories.map((entry) {
                  final percentage = (entry.value / total * 100)
                      .toStringAsFixed(1);
                  final color = getCategoryColor(
                    sortedCategories.indexOf(entry),
                    sortedCategories.length,
                  );

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Color getCategoryColor(int index, int total) {
    final baseColors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFC107), // Amber
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];

    if (index < baseColors.length) {
      return baseColors[index];
    }

    // Generate a color based on the index for categories beyond the base colors
    final hue = (index * 137.5) % 360;
    return HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor();
  }
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> categories;
  final double total;

  PieChartPainter({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2; // Start from top (12 o'clock position)

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final sweepAngle = 2 * math.pi * (category.value / total);
      final color = getCategoryColor(i, categories.length);

      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color getCategoryColor(int index, int total) {
    final baseColors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFC107), // Amber
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];

    if (index < baseColors.length) {
      return baseColors[index];
    }

    final hue = (index * 137.5) % 360;
    return HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor();
  }
}

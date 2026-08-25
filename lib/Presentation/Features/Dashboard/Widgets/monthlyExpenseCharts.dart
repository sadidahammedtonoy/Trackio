import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/numberTranslation.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  static const List<Color> _palette = [
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF03A9F4),
    Color(0xFF8BC34A),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
    Color(0xFF795548),
    Color(0xFFCDDC39),
    Color(0xFF673AB7),
    Color(0xFF00BCD4),
    Colors.redAccent,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.blue,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final tablet = _isTablet(context);

    return Obx(() {
      final data = controller.categorySummary;

      if (data.isEmpty) {
        return Center(
          child: Text(
            "No Transactions for analysis".tr,
          ),
        );
      }

      final sortedEntries = data.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final total = sortedEntries.fold<double>(0.0, (sum, e) => sum + e.value);

      final sections = List.generate(sortedEntries.length, (i) {
        final entry = sortedEntries[i];
        final value = entry.value;
        final percent = total == 0 ? 0 : (value / total) * 100;

        return PieChartSectionData(
          value: value,
          color: _palette[i % _palette.length],
          radius: tablet ? 80 : 70,
          title: percent >= 8 ? "${percent.toStringAsFixed(0)}%" : "",
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: tablet ? 14 : 12,
          ),
        );
      });

      return Padding(
        padding: EdgeInsets.all(tablet ? 16.0 : 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: tablet ? 200 : 180,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: tablet ? 40 : 35,
                  ),
                ),
              ),
            ),
            SizedBox(height: tablet ? 30.0 : 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: tablet ? 4 : 3,
                crossAxisSpacing: tablet ? 12.0 : 10.w,
                mainAxisSpacing: tablet ? 12.0 : 10.h,
                mainAxisExtent: tablet ? 90.0 : null,
                childAspectRatio: tablet ? 1.0 : 1.4,
              ),
              itemCount: sortedEntries.length,
              itemBuilder: (context, i) {
                final entry = sortedEntries[i];
                final color = _palette[i % _palette.length];
                final percent = total == 0 ? 0 : (entry.value / total) * 100;

                return _GlassCard(
                  tablet: tablet,
                  padding: EdgeInsets.symmetric(
                    horizontal: tablet ? 8.0 : 10.w,
                    vertical: tablet ? 8.0 : 8.h,
                  ),
                  borderColor: color.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: tablet ? 13.0 : 13.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        "৳${numberTranslation.toBnDigits(entry.value.toStringAsFixed(0))}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: tablet ? 12.0 : 12.sp,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: tablet ? 11.0 : 11.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final bool tablet;

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderColor,
    this.tablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
        border: Border.all(color: borderColor ?? Colors.grey.withAlpha(77)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? EdgeInsets.all(tablet ? 12.0 : 16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

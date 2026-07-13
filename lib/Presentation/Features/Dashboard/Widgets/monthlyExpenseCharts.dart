import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/numberTranslation.dart';
import '../Controller/Controller.dart';

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
          radius: 70,
          title: percent >= 8 ? "${percent.toStringAsFixed(0)}%" : "",
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        );
      });

      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1.4,
              ),
              itemCount: sortedEntries.length,
              itemBuilder: (context, i) {
                final entry = sortedEntries[i];
                final color = _palette[i % _palette.length];
                final percent = total == 0 ? 0 : (entry.value / total) * 100;

                return _GlassCard(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  borderColor: color.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key.tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        "৳${numberTranslation.toBnDigits(entry.value.toStringAsFixed(0))}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                      Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: TextStyle(color: Colors.black54, fontSize: 11.sp),
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

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20.r),
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
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

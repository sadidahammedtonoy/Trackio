import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/numberTranslation.dart';
import '../Controller/Controller.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  // 🎨 20+ colors (ordered: first blue, second orange)
  static const List<Color> _palette = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
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
    Color(0xFFE91E63),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<dashboardController>();

    return Obx(() {
      // ✅ Always use cached data (instant, no flicker)
      final data = controller.cachedCategoryMap;

      if (data.isEmpty) {
        return Center(
          child: Text(
            "No Transactions for analysis".tr,
          ),
        );
      }

      // Stable order for colors + legend
      final entries = data.entries.toList();

      final total = entries.fold<double>(0.0, (sum, e) => sum + e.value);

      final sections = List.generate(entries.length, (i) {
        final entry = entries[i];
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
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: List.generate(entries.length, (i) {
                final entry = entries[i];
                final color = _palette[i % _palette.length];

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${entry.key.tr}: ${numberTranslation.toBnDigits(entry.value.toStringAsFixed(0))}৳",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

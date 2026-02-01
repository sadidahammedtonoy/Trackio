import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Transcations/Controller/Controller.dart';
import '../Controller/Controller.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  Color _colorForCategory(String name) {
    // Stable color per category (same name => same color)
    final colors = <Color>[
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
    ];
    final hash = name.codeUnits.fold<int>(0, (p, c) => p + c);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<dashboardController>();

    return StreamBuilder<Map<String, double>>(
      stream: controller.streamCategorySummary(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (data.isEmpty) {
          return const Center(child: Text("No data for pie chart"));
        }

        final total = data.values.fold<double>(0.0, (a, b) => a + b);

        final sections = data.entries.map((e) {
          final value = e.value;
          final percent = total == 0 ? 0 : (value / total) * 100;

          return PieChartSectionData(
            value: value,
            color: _colorForCategory(e.key),
            radius: 70,
            title: percent >= 8 ? "${percent.toStringAsFixed(0)}%" : "", // hide tiny labels
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          );
        }).toList();

        return Container(
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

              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: data.entries.map((e) {
                  final color = _colorForCategory(e.key);
                  final value = e.value;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${e.key}: ${value.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

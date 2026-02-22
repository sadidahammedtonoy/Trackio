// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../Controller/Controller.dart';
//
// class WeeklyBarChartView extends StatelessWidget {
//   WeeklyBarChartView({super.key});
//
//   final  controller = Get.find<dashboardController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.6,
//       child: BarChart(
//         BarChartData(
//           barGroups: controller.barGroups,
//           gridData: const FlGridData(show: false),
//           borderData: FlBorderData(show: false),
//           titlesData: FlTitlesData(
//             leftTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   final now = DateTime.now();
//                   final date = DateTime(
//                     now.year,
//                     now.month,
//                     now.day,
//                   ).subtract(Duration(days: 6 - value.toInt()));
//
//                   return SideTitleWidget(
//                     axisSide: meta.axisSide, // must pass the axisSide from meta
//                     child: Text(
//                       "${date.day}/${date.month}",
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
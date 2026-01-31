import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Features/Dashboard/View/dashboard.dart';
import '../../Features/Saving/View/saving.dart';
import '../../Features/Setting/View/setting.dart';
import '../../Features/Transcations/View/transactions.dart';
import '../Controller/Controller.dart';

class navbar extends StatelessWidget {
  navbar({super.key});

  final navbar_controller nav = Get.find<navbar_controller>();

  // Replace with your real pages
  final pages = [
    dashboardPage(),
    transcations_page(),
    savingPage(),
    setting_page()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: SafeArea(
          child: pages[nav.currentIndex.value],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: nav.currentIndex.value,
          onTap: nav.changeTab,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Transactions",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: "Savings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      );
    });
  }
}



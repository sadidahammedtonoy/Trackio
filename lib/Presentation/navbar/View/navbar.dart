import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Features/Dashboard/View/dashboard.dart';
import '../../Features/Setting/View/setting.dart';
import '../../Features/Transcations/View/transactions.dart';
import '../../Features/debts/View/debts.dart';
import '../Controller/Controller.dart';

class navbar extends StatelessWidget {
  navbar({super.key});

  final navbar_controller nav = Get.find<navbar_controller>();

  // Replace with your real pages
  final pages = [
    dashboardPage(),
    transcations_page(),
    deptsPage(),
    setting_page()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: SafeArea(
          child: pages[nav.currentIndex.value],
        ),

        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            top: 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.cyan,
            border: Border.all(
              color: Colors.cyan,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(5, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              currentIndex: nav.currentIndex.value,
              onTap: nav.changeTab,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.cyan,

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
                  icon: Icon(Icons.balance_outlined),
                  activeIcon: Icon(Icons.balance_rounded),
                  label: "Debts",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}



import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Presentation/Share/Background.dart';
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
    return background(
      child: Scaffold(
          body: SafeArea(
            child: Obx(() => AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
      
              },
              child: pages[nav.currentIndex.value],
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
            )),
          ),
      
          // bottomNavigationBar: Container(
          //   padding: EdgeInsets.only(
          //     top: 1,
          //   ),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(30),
          //     color: Colors.cyan,
          //     border: Border.all(
          //       color: Colors.cyan,
          //       width: 1,
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.cyan.withOpacity(0.2),
          //         blurRadius: 8,
          //         offset: const Offset(5, 4),
          //       ),
          //     ],
          //   ),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(30),
          //       topRight: Radius.circular(30),
          //     ),
          //     child: BottomNavigationBar(
          //       currentIndex: nav.currentIndex.value,
          //       onTap: nav.changeTab,
          //       type: BottomNavigationBarType.fixed,
          //       showUnselectedLabels: true,
          //       backgroundColor: Colors.white,
          //       selectedItemColor: Colors.cyan,
          //
          //       items: [
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.dashboard_outlined),
          //           activeIcon: Icon(Icons.dashboard),
          //           label: "Dashboard".tr,
          //         ),
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.receipt_long_outlined),
          //           activeIcon: Icon(Icons.receipt_long),
          //           label: "Transactions".tr,
          //         ),
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.balance_outlined),
          //           activeIcon: Icon(Icons.balance_rounded),
          //           label: "Debts".tr,
          //         ),
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.settings_outlined),
          //           activeIcon: Icon(Icons.settings),
          //           label: "Settings".tr,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
      
          bottomNavigationBar: AnimatedNotchBottomBar(
            notchBottomBarController: nav.notchController,
            color: Color(0xFFFFFFFD),
            // color: Color(0xFFEEEEEE),
            showLabel: true,
            notchColor: Colors.cyan,
            bottomBarItems: [
              BottomBarItem(
                inActiveItem: const Icon(Icons.dashboard_outlined,
                    color: Colors.grey),
                activeItem:
                const Icon(Icons.dashboard, color: Colors.white),
                itemLabel: "Dashboard".tr,
              ),
              BottomBarItem(
                inActiveItem: const Icon(Icons.receipt_long_outlined,
                    color: Colors.grey),
                activeItem:
                const Icon(Icons.receipt_long, color: Colors.white),
                itemLabel: "Transactions".tr,
              ),
              BottomBarItem(
                inActiveItem:
                const Icon(Icons.balance_outlined, color: Colors.grey),
                activeItem:
                const Icon(Icons.balance_rounded, color: Colors.white),
                itemLabel: "Debts".tr,
              ),
              BottomBarItem(
                inActiveItem:
                const Icon(Icons.settings_outlined, color: Colors.grey),
                activeItem:
                const Icon(Icons.settings, color: Colors.white),
                itemLabel: "Settings".tr,
              ),
            ],
            onTap: (index) {
              nav.currentIndex.value = index;
            },
            kIconSize: 24.0,
            kBottomRadius: 30.0,
          )
      ),
    );
  }
}



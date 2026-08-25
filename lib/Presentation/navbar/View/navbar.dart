import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../../Features/Dashboard/View/dashboard.dart';
import '../../Features/Setting/View/setting.dart';
import '../../Features/Transcations/View/transactions.dart';
import '../../Features/debts/View/debts.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class Navbar extends StatelessWidget {
  Navbar({super.key});

  final navbar_controller nav = Get.put(navbar_controller());

  final pages = [
    DashboardPage(),
    transcations_page(),
    deptsPage(),
    setting_page(),
  ];

  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(nav.currentIndex.value),
                child: pages[nav.currentIndex.value],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => _CustomBottomNavBar(
            selectedIndex: nav.currentIndex.value,
            onTap: (index) {
              nav.currentIndex.value = index;
            },
          ),
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    if (tablet) {
      // ── iPad: compact centered pill ────────────────────────────────
      return Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: 420, // fixed width — pill floats centered
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: HugeIcons.strokeRoundedDashboardCircle,
                    label: 'Home'.tr,
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                    isTablet: true,
                  ),
                  _NavBarItem(
                    icon: HugeIcons.strokeRoundedTransaction,
                    label: 'History'.tr,
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                    isTablet: true,
                  ),
                  _NavBarItem(
                    icon: HugeIcons.strokeRoundedCreditCardPos,
                    label: 'Debts'.tr,
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                    isTablet: true,
                  ),
                  _NavBarItem(
                    icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
                    label: 'More'.tr,
                    isSelected: selectedIndex == 3,
                    onTap: () => onTap(3),
                    isTablet: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Phone: original layout (untouched) ───────────────────────────
    return Container(
      height: 115.h,
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 35.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(44.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: HugeIcons.strokeRoundedDashboardCircle,
                  label: 'Home'.tr,
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavBarItem(
                  icon: HugeIcons.strokeRoundedTransaction,
                  label: 'History'.tr,
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavBarItem(
                  icon: HugeIcons.strokeRoundedCreditCardPos,
                  label: 'Debts'.tr,
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavBarItem(
                  icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
                  label: 'More'.tr,
                  isSelected: selectedIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);

    final double iconSize = tablet ? 18.0 : 20.sp;
    final double fontSize = tablet ? 10.0 : 10.sp;
    final double margin   = tablet ? 4.0  : 5.r;
    final double radius   = tablet ? 30.0 : 38.r;
    final double gap      = tablet ? 2.0  : 2.h;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A1C) : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: icon,
                size: iconSize,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              SizedBox(height: gap),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

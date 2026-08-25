import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/numberTranslation.dart';
import '../../AddTransactions/Controller/Controller.dart';
import '../../Transcations/Model/tranModel.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class deptsPage extends StatelessWidget {
  deptsPage({super.key});
  final controller = Get.find<debtsController>();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    final List<Widget> tabViews = [
      _buildTransactionsList(tablet),
      _buildPersonList(tablet),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Debts".tr,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: tablet ? 16.0 : 20.sp,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
                icon: controller.isSearchVisible.value
                    ? const Icon(Icons.close, color: Colors.black)
                    : HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch02,
                        color: Colors.black,
                        size: tablet ? 20.0 : 24.sp,
                      ),
                onPressed: () {
                  controller.toggleSearch();
                },
              )),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: tablet ? 20.0 : 16.w),
        child: Column(
          children: [
            _GlassCard(
              padding: EdgeInsets.all(tablet ? 4.0 : 4.r),
              borderRadius: BorderRadius.circular(tablet ? 16.0 : 16.r),
              child: Obx(() {
                return Row(
                  children: [
                    _tabButton(
                      label: "Transactions".tr,
                      index: 0,
                      selectedIndex: controller.tabIndex.value,
                      onTap: () => controller.changeTab(0),
                      isTablet: tablet,
                    ),
                    _tabButton(
                      label: "Person".tr,
                      index: 1,
                      selectedIndex: controller.tabIndex.value,
                      onTap: () => controller.changeTab(1),
                      isTablet: tablet,
                    ),
                  ],
                );
              }),
            ),
            _buildSearchBar(tablet),
            Expanded(
              child: Obx(() => IndexedStack(
                index: controller.tabIndex.value,
                children: tabViews,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool tablet) {
    return Obx(() => controller.isSearchVisible.value
        ? Padding(
            padding: EdgeInsets.only(
              top: tablet ? 10.0 : 15.h,
              bottom: tablet ? 4.0 : 5.h,
            ),
            child: TextFormField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search Name or Remark...".tr,
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: tablet ? 13.0 : 13.sp,
                ),
                prefixIcon: Icon(Icons.search, size: tablet ? 18.0 : 20.sp, color: Colors.black45),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: tablet ? 8.0 : 12.h,
                  horizontal: tablet ? 16.0 : 16.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (val) => controller.setSearchQuery(val),
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildSummaryCards(bool tablet) {
    return StreamBuilder<Map<String, double>>(
      stream: controller.streamTotalLentBorrow(),
      builder: (context, snapshot) {
        final data =
            snapshot.data ?? {"lent": 0.0, "borrow": 0.0, "net": 0.0};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: tablet ? 8.0 : 10.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final addTran =
                          Get.find<addTranscationsController>();
                      addTran.selectedType.value = "Lent";
                      Get.toNamed(routes.addTranscations_screen);
                    },
                    child: _GlassCard(
                      borderColor: Colors.orange.withOpacity(0.5),
                      padding: EdgeInsets.all(tablet ? 12.0 : 16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Lent".tr,
                                style: TextStyle(
                                  fontSize: tablet ? 14.0 : 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange,
                                ),
                              ),
                              Tooltip(
                                message:
                                    "Lent means giving money to another person with the expectation that it will be returned in the future."
                                        .tr,
                                triggerMode: TooltipTriggerMode.tap,
                                child: Icon(
                                  Icons.info_outline,
                                  size: tablet ? 14.0 : 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: tablet ? 6.0 : 8.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "৳${numberTranslation.toBnDigits(data["lent"]!.toStringAsFixed(1))}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: tablet ? 18.0 : 22.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: tablet ? 3.0 : 4.h),
                          Text(
                            "You Will Receive.".tr,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: tablet ? 11.0 : 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: tablet ? 10.0 : 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final addTran =
                          Get.find<addTranscationsController>();
                      addTran.selectedType.value = "Borrow";
                      Get.toNamed(routes.addTranscations_screen);
                    },
                    child: _GlassCard(
                      borderColor: Colors.purple.withOpacity(0.5),
                      padding: EdgeInsets.all(tablet ? 12.0 : 16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Borrow".tr,
                                style: TextStyle(
                                  fontSize: tablet ? 14.0 : 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple,
                                ),
                              ),
                              Tooltip(
                                message:
                                    "Borrow means money you received and must repay later."
                                        .tr,
                                triggerMode: TooltipTriggerMode.tap,
                                child: Icon(
                                  Icons.info_outline,
                                  size: tablet ? 14.0 : 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: tablet ? 6.0 : 8.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "৳${numberTranslation.toBnDigits(data["borrow"]!.toStringAsFixed(1))}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                                fontSize: tablet ? 18.0 : 22.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: tablet ? 3.0 : 4.h),
                          Text(
                            "You Need to Pay.".tr,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: tablet ? 11.0 : 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tablet ? 14.0 : 20.h),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsList(bool tablet) {
    return StreamBuilder<List<TranItem>>(
      stream: controller.streamLentBorrowTransactions(),
      initialData: controller.cachedLentBorrow,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final live = snapshot.data ?? const <TranItem>[];
        final cached = controller.cachedLentBorrow;
        final rawItems = live.isNotEmpty ? live : cached;

        return Obx(() {
          final query = controller.searchQuery.value.toLowerCase();
          final items = query.isEmpty
              ? rawItems
              : rawItems.where((item) {
                  return item.category.toLowerCase().contains(query) ||
                         item.note.toLowerCase().contains(query);
                }).toList();

          if (items.isEmpty) {
            return Column(
              children: [
                _buildSummaryCards(tablet),
                 Expanded(
                   child: Center(
                    child: Text(query.isEmpty
                        ? "No lent or borrow transactions".tr
                        : "No matching results found".tr),
                                 ),
                 ),
              ],
            );
          }

          // --- Build grouped sections ---
          // Group items by month
          final Map<String, List<TranItem>> monthMap = {};
          final List<String> monthOrder = [];
          for (var item in items) {
            final month = DateFormat('MMMM yyyy').format(item.date);
            if (!monthMap.containsKey(month)) {
              monthMap[month] = [];
              monthOrder.add(month);
            }
            monthMap[month]!.add(item);
          }

          // Build flat list: [summaryCards, then per-month: [header, ...rows]]
          // Each "row" on tablet = up to 2 items; on phone = 1 item
          final List<Widget> rows = [];
          rows.add(_buildSummaryCards(tablet));

          for (int mi = 0; mi < monthOrder.length; mi++) {
            final month = monthOrder[mi];
            final monthItems = monthMap[month]!;

            // Month header
            rows.add(Padding(
              padding: EdgeInsets.only(
                bottom: tablet ? 6.0 : 8.h,
                left: tablet ? 4.0 : 4.w,
                top: mi == 0 ? 0 : (tablet ? 16.0 : 20.h),
              ),
              child: Text(
                month,
                style: TextStyle(
                  fontSize: tablet ? 14.0 : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ));

            if (tablet) {
              // 2-column grid rows
              for (int i = 0; i < monthItems.length; i += 2) {
                final left = monthItems[i];
                final right = (i + 1) < monthItems.length ? monthItems[i + 1] : null;
                rows.add(Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TransactionTile(
                          item: left,
                          isTablet: true,
                          onDelete: () async {
                            await controller.deleteMonthlyTransaction(
                              monthKey: left.monthKey,
                              transactionId: left.id,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: right != null
                            ? _TransactionTile(
                                item: right,
                                isTablet: true,
                                onDelete: () async {
                                  await controller.deleteMonthlyTransaction(
                                    monthKey: right.monthKey,
                                    transactionId: right.id,
                                  );
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ));
              }
            } else {
              // Single column
              for (final item in monthItems) {
                rows.add(Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _TransactionTile(
                    item: item,
                    isTablet: false,
                    onDelete: () async {
                      await controller.deleteMonthlyTransaction(
                        monthKey: item.monthKey,
                        transactionId: item.id,
                      );
                    },
                  ),
                ));
              }
            }
          }

          return ListView(
            padding: EdgeInsets.only(
              bottom: tablet ? 80.0 : 115.h,
              top: tablet ? 10.0 : 15.h,
            ),
            children: rows,
          );
        });
      },
    );
  }

  Widget _buildPersonList(bool tablet) {
    return StreamBuilder<List<MonthPersonDebt>>(
      stream: controller.streamDebtsByPersonByMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final rawMonthlyDebts = snapshot.data ?? [];

        return Obx(() {
          final query = controller.searchQuery.value.toLowerCase();
          final monthlyDebts = query.isEmpty
              ? rawMonthlyDebts
              : rawMonthlyDebts.map((monthDebt) {
                  final filteredDebts = monthDebt.debts.where((debt) {
                    return debt.name.toLowerCase().contains(query);
                  }).toList();
                  return MonthPersonDebt(month: monthDebt.month, debts: filteredDebts);
                }).where((monthDebt) => monthDebt.debts.isNotEmpty).toList();


          if (monthlyDebts.isEmpty) {
            return Center(
              child: Text(
                query.isEmpty ? "No debts to show".tr : "No matching results found".tr,
                style: TextStyle(
                  fontSize: tablet ? 14.0 : 16.sp,
                  color: Colors.black54,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(
              bottom: tablet ? 80.0 : 115.h,
              top: tablet ? 10.0 : 15.h,
            ),
            itemCount: monthlyDebts.length,
            itemBuilder: (context, index) {
              final monthDebt = monthlyDebts[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: tablet ? 10.0 : 12.h,
                      left: tablet ? 4.0 : 4.w,
                      top: index == 0 ? 0 : (tablet ? 16.0 : 20.h),
                    ),
                    child: Text(
                      monthDebt.month,
                      style: TextStyle(
                        fontSize: tablet ? 14.0 : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: tablet ? 3 : 2,
                      crossAxisSpacing: tablet ? 10.0 : 12.w,
                      mainAxisSpacing: tablet ? 10.0 : 12.h,
                      mainAxisExtent: tablet ? 90.0 : 110.0,
                    ),
                    itemCount: monthDebt.debts.length,
                    itemBuilder: (context, gridIndex) {
                      final debt = monthDebt.debts[gridIndex];
                      return _PersonDebtTile(debt: debt, isTablet: tablet);
                    },
                  )
                ],
              );
            },
          );
        });
      },
    );
  }
}

Widget _tabButton({
  required String label,
  required int index,
  required int selectedIndex,
  required VoidCallback onTap,
  bool isTablet = false,
}) {
  final isSelected = selectedIndex == index;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: isTablet ? 8.0 : 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(isTablet ? 10.0 : 12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 13.0 : 14.sp,
          ),
        ),
      ),
    ),
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        border: Border.all(color: borderColor ?? Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.item,
    required this.onDelete,
    this.isTablet = false,
  });

  final TranItem item;
  final Future<void> Function() onDelete;
  final bool isTablet;

  Color _typeColor(String type) {
    if (type == "Expense") return Colors.red;
    if (type == "Income") return Colors.green;
    if (type == "Saving") return Colors.blue;
    if (type == "Lent") return Colors.orange;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(item.type);

    final double avatarSize = isTablet ? 36.0 : 50.r;
    final double avatarFont = isTablet ? 14.0 : 18.sp;
    final double hGap = isTablet ? 10.0 : 15.w;
    final double catFont = isTablet ? 13.0 : 15.sp;
    final double walletFont = isTablet ? 11.0 : 12.sp;
    final double amtFont = isTablet ? 13.0 : 15.sp;
    final double dateFont = isTablet ? 9.0 : 10.sp;
    final double cardPad = isTablet ? 10.0 : 12.r;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildActionBg(HugeIcons.strokeRoundedEdit02, "Edit".tr, Colors.blue, Alignment.centerLeft),
      secondaryBackground: _buildActionBg(HugeIcons.strokeRoundedDelete04, "Delete".tr, Colors.red, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          Get.find<editTransactionsController>().assignValues(item);
          Get.to(editTransactions(model: item));
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          final confirm = await _showDeleteDialog(context);
          if (!confirm) return false;
          await onDelete();
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () => _showDetailsDialog(context),
        child: _GlassCard(
          padding: EdgeInsets.all(cardPad),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: avatarFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: hGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.category.isEmpty ? "No Name".tr : item.category.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: catFont,
                            color: Colors.black87,
                          ),
                        ),
                        if (item.marked)
                          Padding(
                            padding: EdgeInsets.only(left: isTablet ? 5.0 : 6.w),
                            child: Icon(Icons.check_circle,
                                color: Colors.green, size: isTablet ? 13.0 : 14.sp),
                          ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      item.wallet.tr,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: walletFont,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: amtFont,
                      color: typeColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    isTablet
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(item.date)
                        : numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date)) +
                          ", " +
                          numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date)),
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: dateFont,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(width: isTablet ? 8.0 : 4.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBg(dynamic icon, String text, Color color, Alignment alignment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.0 : 20.w),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 14.0 : 14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                HugeIcon(icon: icon, color: color, size: isTablet ? 18.0 : 22.sp),
                SizedBox(width: isTablet ? 6.0 : 8.w),
                Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTablet ? 12.0 : null)),
              ]
            : [
                Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTablet ? 12.0 : null)),
                SizedBox(width: isTablet ? 6.0 : 8.w),
                HugeIcon(icon: icon, color: color, size: isTablet ? 18.0 : 22.sp),
              ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text("Delete Transaction".tr),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Are you sure you want to delete this transaction?".tr),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text("Cancel".tr),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx, true),
                child: Text("Delete".tr),
              ),
            ],
          );
        },
      ) ?? false;
    } else {
      final result = await Get.dialog<bool>(
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Delete Transaction".tr),
            content: Text("Are you sure you want to delete this transaction?".tr),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54))),
              TextButton(onPressed: () => Get.back(result: true), child: Text("Delete".tr, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ) ?? false;
      return result;
    }
  }

  void _showDetailsDialog(BuildContext context) {
    final dateText = numberTranslation.formatDateBnFromString(
      DateFormat('dd MMM yyyy').format(item.date),
    );
    final timeText = numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date));
    final typeColor = _typeColor(item.type);
    final tablet = _isTablet(context);

    final isLent = item.type == 'Lent';
    final isBorrow = item.type == 'Borrow';
    final gradientColors = isBorrow
        ? [const Color(0xFF9B59B6), const Color(0xFF8E44AD)]
        : isLent
            ? [const Color(0xFFFF9F43), const Color(0xFFEE5A24)]
            : [const Color(0xFF2ECC71), const Color(0xFF27AE60)];
    final typeIcon = isBorrow
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: tablet ? 160 : 20,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tablet ? 28.0 : 22.0,
                    vertical: tablet ? 24.0 : 20.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(typeIcon, color: Colors.white, size: tablet ? 18 : 16),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${item.type.tr} ${'Transaction'.tr}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: tablet ? 16.0 : 15.0,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          if (item.marked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Completed'.tr, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: tablet ? 14 : 12),
                      Text(
                        "৳ ${numberTranslation.toBnDigits("${item.amount}")}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: tablet ? 34.0 : 30.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: tablet ? 13.0 : 12.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Detail Rows
                Padding(
                  padding: EdgeInsets.all(tablet ? 24.0 : 20.0),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: item.type == "Lent" || item.type == "Borrow"
                            ? Icons.person_outline
                            : Icons.category_outlined,
                        label: item.type == "Lent" || item.type == "Borrow"
                            ? "Person Name:".tr
                            : "Category:".tr,
                        value: item.category.isEmpty ? "No Name".tr : item.category.tr,
                      ),
                      _DetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Wallet:".tr,
                        value: item.wallet.tr,
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: "Date:".tr,
                        value: dateText,
                      ),
                      _DetailRow(
                        icon: Icons.notes_outlined,
                        label: "Remark:".tr,
                        value: item.note.isEmpty ? "No Remark".tr : item.note.tr,
                      ),
                      SizedBox(height: tablet ? 12 : 10),
                      // Mark button
                      SizedBox(
                        width: double.infinity,
                        height: tablet ? 50 : 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.find<debtsController>().toggleTransactionMarked(
                              monthKey: item.monthKey,
                              transactionId: item.id,
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.marked ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            item.marked
                                ? "Mark as Pending".tr
                                : "Mark as Completed".tr,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        height: tablet ? 50 : 46,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Close".tr,
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontSize: tablet ? 15 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonDebtTile extends StatelessWidget {
  final PersonDebt debt;
  final bool isTablet;
  const _PersonDebtTile({required this.debt, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final isLent = debt.netAmount > 0;
    final amount = debt.netAmount.abs();
    final color = isLent ? Colors.orange : Colors.purple;
    final status = isLent ? "You will receive".tr : "You need to pay".tr;

    return _GlassCard(
      borderColor: color.withOpacity(0.5),
      padding: EdgeInsets.all(isTablet ? 10.0 : 12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            debt.name.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 13.0 : 15.sp,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "৳${numberTranslation.toBnDigits(amount.toStringAsFixed(0))}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16.0 : 18.sp,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(height: isTablet ? 2.0 : 2.h),
          Text(
            status,
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTablet ? 10.0 : 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tablet ? 5.0 : 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: tablet ? 14.0 : 16.sp, color: Colors.black54),
          SizedBox(width: tablet ? 6.0 : 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: tablet ? 13.0 : 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: tablet ? 4.0 : 6.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: tablet ? 13.0 : 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

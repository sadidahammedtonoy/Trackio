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

class deptsPage extends StatelessWidget {
  deptsPage({super.key});
  final controller = Get.find<debtsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Debts".tr,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
                icon: controller.isSearchVisible.value
                    ? const Icon(Icons.close, color: Colors.black)
                    : HugeIcon(icon: HugeIcons.strokeRoundedSearch02, color: Colors.black, size: 24.sp),
                onPressed: () {
                  controller.toggleSearch();
                },
              )),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Obx(() => controller.isSearchVisible.value
                ? Padding(
                    padding: EdgeInsets.only(bottom: 15.h, top: 5.h),
                    child: TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Search Name or Remark...".tr,
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black45),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 16.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (val) => controller.setSearchQuery(val),
                    ),
                  )
                : const SizedBox.shrink()),
            StreamBuilder<Map<String, double>>(
              stream: controller.streamTotalLentBorrow(),
              builder: (context, snapshot) {
                final data =
                    snapshot.data ?? {"lent": 0.0, "borrow": 0.0, "net": 0.0};

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
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
                              padding: EdgeInsets.all(16.r),
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
                                          fontSize: 18.sp,
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
                                          size: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "৳${numberTranslation.toBnDigits(data["lent"]!.toStringAsFixed(1))}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        fontSize: 22.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "You Will Receive.".tr,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
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
                              padding: EdgeInsets.all(16.r),
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
                                          fontSize: 18.sp,
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
                                          size: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "৳${numberTranslation.toBnDigits(data["borrow"]!.toStringAsFixed(1))}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                        fontSize: 22.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "You Need to Pay.".tr,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: StreamBuilder<List<TranItem>>(
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
                      return Center(
                        child: Text(query.isEmpty
                            ? "No lent or borrow transactions".tr
                            : "No matching results found".tr),
                      );
                    }

                    List<dynamic> groupedItems = [];
                    String? lastMonth;

                    for (var item in items) {
                      String currentMonth = DateFormat('MMMM yyyy').format(item.date);
                      if (currentMonth != lastMonth) {
                        groupedItems.add(currentMonth);
                        lastMonth = currentMonth;
                      }
                      groupedItems.add(item);
                    }

                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: 115.h), 
                      itemCount: groupedItems.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = groupedItems[index];

                        if (item is String) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h, left: 4.w, top: index == 0 ? 0 : 20.h),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        } else if (item is TranItem) {
                          return _TransactionTile(
                            item: item,
                            onDelete: () async {
                              await controller.deleteMonthlyTransaction(
                                monthKey: item.monthKey,
                                transactionId: item.id,
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.onDelete});

  final TranItem item;
  final Future<void> Function() onDelete;

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
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
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
                            fontSize: 15.sp,
                            color: Colors.black87,
                          ),
                        ),
                        if (item.marked)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Icon(Icons.check_circle,
                                color: Colors.green, size: 14.sp),
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.wallet.tr,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.sp,
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
                      fontSize: 15.sp,
                      color: typeColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date)) + 
                    ", " + 
                    numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date)),
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 10.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBg(dynamic icon, String text, Color color, Alignment alignment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [HugeIcon(icon: icon, color: color, size: 22.sp), SizedBox(width: 8.w), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold))]
            : [Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)), SizedBox(width: 8.w), HugeIcon(icon: icon, color: color, size: 22.sp)],
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
    final typeColor = _typeColor(item.type);

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: typeColor.withOpacity(0.15)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.type.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            color: typeColor,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Transaction".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (item.marked)
                      Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                  ],
                ),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "৳ ${numberTranslation.toBnDigits("${item.amount}")}",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(),
                SizedBox(height: 10.h),
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
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.find<debtsController>().toggleTransactionMarked(
                            monthKey: item.monthKey,
                            transactionId: item.id,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              item.marked ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Mark as ${item.marked ? "Pending".tr : "Completed".tr}"
                              .tr,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Close".tr,
                      style: const TextStyle(color: Colors.black54),
                    ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.black54),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

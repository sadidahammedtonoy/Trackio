import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/numberTranslation.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import '../Model/tranModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class transcations_page extends StatelessWidget {
  final controller = Get.put(transactionsController());

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  double _sectionTotal(List<TranItem> list) {
    return list.fold(0.0, (sum, t) {
      if (t.type == "Lent" || t.type == "Borrow") {
        return sum;
      }

      if (t.type == "Expense") {
        return sum - t.amount;
      }

      return sum + t.amount;
    });
  }

  Map<DateTime, List<TranItem>> _groupByDate(List<TranItem> items) {
    final map = <DateTime, List<TranItem>>{};
    for (final t in items) {
      final key = _dayKey(t.date);
      map.putIfAbsent(key, () => <TranItem>[]).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    controller.setMonthFromDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Obx(() {
        final selected = controller.selectedMonthKey.value;
        return Text(
          selected == null ? "All Transactions".tr : "Month: $selected",
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () {
            _showMonthFilterSheet(context);
          },
        ),
      ],),
      body: Obx(() {
        return Column(
          children: [
            // ✅ List area
            Expanded(
              child: StreamBuilder<List<TranItem>>(
                stream: controller.streamTxnForUI(),
                initialData: controller.cachedTxnForUI(), // ✅ show instantly
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // ✅ Prefer live data; if live is empty but cache has items, keep cache
                  final live = snapshot.data ?? const <TranItem>[];
                  final cached = controller.cachedTxnForUI();
                  final items = live.isNotEmpty ? live : cached;

                  if (items.isEmpty) {
                    return Center(child: Text("No transactions yet".tr));
                  }

                  final now = DateTime.now();
                  final grouped = _groupByDate(items);
                  final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                  String titleForDay(DateTime day) {
                    if (_isSameDay(day, now)) return "Today Transactions".tr;
                    if (_isSameDay(day, now.subtract(const Duration(days: 1)))) {
                      return "Yesterday Transactions".tr;
                    }
                    return numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(day));
                  }

                  Widget header(DateTime day, List<TranItem> list) {
                    final total = _sectionTotal(list);
                    final isPositive = total >= 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            titleForDay(day),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${isPositive ? '+' : ''}${numberTranslation.toBnDigits(total.toStringAsFixed(0))}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  Widget buildTile(TranItem t) => _TransactionTile(
                    item: t,
                    onDelete: () async {
                      await controller.deleteMonthlyTransaction(
                        monthKey: t.monthKey,
                        transactionId: t.id,
                      );
                    },
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: days.expand((day) {
                        final list = grouped[day]!;
                        return [
                          header(day, list),
                          ...list.map(buildTile),
                          const SizedBox(height: 14),
                        ];
                      }).toList(),
                    ),
                  );
                },
              )
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          Get.toNamed(routes.addTranscations_screen);
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: AppColors.primary),
      ),
    );
  }
}

Future<bool> showDeleteTransactionDialog() async {
  if (GetPlatform.isIOS) {
    // 🍎 iOS style
    final result = await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: Text("Delete Transaction".tr),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Are you sure you want to delete this transaction?".tr,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel".tr),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Get.back(result: true),
            child: Text("Delete".tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  } else {
    // 🤖 Android style
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete Transaction".tr),
        content: Text("Are you sure you want to delete this transaction?".tr),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel".tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              "Delete".tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}


class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.item,
    required this.onDelete,
  });

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
    final dateText = numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date));
    final typeColor = _typeColor(item.type);

    return Dismissible(
      key: ValueKey(item.id),

      // ✅ Only swipe left
      // direction: DismissDirection.endToStart,
      // background: const SizedBox.shrink(),
      // ✅ Allow both swipes
      direction: DismissDirection.horizontal,

      // ✅ Left → Right background (Edit)
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              "Edit".tr,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        // ✅ Swipe Left → Right = Edit (DON'T dismiss)
        if (direction == DismissDirection.startToEnd) {
          print("Edit this");
          Get.find<editTransactionsController>().assignValues(item);
          Get.to(editTransactions(model: item,));
          return false;
        }

        // ✅ Swipe Right → Left = Delete (confirm + dismiss)
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDeleteTransactionDialog();
          if (!confirm) return false;

          await onDelete();
          return true;
        }

        return false;
      },


      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Delete".tr,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.red),
          ],
        ),
      ),

      // confirmDismiss: (direction) async {
      //   if (direction != DismissDirection.endToStart) return false;
      //
      //   final confirm = await showDeleteTransactionDialog();
      //   if (!confirm) return false;
      //
      //   await onDelete();
      //
      //   return true;
      // },


      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onLongPress: (){
            Get.dialog(
                Dialog(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 5,
                          children: [
                            Text(item.type.tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.sp, color: typeColor),),
                            Text("Transaction".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22.sp, color: Colors.black),),
                          ],
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text("৳ ${numberTranslation.toBnDigits("${item.amount}")}", style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w800, color: Colors.black),)),
                        Divider(),

                        item.type == "Lent" || item.type == "Borrow" ? Row(
                          spacing: 5,
                          children: [
                            Icon(Icons.person, color: Colors.black, size: 15,),
                            Text("Person Name:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),),
                            Text(item.category, style: TextStyle(fontSize: 16.sp),),
                          ],
                        ) :
                        Row(
                          spacing: 5,
                          children: [
                            Icon(Icons.category, color: Colors.black, size: 15,),
                            Text("Category:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),),
                            Text(item.category.isEmpty ? "Uncategorized".tr : item.category.tr, style: TextStyle(fontSize: 16.sp,),),
                          ],
                        ),

                        Row(
                          spacing: 5,
                          children: [
                            Icon(Icons.account_balance_wallet, color: Colors.black, size: 15,),
                            Text("Wallet:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),),
                            Text(item.wallet.tr, style: TextStyle(fontSize: 16.sp),),
                          ],
                        ),

                        Row(
                          spacing: 5,
                          children: [
                            Icon(Icons.date_range_rounded, color: Colors.black, size: 15,),
                            Text("Date:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),),
                            Text(dateText, style: TextStyle(fontSize: 16.sp),),
                          ],
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Icon(Icons.edit_note_outlined, color: Colors.black, size: 15,),
                            Text("Remark:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),),
                            Expanded(child: Text(item.note.isEmpty ? "No Remark".tr : item.note, style: TextStyle(fontSize: 16.sp),)),
                          ],
                        ),

                        ElevatedButton(onPressed: () => Get.back(), child: Text("Close".tr, style: TextStyle(color: Colors.white),))



                      ],
                    ),
                  ),
                )
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(4, 1), // x, y
                    ),
                  ],
                ),
                child: Text(
                  item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                  style: TextStyle(color: typeColor, fontSize: 20.sp, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 15,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Text(
                          item.category.isEmpty ? "Uncategorized".tr : item.category.tr,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        item.marked ? Icon(Icons.check_circle, color: Colors.green, size: 15,) : SizedBox.shrink()
                      ],
                    ),
                    Row(
                      spacing: 3,
                      children: [
                        Text(
                          item.wallet.tr,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                    style: TextStyle(fontWeight: FontWeight.w800, color: typeColor),
                  ),
                  Text(
                    dateText,
                    style: const TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic,),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

void _showMonthFilterSheet(BuildContext context) {
  final controller = Get.find<transactionsController>();

  Get.bottomSheet(
    ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        padding: const EdgeInsets.only(bottom: 30),
        decoration: const BoxDecoration(
          color: Colors.white
        ),
        child: StreamBuilder<List<String>>(
          stream: controller.streamMonthKeys(),
          builder: (context, snap) {
            final months = snap.data ?? [];

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Drag Handle ---
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // --- Title Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filter by Month".tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Select a month to filter your transactions".tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Divider ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(
                    height: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),

                const SizedBox(height: 8),

                // --- "All Months" Option ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() => _MonthTile(
                    icon: Icons.sick_outlined,
                    label: "All Months".tr,
                    isSelected: controller.selectedMonth.value == null,
                    onTap: () {
                      controller.selectMonth(null);
                      Get.back();
                    },
                  )),
                ),

                // --- Month List ---
                ...months.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() => _MonthTile(
                    icon: Icons.calendar_month_outlined,
                    label: numberTranslation.formatMonthYearBnFromKey(m),
                    isSelected: controller.selectedMonth.value == m,
                    onTap: () {
                      controller.selectMonth(m);
                      Get.back();
                    },
                  )),
                )),

                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    ),
    isDismissible: true,
    enableDrag: true,
  );
}

// ─── Reusable Tile Widget ────────────────────────────────────────────────────

class _MonthTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonthTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cyan palette
    const Color cyanAccent = Color(0xFF06B6D4);   // vibrant cyan
    const Color cyanBg = Color(0xFFECFEFF);       // very light cyan bg
    const Color neutralBg = Color(0xFFF3F4F6);    // default grey bg
    const Color neutralIcon = Color(0xFF6B7280);  // default grey icon

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? cyanBg : Colors.transparent,
            border: Border.all(
              color: isSelected ? cyanAccent.withOpacity(0.35) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? cyanAccent.withOpacity(0.15) : neutralBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? cyanAccent : neutralIcon,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Label
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? cyanAccent : const Color(0xFF1F2937),
                  ),
                  child: Text(label),
                ),
              ),

              // Checkmark or Chevron
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey("check"),
                        size: 22,
                        color: cyanAccent,
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        key: const ValueKey("chevron"),
                        size: 20,
                        color: const Color(0xFF9CA3AF),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
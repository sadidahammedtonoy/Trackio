import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/numberTranslation.dart';
import '../../Transcations/Model/tranModel.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Widgets/monthlyExpenseCharts.dart';
import 'package:intl/intl.dart';

class dashboardPage extends StatelessWidget {
  dashboardPage({super.key});
  final dashboardController controller = Get.find<dashboardController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Dashboard".tr),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<Map<String, double>>(
                stream: controller.streamThisMonthSummary(),
                builder: (context, snap) {
                  final data = snap.data ?? {"expense": 0, "income": 0, "saving": 0};

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 18,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blueAccent,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    offset: const Offset(4, 1),
                                    blurRadius: 10,
                                  )
                                ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.account_balance_wallet_outlined, size: 30, color: Colors.white,)
                                ),
                                const SizedBox(height: 20, width: 110,),
                                Text("Remaining".tr, style: TextStyle(fontSize: 16.sp),),
                                StreamBuilder<double>(
                                  stream: controller.streamThisMonthSavings(),
                                  builder: (context, snap) {
                                    final v = snap.data ?? 0.0;
                                    return Text("৳${numberTranslation.toBnDigits("${(data["income"] ?? 0) - (data["expense"] ?? 0) - v}")}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),);
                                  },
                                )



                              ],
                            ),
                          ),
                          StreamBuilder<double>(
                            stream: controller.streamTodayExpense(),
                            builder: (context, snap) {
                              final todayExpense = snap.data ?? 0;
                              return Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.5),
                                        offset: const Offset(4, 1),
                                        blurRadius: 10,
                                      )
                                    ]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withAlpha(150),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.receipt_long_outlined, size: 30, color: Colors.white,)
                                    ),
                                    const SizedBox(height: 20, width: 100,),
                                    Text("Today Expense".tr, style: TextStyle(fontSize: 16.sp),),
                                    Text("৳${numberTranslation.toBnDigits("$todayExpense")}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

                                  ],
                                ),
                              );

                            },
                          ),

                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blueGrey,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.5),
                                    offset: const Offset(4, 1),
                                    blurRadius: 15,
                                  )
                                ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.today, size: 30, color: Colors.white,)
                                ),
                                const SizedBox(height: 20, width: 110,),
                                Text("Daily Limit".tr, style: TextStyle(fontSize: 16.sp),),
                                StreamBuilder<double>(
                                  stream: controller.streamThisMonthSavings(),
                                  builder: (context, snap) {
                                    final v = snap.data ?? 0.0;
                                    return Text(
                                      "৳${numberTranslation.toBnDigits(
                                        ((((data["income"] ?? 0) - (data["expense"] ?? 0) - v) /
                                            controller.daysLeftInCurrentMonth()))
                                            .toStringAsFixed(1),
                                      )}",
                                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),
                                    );
                                  },
                                )


                              ],
                            ),
                          ),


                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    offset: const Offset(4, 1),
                                    blurRadius: 10,
                                  )
                                ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.trending_up_outlined, size: 30, color: Colors.white,)
                                ),
                                const SizedBox(height: 20, width: 110,),
                                Text("Income".tr, style: TextStyle(fontSize: 16.sp),),
                                Text("৳${numberTranslation.toBnDigits("${data["income"]}")}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

                              ],
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.5),
                                    offset: const Offset(4, 1),
                                    blurRadius: 10,
                                  )
                                ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.trending_down, size: 30, color: Colors.white,)
                                ),
                                const SizedBox(height: 20, width: 110,),
                                Text("Expense".tr, style: TextStyle(fontSize: 16.sp),),
                                Text("৳${numberTranslation.toBnDigits("${data["expense"]}")}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

                              ],
                            ),
                          ),
                      StreamBuilder<double>(
                        stream: controller.streamOverallSavingOnly(),
                        builder: (context, snapshot) {
                          final saving = snapshot.data ?? 0.0;

                          return Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.cyan,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(0.5),
                                    offset: const Offset(4, 1),
                                    blurRadius: 10,
                                  )
                                ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.savings_outlined, size: 30, color: Colors.white,)
                                ),
                                const SizedBox(height: 20, width: 110,),
                                Text("Saving".tr, style: TextStyle(fontSize: 16.sp),),
                                Text("৳${numberTranslation.toBnDigits(saving.toStringAsFixed(0))}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),
                              ],
                            ),
                          );
                        },
                      ),
                        ],
                      ),
                    ),
                  );

                },
              ),
              const SizedBox(height: 15),
              Text(
                "Category Breakdown".tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: CategoryPieChart(),
              ),
              StreamBuilder<List<TranItem>>(
                stream: controller.streamTodayTransactions(),
                initialData: controller.cachedTodayItems, // ✅ show cached instantly
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // ✅ If snapshot is empty but cache has data, keep showing cache
                  final liveItems = snapshot.data ?? const <TranItem>[];
                  final cachedItems = controller.cachedTodayItems;

                  final items = liveItems.isNotEmpty ? liveItems : cachedItems;

                  if (items.isEmpty) {
                    return Center(child: Text("No transactions today".tr));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today Transactions".tr,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),

                      ...items.map((t) => _TransactionTile(
                        item: t,
                        onDelete: () async {
                          await controller.deleteMonthlyTransaction(
                            monthKey: t.monthKey,
                            transactionId: t.id,
                          );
                        },
                      )),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}



Future<bool> showDeleteTransactionDialog() async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Delete Transaction".tr),
      content: Text("Are you sure you want to delete this transaction?".tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text("Cancel".tr),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text("Delete".tr, style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
    barrierDismissible: false,
  );
  return result ?? false;
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
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),


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

      confirmDismiss: (direction) async {
        if (direction != DismissDirection.endToStart) return false;

        final confirm = await showDeleteTransactionDialog();
        if (!confirm) return false;

        await onDelete();

        return true;
      },


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
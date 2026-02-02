import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: const Text("Dashboard"),
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
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 8,
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
                                Text("Remaining", style: TextStyle(fontSize: 16.sp),),
                                Text("৳${(data["income"] ?? 0) - (data["expense"] ?? 0)}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

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
                                        color: Colors.orange.withOpacity(0.2),
                                        blurRadius: 8,
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
                                    Text("Today Expense", style: TextStyle(fontSize: 16.sp),),
                                    Text("৳$todayExpense", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

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
                                  color: Colors.green,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
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
                                Text("Income", style: TextStyle(fontSize: 16.sp),),
                                Text("৳${data["income"]}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

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
                                    color: Colors.redAccent.withOpacity(0.2),
                                    blurRadius: 8,
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
                                Text("Expense", style: TextStyle(fontSize: 16.sp),),
                                Text("৳${data["expense"]}", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

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
                                  color: Colors.green,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
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
                                    child: Icon(Icons.savings_outlined, size: 30, color: Colors.white,)
                                ),
                                const SizedBox(height: 20, width: 110,),
                                Text("Saving", style: TextStyle(fontSize: 16.sp),),
                                Text("৳$saving", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),),

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
              const Text(
                "Category Breakdown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: CategoryPieChart(),
              ),
              StreamBuilder<List<TranItem>>(
                stream: controller.streamTodayTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Center(child: Text("No transactions today"));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today Transactions",
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
      title: const Text("Delete Transaction"),
      content: const Text("Are you sure you want to delete this transaction?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
    final dateText = DateFormat('dd MMM, yyyy • hh:mm a').format(item.date);
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
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Delete",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
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


      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: typeColor,
              radius: 18,
              child: Text(
                item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.wallet} • $dateText",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  if (item.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Note: ${item.note}",
                      style:
                      const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item.amount.toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.w800, color: typeColor),
            ),
          ],
        ),
      ),
    );
  }
}
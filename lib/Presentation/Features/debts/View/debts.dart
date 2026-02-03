import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Transcations/Model/tranModel.dart';
import '../Controller/Controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class deptsPage extends StatelessWidget {
  deptsPage({super.key});
  final controller = Get.find<debtsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debts"), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            StreamBuilder<Map<String, double>>(
              stream: controller.streamTotalLentBorrow(),
              builder: (context, snapshot) {
                final data =
                    snapshot.data ?? {"lent": 0.0, "borrow": 0.0, "net": 0.0};

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text("Balance: ", style: TextStyle(fontSize: 28.sp)),
                    //     Text(
                    //       "৳${data["net"]!.toStringAsFixed(2)}",
                    //       style: TextStyle(
                    //         color: (data["net"] ?? 0) >= 0
                    //             ? Colors.green
                    //             : Colors.red,
                    //         fontSize: 28.sp,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //
                    const SizedBox(height: 10),

                    Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              border: Border.all(
                              color: Colors.orange,
                              width: 1,
                              style: BorderStyle.solid,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 0.5,
                                  offset: const Offset(4, 1), // x, y
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Lent",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Tooltip(
                                      message: "Lent means giving money to another person with the expectation that it will be returned in the future.",
                                      triggerMode: TooltipTriggerMode.tap,
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.all(8),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  "৳${data["lent"]!.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange,
                                    fontSize: 25,
                                  ),
                                ),
                                const Text(
                                  "You Will Receive.",
                                  style: TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.purple,
                                width: 0.5,
                                style: BorderStyle.solid,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(4, 1), // x, y
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Borrow",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    Tooltip(
                                      message: "Borrow means money you received and must repay later.",
                                      triggerMode: TooltipTriggerMode.tap,
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.all(8),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  "৳${data["borrow"]!.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple,
                                    fontSize: 25,
                                  ),
                                ),
                                const Text(
                                  "You Need to Pay.",
                                  style: TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 15),
            StreamBuilder<List<TranItem>>(
              stream: controller.streamLentBorrowTransactions(),
              initialData: controller.cachedLentBorrow, // ✅ instant
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final live = snapshot.data ?? const <TranItem>[];
                final cached = controller.cachedLentBorrow;

                // ✅ keep cached until live arrives
                final items = live.isNotEmpty ? live : cached;

                if (items.isEmpty) {
                  return const Center(
                    child: Text("No lent or borrow transactions"),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Transactions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...items.map(
                      (t) => _TransactionTile(
                        item: t,
                        onDelete: () async {
                          await controller.deleteMonthlyTransaction(
                            monthKey: t.monthKey,
                            transactionId: t.id,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
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
    final dateText = DateFormat('dd MMM, yyyy').format(item.date);
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Delete",
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
          onLongPress: () {
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
                      Text(
                        "${item.type} Transaction",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                          color: typeColor,
                        ),
                      ),
                      item.type == "Lent" || item.type == "Borrow"
                          ? Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 15,
                                ),
                                Text(
                                  "Person Name:",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ],
                            )
                          : Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.category,
                                  color: Colors.black,
                                  size: 15,
                                ),
                                Text(
                                  "Category:",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ],
                            ),
                      Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.wallet, color: Colors.black, size: 15),
                          Text(
                            "Amount:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "৳${item.amount}",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),

                      Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.black,
                            size: 15,
                          ),
                          Text(
                            "Wallet:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(item.wallet, style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),

                      Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            color: Colors.black,
                            size: 15,
                          ),
                          Text(
                            "Date:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(dateText, style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.edit_note_outlined,
                            color: Colors.black,
                            size: 15,
                          ),
                          Text(
                            "Remark:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.note.isEmpty ? "No Remark" : item.note,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Close",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Row(
                      spacing: 3,
                      children: [
                        Text(
                          item.wallet,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
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
                    "৳${item.amount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: typeColor,
                    ),
                  ),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
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
}

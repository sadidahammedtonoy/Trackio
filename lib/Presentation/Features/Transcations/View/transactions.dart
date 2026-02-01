import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import '../Controller/Controller.dart';
import '../Model/tranModel.dart';
import 'package:intl/intl.dart';

class transcations_page extends StatelessWidget {
  final controller = Get.put(transactionsController());

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  double _sectionTotal(List<TranItem> list) {
    return list.fold(0.0, (sum, t) {
      if (t.type == "Expense" || t.type == "Lent") return sum - t.amount;
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
          selected == null ? "All Transactions" : "Month: $selected",
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.deepPurple),
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
                // if selectedMonthKey == null -> show all
                stream: controller.selectedMonthKey.value == null
                    ? controller.streamAllItems()
                    : controller.streamMonthlyItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text("No transactions yet"));
                  }

                  final now = DateTime.now();
                  final grouped = _groupByDate(items);
                  final days = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  String titleForDay(DateTime day) {
                    if (_isSameDay(day, now)) return "Today Transactions";
                    if (_isSameDay(day, now.subtract(const Duration(days: 1)))) {
                      return "Yesterday Transactions";
                    }
                    return DateFormat('dd MMM yyyy').format(day); // 31 Jan 2026
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${isPositive ? '+' : ''}${total.toStringAsFixed(0)}",
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
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(routes.addTranscations_screen);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.deepPurple),
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


void _showMonthFilterSheet(BuildContext context) {
  final controller = Get.find<transactionsController>();

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StreamBuilder<List<String>>(
        stream: controller.streamMonthKeys(),
        builder: (context, snap) {
          final months = snap.data ?? [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Filter by Month",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.all_inbox),
                title: const Text("All Months"),
                onTap: () {
                  controller.selectMonth(null);
                  Get.back();
                },
              ),

              ...months.map((m) => ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(m), // can format later
                onTap: () {
                  controller.selectMonth(m);
                  Get.back();
                },
              )),
            ],
          );
        },
      ),
    ),
  );
}
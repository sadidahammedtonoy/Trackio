import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' hide Rx;
import '../../Transcations/Model/tranModel.dart';
import '../../Budget/Model/budgetModel.dart';

class dashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  final RxMap<String, double> monthSummary = {"expense": 0.0, "income": 0.0}.obs;
  final RxDouble todayExpense = 0.0.obs;
  final RxDouble totalSavingAllTime = 0.0.obs;
  final RxDouble thisMonthSavings = 0.0.obs;
  final RxMap<String, double> categorySummary = <String, double>{}.obs;
  final RxList<TranItem> todayTransactions = <TranItem>[].obs;
  final RxList<double> weeklyAmounts = List.filled(7, 0.0).obs;
  final RxList<String> labels = <String>[].obs;
  final RxBool isLoading = true.obs;
  final Rxn<String> touchedValue = Rxn<String>();
  final RxList<BudgetStatus> overBudget = <BudgetStatus>[].obs;

  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxMap<int, double> dailyExpenses = <int, double>{}.obs;

  String get _uid => _auth.currentUser?.uid ?? "";
  StreamSubscription? _mainSub;

  @override
  void onInit() {
    super.onInit();
    _setupLabels();
    _initDashboardStream();
  }

  void _setupLabels() {
    final now = DateTime.now();
    final list = <String>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      list.add(DateFormat('EEE').format(day));
    }
    labels.assignAll(list);
  }

  void _initDashboardStream() {
    if (_uid.isEmpty) return;

    // 1. Listen to all months to aggregate global data (Weekly, All-time Savings)
    final monthsRef = _firestore.collection('users').doc(_uid).collection('monthly_transactions');

    final allTxsStream = monthsRef.snapshots().switchMap((monthsSnap) {
      if (monthsSnap.docs.isEmpty) return Stream.value(<TranItem>[]);
      
      final itemStreams = monthsSnap.docs.map((m) {
        return monthsRef.doc(m.id).collection('items').snapshots().map((s) {
          return s.docs.map((d) => TranItem.fromDoc(d, monthKey: m.id)).toList();
        });
      }).toList();

      return CombineLatestStream.list<List<TranItem>>(itemStreams)
          .map((lists) => lists.expand((x) => x).toList());
    });

    // 2. Stream Budgets based on selectedMonth
    final budgetsStream = selectedMonth.stream
        .startWith(selectedMonth.value)
        .switchMap((date) {
          final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
          return _firestore
              .collection('users')
              .doc(_uid)
              .collection('budgets')
              .where('monthKey', isEqualTo: key)
              .snapshots()
              .map((snap) => snap.docs.map((doc) => BudgetModel.fromDoc(doc)).toList());
        });

    // 3. Combine both streams with the selected month selection
    _mainSub = CombineLatestStream.combine3(
      allTxsStream,
      budgetsStream,
      selectedMonth.stream.startWith(selectedMonth.value),
      (List<TranItem> allTxs, List<BudgetModel> budgets, DateTime currentMonth) {
        _processDashboardData(allTxs, budgets, currentMonth);
      },
    ).listen((_) {}, onError: (e) => debugPrint("Dashboard Stream Error: $e"));
  }

  void _processDashboardData(List<TranItem> allTxs, List<BudgetModel> budgets, DateTime currentMonth) {
    final monthKey = "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}";
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    double income = 0, expense = 0, todayExp = 0, monthSaving = 0, totalSavings = 0;
    final Map<String, double> catSum = {};
    final List<TranItem> todayTxsList = [];
    final Map<int, double> dailyExp = {};
    final weekly = List.filled(7, 0.0);

    for (var tx in allTxs) {
      // Global logic: All-time Savings
      if (tx.type == "Saving") totalSavings += tx.amount;

      // Global logic: Weekly Chart (Last 7 days)
      final txDateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final diff = todayStart.difference(txDateOnly).inDays;
      if (diff >= 0 && diff < 7 && tx.type == "Expense") {
        weekly[6 - diff] += tx.amount;
      }

      // Selected Month logic
      if (tx.monthKey == monthKey) {
        if (tx.type == "Income") income += tx.amount;
        if (tx.type == "Expense") {
          expense += tx.amount;
          catSum[tx.category] = (catSum[tx.category] ?? 0) + tx.amount;
          dailyExp[tx.date.day] = (dailyExp[tx.date.day] ?? 0) + tx.amount;
        }
        if (tx.type == "Saving") monthSaving += tx.amount;

        // Today's Transactions logic
        if (_isSameDay(tx.date, now)) {
          todayTxsList.add(tx);
          if (tx.type == "Expense") todayExp += tx.amount;
        }
      }
    }

    // Update States
    monthSummary.assignAll({"income": income, "expense": expense});
    thisMonthSavings.value = monthSaving;
    todayExpense.value = todayExp;
    categorySummary.assignAll(catSum);
    todayTransactions.assignAll(todayTxsList);
    dailyExpenses.assignAll(dailyExp);
    weeklyAmounts.assignAll(weekly);
    totalSavingAllTime.value = totalSavings;

    // Budget check logic
    final List<BudgetStatus> over = [];
    for (var b in budgets) {
      final spent = catSum[b.category] ?? 0.0;
      if (spent > b.limit && b.limit > 0) {
        over.add(BudgetStatus(category: b.category, limit: b.limit, spent: spent));
      }
    }
    overBudget.assignAll(over);

    isLoading.value = false;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void changeMonth(int offset) {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month + offset, 1);
  }

  int daysLeftInCurrentMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(DateTime(now.year, now.month, now.day)).inDays + 1;
  }

  Future<void> deleteTransaction(TranItem item) async {
    if (_uid.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('monthly_transactions')
        .doc(item.monthKey)
        .collection('items')
        .doc(item.id)
        .delete();
  }

  @override
  void onClose() {
    _mainSub?.cancel();
    super.onClose();
  }
}

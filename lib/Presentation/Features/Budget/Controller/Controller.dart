import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/budgetModel.dart';
import '../../Transcations/Model/tranModel.dart';
import '../../Recurring/Model/recurringModel.dart';
import 'dart:async';

class InsightsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxString selectedMonthKey = "".obs;
  final RxString budgetMonthKey = "".obs;
  final RxBool isAnalyticsMode = false.obs;
  final RxString selectedCategory = "".obs;
  final TextEditingController amountC = TextEditingController();

  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;
  final RxList<TranItem> transactions = <TranItem>[].obs;
  final RxList<BudgetStatus> budgetStatuses = <BudgetStatus>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<RecurringModel> recurringItems = <RecurringModel>[].obs;

  StreamSubscription? _budgetSub;
  StreamSubscription? _tranSub;

  String get _uid => _auth.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedMonthKey.value = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    budgetMonthKey.value = selectedMonthKey.value;
    
    _fetchCategories();
    _fetchRecurringItems();
    
    // Listen to month changes to refresh streams
    ever(selectedMonthKey, (_) => _startStreams());
    _startStreams();
  }

  void setMonth(DateTime date) {
    selectedMonthKey.value = "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  void _fetchCategories() {
    if (_uid.isEmpty) return;
    _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      categories.assignAll(snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList());
    });
  }

  void _fetchRecurringItems() {
    if (_uid.isEmpty) return;
    _firestore
        .collection('users')
        .doc(_uid)
        .collection('recurring')
        .snapshots()
        .listen((snapshot) {
      recurringItems.assignAll(snapshot.docs.map((doc) => RecurringModel.fromDoc(doc)).toList());
    });
  }

  void _startStreams() {
    _budgetSub?.cancel();
    _tranSub?.cancel();
    if (_uid.isEmpty) return;

    // 1. Stream Budgets for selected month
    _budgetSub = _firestore
        .collection('users')
        .doc(_uid)
        .collection('budgets')
        .where('monthKey', isEqualTo: selectedMonthKey.value)
        .snapshots()
        .listen((snapshot) {
      budgets.assignAll(snapshot.docs.map((doc) => BudgetModel.fromDoc(doc)).toList());
      _calculateStatus();
    });

    // 2. Stream Transactions for selected month
    _tranSub = _firestore
        .collection('users')
        .doc(_uid)
        .collection('monthly_transactions')
        .doc(selectedMonthKey.value)
        .collection('items')
        .snapshots()
        .listen((snapshot) {
      transactions.assignAll(snapshot.docs.map((doc) => TranItem.fromDoc(doc, monthKey: selectedMonthKey.value)).toList());
      _calculateStatus();
    });
  }

  void _calculateStatus() {
    final Map<String, double> spentByCategory = {};
    for (var tx in transactions) {
      if (tx.type == "Expense") {
        spentByCategory[tx.category] = (spentByCategory[tx.category] ?? 0) + tx.amount;
      }
    }

    final List<BudgetStatus> statusList = [];
    
    // Process ONLY defined budgets
    for (var budget in budgets) {
      statusList.add(BudgetStatus(
        category: budget.category,
        limit: budget.limit,
        spent: spentByCategory[budget.category] ?? 0.0,
      ));
    }

    budgetStatuses.assignAll(statusList);
  }

  Future<void> addOrUpdateBudget() async {
    if (selectedCategory.value.isEmpty || amountC.text.isEmpty) {
      Get.snackbar("Error", "Select category and enter amount");
      return;
    }
    final double limit = double.tryParse(amountC.text) ?? 0;
    try {
      final existing = budgets.firstWhereOrNull(
          (b) => b.category == selectedCategory.value && b.monthKey == budgetMonthKey.value);
      
      if (existing != null) {
        await _firestore.collection('users').doc(_uid).collection('budgets').doc(existing.id).update({'limit': limit});
      } else {
        await _firestore.collection('users').doc(_uid).collection('budgets').add({
          'category': selectedCategory.value,
          'limit': limit,
          'monthKey': budgetMonthKey.value,
        });
      }
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _firestore.collection('users').doc(_uid).collection('budgets').doc(id).delete();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> addRecurring(RecurringModel model) async {
    if (_uid.isEmpty) return;
    await _firestore.collection('users').doc(_uid).collection('recurring').add(model.toMap());
  }

  Future<void> toggleRecurring(RecurringModel model) async {
    if (_uid.isEmpty) return;
    await _firestore.collection('users').doc(_uid).collection('recurring').doc(model.id).update({'isActive': !model.isActive});
  }

  Future<void> deleteRecurring(String id) async {
    if (_uid.isEmpty) return;
    await _firestore.collection('users').doc(_uid).collection('recurring').doc(id).delete();
  }

  @override
  void onClose() {
    _budgetSub?.cancel();
    _tranSub?.cancel();
    amountC.dispose();
    super.onClose();
  }
}

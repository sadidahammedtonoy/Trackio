import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/recurringModel.dart';
import '../../Transcations/Model/tranModel.dart';

class RecurringController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<RecurringModel> recurringItems = <RecurringModel>[].obs;

  String get _uid => _auth.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    _fetchRecurringItems();
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
      checkAndExecuteRecurring();
    });
  }

  Future<void> checkAndExecuteRecurring() async {
    if (_uid.isEmpty) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activeRecurring = recurringItems.where((r) => r.isActive).toList();

    for (var item in activeRecurring) {
      bool shouldExecute = false;
      DateTime? nextRun;

      if (item.frequency == "Scheduled" || item.frequency == "One-time") {
        if (item.nextExecutionDate != null && !item.nextExecutionDate!.isAfter(now)) {
          shouldExecute = true;
        }
      } else if (item.frequency == "Daily") {
        final lastRun = item.lastExecutedMonthKey.isEmpty ? null : _parseLastRun(item.lastExecutedMonthKey);
        if (lastRun == null || lastRun.isBefore(today)) {
          shouldExecute = true;
          nextRun = today.add(const Duration(days: 1));
        }
      } else if (item.frequency == "Weekly") {
        final lastRun = item.lastExecutedMonthKey.isEmpty ? null : _parseLastRun(item.lastExecutedMonthKey);
        if (lastRun == null || lastRun.isBefore(today.subtract(const Duration(days: 6)))) {
          shouldExecute = true;
          nextRun = today.add(const Duration(days: 7));
        }
      } else if (item.frequency == "Monthly") {
        final currentMonthKey = _getMonthKey(now);
        if (item.lastExecutedMonthKey != currentMonthKey) {
          shouldExecute = true;
          nextRun = DateTime(now.year, now.month + 1, now.day);
        }
      }

      if (shouldExecute) {
        await _executeTransaction(item);
        
        if (item.frequency == "Scheduled" || item.frequency == "One-time") {
          // Deactivate or delete scheduled item after execution
          await _firestore
              .collection('users')
              .doc(_uid)
              .collection('recurring')
              .doc(item.id)
              .update({'isActive': false, 'lastExecutedMonthKey': _getMonthKey(now)});
        } else {
          // Update last execution and next date
          await _firestore
              .collection('users')
              .doc(_uid)
              .collection('recurring')
              .doc(item.id)
              .update({
            'lastExecutedMonthKey': _getTimestampKey(now),
            'nextExecutionDate': nextRun != null ? Timestamp.fromDate(nextRun) : null,
          });
        }
      }
    }
  }

  Future<void> _executeTransaction(RecurringModel item) async {
    final now = DateTime.now();
    final monthKey = _getMonthKey(now);
    
    // Add to monthly_transactions sub-collection
    final monthRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('monthly_transactions')
        .doc(monthKey);
    
    await monthRef.set({"updatedAt": FieldValue.serverTimestamp()}, SetOptions(merge: true));

    final docRef = monthRef.collection('items').doc();
    final tranData = {
      'type': item.type,
      'date': Timestamp.now(),
      'amount': item.amount,
      'wallet': item.wallet,
      'category': item.category,
      'note': "[Auto] ${item.note}".trim(),
      'marked': item.type == "Lent" || item.type == "Borrow" ? false : true,
      'monthKey': monthKey,
    };

    await docRef.set(tranData);
    debugPrint("✅ Executed Automation: ${item.note} (${item.type})");
  }

  String _getMonthKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  String _getTimestampKey(DateTime date) {
    return date.toIso8601String();
  }

  DateTime? _parseLastRun(String key) {
    try {
      return DateTime.parse(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> addRecurring(RecurringModel model) async {
    if (_uid.isEmpty) return;
    await _firestore.collection('users').doc(_uid).collection('recurring').add(model.toMap());
  }

  Future<void> toggleRecurring(RecurringModel model) async {
    if (_uid.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('recurring')
        .doc(model.id)
        .update({'isActive': !model.isActive});
  }

  Future<void> deleteRecurring(String id) async {
    if (_uid.isEmpty) return;
    await _firestore.collection('users').doc(_uid).collection('recurring').doc(id).delete();
  }

  List<RecurringModel> getAllRecurring() {
    return recurringItems;
  }
}

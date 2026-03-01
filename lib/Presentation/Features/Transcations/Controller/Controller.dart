import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/tranModel.dart';

class transactionsController extends GetxController {

  final RxString monthKey = ''.obs;
  final RxString selectedMonth = ''.obs;


  // ✅ month filter toggle: null = ALL months
  final RxnString selectedMonthKey = RxnString(null);

  // Search logic
  final RxBool isSearchVisible = false.obs;
  final RxString searchQuery = ''.obs;

  // Category filter logic
  final RxnString selectedCategoryFilter = RxnString(null);

  void toggleCategoryFilter(String category) {
    if (selectedCategoryFilter.value == category) {
      selectedCategoryFilter.value = null;
    } else {
      selectedCategoryFilter.value = category;
    }
  }

  // Scroll to top logic
  final ScrollController scrollController = ScrollController();
  final RxBool showScrollToTop = false.obs;
  Timer? _scrollStopTimer;

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchQuery.value = '';
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void setMonthFromDate(DateTime date) {
    monthKey.value = "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  void selectMonth(String? key) {
    // null => show ALL transactions
    selectedMonthKey.value = key;
    // reset category filter when month changes
    selectedCategoryFilter.value = null;
  }

  final RxList<TranItem> cachedAllItems = <TranItem>[].obs;
  final RxList<TranItem> cachedMonthItems = <TranItem>[].obs;

  StreamSubscription<List<TranItem>>? _allSub;
  StreamSubscription<List<TranItem>>? _monthSub;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.offset > 300) {
        showScrollToTop.value = true;
        
        // Reset timer whenever user scrolls
        _scrollStopTimer?.cancel();
        _scrollStopTimer = Timer(const Duration(seconds: 1), () {
          showScrollToTop.value = false;
        });
      } else {
        showScrollToTop.value = false;
        _scrollStopTimer?.cancel();
      }
    });

    // Keep "all items" hot
    _allSub = streamAllItems().listen((list) {
      cachedAllItems.assignAll(list);
    });

    // Keep "month items" hot (will update when selectedMonthKey changes too)
    ever(selectedMonthKey, (_) {
      _monthSub?.cancel();
      _monthSub = streamMonthlyItems().listen((list) {
        cachedMonthItems.assignAll(list);
      });
    });

    // initial month subscription
    _monthSub = streamMonthlyItems().listen((list) {
      cachedMonthItems.assignAll(list);
    });
  }

  @override
  void onClose() {
    _allSub?.cancel();
    _monthSub?.cancel();
    _scrollStopTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  /// ✅ Use this in UI so it doesn’t flicker
  Stream<List<TranItem>> streamTxnForUI() {
    final isAll = selectedMonthKey.value == null;
    return isAll ? streamAllItems() : streamMonthlyItems();
  }

  /// ✅ Cached fallback for UI
  List<TranItem> cachedTxnForUI() {
    final isAll = selectedMonthKey.value == null;
    var items = isAll ? cachedAllItems : cachedMonthItems;
    
    // Apply Category Filter
    if (selectedCategoryFilter.value != null) {
      final cat = selectedCategoryFilter.value!;
      items = items.where((item) {
        if (item.type == "Lent" || item.type == "Borrow") {
          return item.type == cat;
        }
        final displayCat = item.category.isEmpty ? "Uncategorized" : item.category;
        return displayCat == cat;
      }).toList().obs;
    }

    if (searchQuery.isEmpty) return items;
    
    return items.where((item) {
      final categoryMatch = item.category.toLowerCase().contains(searchQuery.value.toLowerCase());
      final remarkMatch = item.note.toLowerCase().contains(searchQuery.value.toLowerCase());
      return categoryMatch || remarkMatch;
    }).toList();
  }

  // ✅ Existing (month basis)
  Stream<List<TranItem>> streamMonthlyItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    // IMPORTANT: decide which month you want to load
    final key = selectedMonthKey.value ?? monthKey.value;

    if (key.trim().isEmpty) {
      // debug
      print("❌ streamMonthlyItems monthKey empty!");
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(key)
        .collection('items')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => TranItem.fromDoc(d, monthKey: key))
        .toList());
  }


  // ✅ NEW: stream ALL months (reads every month doc and merges items)
  Stream<List<TranItem>> streamAllItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions');

    return monthsRef.snapshots().asyncMap((monthsSnap) async {
      final all = <TranItem>[];

      print("✅ months count = ${monthsSnap.docs.length}");

      for (final monthDoc in monthsSnap.docs) {
        final mk = monthDoc.id; // ✅ THIS is the month key

        if (mk.trim().isEmpty) continue;

        final itemsSnap = await monthsRef
            .doc(mk)
            .collection('items')
            .orderBy('date', descending: true)
            .get();

        all.addAll(
          itemsSnap.docs.map((d) => TranItem.fromDoc(d, monthKey: mk)),
        );
      }

      all.sort((a, b) => b.date.compareTo(a.date));
      return all;
    });
  }

  // ✅ Month dropdown options
  Stream<List<String>> streamMonthKeys() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .snapshots()
        .map((snap) {
      final keys = snap.docs.map((d) => d.id).toList();
      keys.sort((a, b) => b.compareTo(a)); // newest first
      return keys;
    });
  }

  Future<bool> deleteMonthlyTransaction({
    required String monthKey,
    required String transactionId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final monthRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('monthly_transactions')
          .doc(monthKey);

      // ✅ delete item
      await monthRef.collection('items').doc(transactionId).delete();

      // ✅ touch parent doc so month snapshot changes (important for streamAllItems)
      await monthRef.set({
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint("❌ Delete failed: $e");
      return false;
    }
  }

}

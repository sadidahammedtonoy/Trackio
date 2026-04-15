import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart' hide Rx;
import '../Model/tranModel.dart';

class transactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxString monthKey = ''.obs;
  final RxString selectedMonth = ''.obs;

  // ✅ month filter toggle: null = ALL months
  final RxnString selectedMonthKey = RxnString(null);

  // Search logic
  final RxBool isSearchVisible = false.obs;
  final RxString searchQuery = ''.obs;

  // Category filter logic
  final RxnString selectedCategoryFilter = RxnString(null);

  final RxList<TranItem> cachedItems = <TranItem>[].obs;
  final RxList<TranItem> filteredItems = <TranItem>[].obs;
  final RxList<String> availableMonthKeys = <String>[].obs;

  StreamSubscription? _mainSub;
  StreamSubscription? _monthKeysSub;

  // Scroll to top logic
  final ScrollController scrollController = ScrollController();
  final RxBool showScrollToTop = false.obs;
  Timer? _scrollStopTimer;

  String get _uid => _auth.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.offset > 300) {
        showScrollToTop.value = true;
        _scrollStopTimer?.cancel();
        _scrollStopTimer = Timer(const Duration(seconds: 1), () {
          showScrollToTop.value = false;
        });
      } else {
        showScrollToTop.value = false;
        _scrollStopTimer?.cancel();
      }
    });

    // Re-filter when any filter change or items change
    ever(cachedItems, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    ever(selectedCategoryFilter, (_) => applyFilters());

    _subscribeToMonthKeys();
    
    // Initial setup for the stream
    _initTransactionsStream();
  }

  void _subscribeToMonthKeys() {
    if (_uid.isEmpty) return;

    _monthKeysSub = _firestore
        .collection('users')
        .doc(_uid)
        .collection('monthly_transactions')
        .snapshots()
        .listen((snapshot) {
      final keys = snapshot.docs.map((doc) => doc.id).toList();
      keys.sort((a, b) => b.compareTo(a)); // Newest months first
      availableMonthKeys.assignAll(keys);
    });
  }

  void _initTransactionsStream() {
    _mainSub?.cancel();
    if (_uid.isEmpty) return;

    // Use switchMap to restart the stream whenever selectedMonthKey changes
    _mainSub = selectedMonthKey.stream
        .startWith(selectedMonthKey.value)
        .switchMap((key) => _getTransactionsStream(key))
        .listen((items) {
      cachedItems.assignAll(items);
    }, onError: (e) => debugPrint("❌ Stream Error: $e"));
  }

  Stream<List<TranItem>> _getTransactionsStream(String? key) {
    final monthsRef = _firestore.collection('users').doc(_uid).collection('monthly_transactions');

    if (key != null) {
      // 🟢 Specific Month Stream
      return monthsRef
          .doc(key)
          .collection('items')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((d) => TranItem.fromDoc(d, monthKey: key)).toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      });
    } else {
      // 🔵 All Months Stream
      return monthsRef.snapshots().switchMap((monthsSnap) {
        if (monthsSnap.docs.isEmpty) return Stream.value(<TranItem>[]);

        final itemStreams = monthsSnap.docs.map((m) {
          return monthsRef.doc(m.id).collection('items').snapshots().map((s) {
            return s.docs.map((d) => TranItem.fromDoc(d, monthKey: m.id)).toList();
          }).startWith(<TranItem>[]); // Start with empty to avoid waiting
        }).toList();

        return CombineLatestStream.list<List<TranItem>>(itemStreams).map((lists) {
          final all = lists.expand((x) => x).toList();
          all.sort((a, b) => b.date.compareTo(a.date));
          return all;
        });
      });
    }
  }

  void toggleCategoryFilter(String category) {
    if (selectedCategoryFilter.value == category) {
      selectedCategoryFilter.value = null;
    } else {
      selectedCategoryFilter.value = category;
    }
  }

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
    selectedMonthKey.value = key;
    selectedCategoryFilter.value = null;
  }

  void applyFilters() {
    var items = List<TranItem>.from(cachedItems);

    // Apply Category Filter
    if (selectedCategoryFilter.value != null) {
      final cat = selectedCategoryFilter.value!;
      items = items.where((item) {
        if (item.type == "Lent" || item.type == "Borrow") {
          return item.type == cat;
        }
        final displayCat = item.category.isEmpty ? "Uncategorized" : item.category;
        return displayCat == cat;
      }).toList();
    }

    // Apply Search Filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      items = items.where((item) {
        final categoryMatch = item.category.toLowerCase().contains(query);
        final remarkMatch = item.note.toLowerCase().contains(query);
        final walletMatch = item.wallet.toLowerCase().contains(query);
        final amountMatch = item.amount.toString().contains(query);
        return categoryMatch || remarkMatch || walletMatch || amountMatch;
      }).toList();
    }

    filteredItems.assignAll(items);
  }

  @override
  void onClose() {
    _mainSub?.cancel();
    _monthKeysSub?.cancel();
    _scrollStopTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  List<String> getMonthKeys() {
    return availableMonthKeys;
  }

  Future<bool> deleteTransaction(TranItem item) async {
    try {
      if (_uid.isEmpty) return false;
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('monthly_transactions')
          .doc(item.monthKey)
          .collection('items')
          .doc(item.id)
          .delete();
      return true;
    } catch (e) {
      debugPrint("❌ Delete failed: $e");
      return false;
    }
  }
}

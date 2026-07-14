import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../Model/tranModel.dart';

/// Manages the state and business logic for the transactions feature.
class transactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- PRIVATE STATE ---
  /// Holds the raw, unfiltered list of transactions fetched from Firestore.
  final RxList<TranItem> _rawItems = <TranItem>[].obs;

  // --- PUBLIC REACTIVE STATE ---
  /// The final list of items to be displayed in the UI after all filters are applied.
  final RxList<TranItem> filteredItems = <TranItem>[].obs;

  /// The currently selected month key for filtering (e.g., "2023-10"). Null means "All Months".
  final RxnString selectedMonthKey = RxnString(null);

  /// The list of available month keys (e.g., ["2023-10", "2023-09"]) for the filter sheet.
  final RxList<String> availableMonthKeys = <String>[].obs;

  /// The current search query text.
  final RxString searchQuery = ''.obs;

  /// The currently selected category for filtering.
  final RxnString selectedCategoryFilter = RxnString(null);

  /// Controls the visibility of the search bar in the UI.
  final RxBool isSearchVisible = false.obs;

  /// Controls the visibility of the "Scroll to Top" button.
  final RxBool showScrollToTop = false.obs;

  // --- CONTROLLERS & SUBSCRIPTIONS ---
  final ScrollController scrollController = ScrollController();
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _monthKeysSubscription;
  Timer? _scrollStopTimer;

  String get _uid => _auth.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    _setupReactiveStreams();
    _setupScrollListener();
  }

  /// Sets up the core reactive data flow for the controller.
  void _setupReactiveStreams() {
    if (_uid.isEmpty) return;

    // 1. Stream of available months
    _monthKeysSubscription = _firestore
        .collection('users').doc(_uid).collection('monthly_transactions')
        .snapshots()
        .listen((snapshot) {
      final keys = snapshot.docs.map((doc) => doc.id).toList();
      keys.sort((a, b) => b.compareTo(a)); // Sort newest first
      availableMonthKeys.assignAll(keys);
    });

    // 2. Main transaction data stream
    // This stream reacts to changes in `selectedMonthKey` and automatically
    // switches the Firestore query.
    _transactionSubscription = selectedMonthKey.stream
        .startWith(null) // Ensure it fires once on initialization for "All Months"
        .switchMap((monthKey) => _fetchTransactionsStream(monthKey))
        .listen((items) {
      items.sort((a, b) => b.date.compareTo(a.date));
      _rawItems.assignAll(items);
    }, onError: (e) => print("Error fetching transactions: $e"));

    // 3. Filter workers
    // These workers automatically call `_applyFilters` whenever the source data
    // or any filter criteria change.
    ever(_rawItems, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedCategoryFilter, (_) => _applyFilters());
  }

  /// Returns a Firestore stream based on the provided month key.
  Stream<List<TranItem>> _fetchTransactionsStream(String? monthKey) {
    final monthsRef = _firestore.collection('users').doc(_uid).collection('monthly_transactions');

    // If a month is selected, fetch only its items.
    if (monthKey != null) {
      return monthsRef.doc(monthKey).collection('items').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => TranItem.fromDoc(doc, monthKey: monthKey)).toList());
    }
    
    // Otherwise, fetch items from all months.
    return monthsRef.snapshots().switchMap((monthsSnap) {
      if (monthsSnap.docs.isEmpty) return Stream.value([]);
      final streams = monthsSnap.docs.map((monthDoc) =>
        monthsRef.doc(monthDoc.id).collection('items').snapshots().map((itemSnap) =>
          itemSnap.docs.map((d) => TranItem.fromDoc(d, monthKey: monthDoc.id)).toList()
        )
      ).toList();
      return CombineLatestStream.list(streams).map((lists) => lists.expand((list) => list).toList());
    });
  }

  /// Applies search and category filters to the raw list and updates `filteredItems`.
  void _applyFilters() {
    var items = List<TranItem>.from(_rawItems);

    // Category Filter
    if (selectedCategoryFilter.value != null) {
      final category = selectedCategoryFilter.value!;
      items.retainWhere((item) {
        final itemCategory = item.category.isEmpty ? "Uncategorized" : item.category;
        return itemCategory == category || item.type == category;
      });
    }

    // Search Filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      items.retainWhere((item) =>
          item.category.toLowerCase().contains(query) ||
          item.note.toLowerCase().contains(query) ||
          item.wallet.toLowerCase().contains(query) ||
          item.amount.toString().contains(query));
    }

    filteredItems.assignAll(items);
  }

  // --- PUBLIC API METHODS (for UI interaction) ---

  /// Sets the month filter. Called from the month filter bottom sheet.
  void selectMonth(String? key) {
    if (selectedMonthKey.value == key) return;
    selectedMonthKey.value = key;
    selectedCategoryFilter.value = null; // Reset other filters
  }

  /// Toggles the category filter. Called from the summary chips.
  void toggleCategoryFilter(String category) {
    selectedCategoryFilter.value = (selectedCategoryFilter.value == category) ? null : category;
  }

  /// Toggles the visibility of the search bar.
  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) searchQuery.value = ''; // Clear search on hide
  }

  /// Deletes a transaction from Firestore.
  Future<void> deleteTransaction(TranItem item) async {
    try {
      await _firestore
          .collection('users').doc(_uid)
          .collection('monthly_transactions').doc(item.monthKey)
          .collection('items').doc(item.id)
          .delete();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete transaction: $e");
    }
  }

  /// Animates the scroll view to the top.
  void scrollToTop() {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  // --- PRIVATE HELPERS & LIFECYCLE ---

  void _setupScrollListener() {
    scrollController.addListener(() {
      _scrollStopTimer?.cancel();
      if (scrollController.offset > 300) {
        showScrollToTop.value = true;
        _scrollStopTimer = Timer(const Duration(seconds: 2), () => showScrollToTop.value = false);
      } else {
        showScrollToTop.value = false;
      }
    });
  }

  @override
  void onClose() {
    _transactionSubscription?.cancel();
    _monthKeysSubscription?.cancel();
    _scrollStopTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}

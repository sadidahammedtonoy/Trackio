import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Data/Repository/DataRepository.dart';
import '../Model/tranModel.dart';

class transactionsController extends GetxController {
  final DataRepository _repository = Get.find<DataRepository>();

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
    selectedMonthKey.value = key;
    selectedCategoryFilter.value = null;
    _refreshItems();
  }

  final RxList<TranItem> cachedItems = <TranItem>[].obs;
  StreamSubscription? _hiveSub;

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

    // Listen to Hive changes for real-time UI updates
    _hiveSub = _repository.localDataSource.transactionsBox.watch().listen((event) {
      _refreshItems();
    });

    _refreshItems();
  }

  void _refreshItems() {
    var items = _repository.getAllTransactions();

    // Filter by Month if selected
    if (selectedMonthKey.value != null) {
      items = items.where((item) => item.monthKey == selectedMonthKey.value).toList();
    }

    // Sort by Date
    items.sort((a, b) => b.date.compareTo(a.date));
    
    cachedItems.assignAll(items);
  }

  @override
  void onClose() {
    _hiveSub?.cancel();
    _scrollStopTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  /// ✅ Used in UI to get filtered/searched list
  List<TranItem> getFilteredTransactions() {
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
      items = items.where((item) {
        final categoryMatch = item.category.toLowerCase().contains(searchQuery.value.toLowerCase());
        final remarkMatch = item.note.toLowerCase().contains(searchQuery.value.toLowerCase());
        return categoryMatch || remarkMatch;
      }).toList();
    }

    return items;
  }

  // Get distinct month keys for dropdown
  List<String> getMonthKeys() {
    final keys = _repository.getAllTransactions().map((e) => e.monthKey).toSet().toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  Future<bool> deleteTransaction(TranItem item) async {
    try {
      await _repository.deleteTransaction(item);
      _refreshItems();
      return true;
    } catch (e) {
      debugPrint("❌ Delete failed: $e");
      return false;
    }
  }
}

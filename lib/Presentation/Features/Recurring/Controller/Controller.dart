import 'dart:async';
import 'package:get/get.dart';
import 'package:sadid/Data/Repository/DataRepository.dart';
import 'package:sadid/Presentation/Features/Recurring/Model/recurringModel.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';
import 'package:uuid/uuid.dart';

class RecurringController extends GetxController {
  final DataRepository _repository = Get.find<DataRepository>();

  final RxList<RecurringModel> recurringItems = <RecurringModel>[].obs;
  StreamSubscription? _hiveSub;

  @override
  void onInit() {
    super.onInit();
    _refreshItems();
    // Listen to Hive changes
    _hiveSub = _repository.localDataSource.recurringBox.watch().listen((_) {
      _refreshItems();
    });
    checkAndExecuteRecurring();
  }

  void _refreshItems() {
    recurringItems.assignAll(_repository.getAllRecurring());
  }

  List<RecurringModel> getAllRecurring() {
    return recurringItems;
  }

  Future<void> checkAndExecuteRecurring() async {
    final currentMonthKey = _getMonthKey(DateTime.now());
    final activeRecurring = recurringItems.where((r) => r.isActive).toList();

    for (var recurring in activeRecurring) {
      if (recurring.lastExecutedMonthKey != currentMonthKey) {
        // Execute for this month
        final tranItem = TranItem(
          id: const Uuid().v4(),
          monthKey: currentMonthKey,
          type: recurring.type,
          date: DateTime.now(),
          amount: recurring.amount,
          wallet: recurring.wallet,
          category: recurring.category,
          note: "[Recurring] ${recurring.note}",
          marked: false,
          isSynced: false,
        );

        await _repository.saveTransaction(tranItem);

        // Update last executed key
        final updatedRecurring = recurring.copyWith(lastExecutedMonthKey: currentMonthKey);
        await _repository.saveRecurring(updatedRecurring);
      }
    }
  }

  String _getMonthKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  Future<void> addRecurring(RecurringModel model) async {
    await _repository.saveRecurring(model);
    _refreshItems();
    checkAndExecuteRecurring();
  }

  Future<void> toggleRecurring(RecurringModel model) async {
    await _repository.saveRecurring(model.copyWith(isActive: !model.isActive));
    _refreshItems();
  }

  Future<void> deleteRecurring(String id) async {
    await _repository.deleteRecurring(id);
    _refreshItems();
  }

  @override
  void onClose() {
    _hiveSub?.cancel();
    super.onClose();
  }
}

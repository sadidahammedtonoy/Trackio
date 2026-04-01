import 'package:hive_flutter/hive_flutter.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';
import 'package:sadid/Presentation/Features/Setting/Model/settingsModel.dart';
import 'package:sadid/Presentation/Features/Budget/Model/budgetModel.dart';
import 'package:sadid/Presentation/Features/Recurring/Model/recurringModel.dart';

class LocalDataSource {
  static const String transactionsBoxName = 'transactions';
  static const String settingsBoxName = 'settings';
  static const String budgetsBoxName = 'budgets';
  static const String recurringBoxName = 'recurring';
  static const String categoriesBoxName = 'categories';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TranItemAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AppSettingsAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(BudgetModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(RecurringModelAdapter());
    
    // Open Boxes
    await Hive.openBox<TranItem>(transactionsBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);
    await Hive.openBox<BudgetModel>(budgetsBoxName);
    await Hive.openBox<RecurringModel>(recurringBoxName);
    await Hive.openBox<Map>(categoriesBoxName);
  }

  Box<TranItem> get transactionsBox => Hive.box<TranItem>(transactionsBoxName);
  Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);
  Box<BudgetModel> get budgetsBox => Hive.box<BudgetModel>(budgetsBoxName);
  Box<RecurringModel> get recurringBox => Hive.box<RecurringModel>(recurringBoxName);
  Box<Map> get categoriesBox => Hive.box<Map>(categoriesBoxName);

  // Settings
  Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put('app_settings', settings);
  }

  AppSettings getSettings() {
    return settingsBox.get('app_settings') ?? AppSettings.defaultSettings();
  }

  // Transactions
  Future<void> saveTransaction(TranItem item) async {
    await transactionsBox.put(item.id, item);
  }

  Future<void> saveAllTransactions(List<TranItem> items) async {
    final Map<String, TranItem> itemMap = {for (var item in items) item.id: item};
    await transactionsBox.putAll(itemMap);
  }

  List<TranItem> getAllTransactions() {
    return transactionsBox.values.toList();
  }

  Future<void> deleteTransaction(String id) async {
    await transactionsBox.delete(id);
  }

  List<TranItem> getUnsyncedTransactions() {
    return transactionsBox.values.where((item) => !item.isSynced).toList();
  }

  // Recurring
  Future<void> saveRecurring(RecurringModel model) async {
    await recurringBox.put(model.id, model);
  }

  List<RecurringModel> getAllRecurring() {
    return recurringBox.values.toList();
  }

  Future<void> deleteRecurring(String id) async {
    await recurringBox.delete(id);
  }

  // Categories
  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    await categoriesBox.clear();
    for (var i = 0; i < categories.length; i++) {
      await categoriesBox.put(i, categories[i]);
    }
  }

  List<Map<String, dynamic>> getCategories() {
    return categoriesBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

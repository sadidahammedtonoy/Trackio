import 'package:hive_flutter/hive_flutter.dart';
import '../../Presentation/Features/Transcations/Model/tranModel.dart';
import '../../Presentation/Features/Setting/Model/settingsModel.dart';

class LocalDataSource {
  static const String transactionsBoxName = 'transactions';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TranItemAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    
    await Hive.openBox<TranItem>(transactionsBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);
  }

  Box<TranItem> get transactionsBox => Hive.box<TranItem>(transactionsBoxName);
  Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);

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
}

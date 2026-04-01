import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Presentation/Features/Transcations/Model/tranModel.dart';
import '../../Presentation/Features/Setting/Model/settingsModel.dart';
import '../../Presentation/Features/Budget/Model/budgetModel.dart';
import '../../Presentation/Features/Recurring/Model/recurringModel.dart';
import '../Local/LocalDataSource.dart';
import '../Remote/RemoteDataSource.dart';

class DataRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  DataRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // Settings
  Future<AppSettings> getSettings() async {
    final localSettings = localDataSource.getSettings();
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isNotEmpty && connectivity.first != ConnectivityResult.none) {
      try {
        final remoteSettings = await remoteDataSource.fetchSettings();
        if (remoteSettings != null) {
          if (remoteSettings.updatedAt.isAfter(localSettings.updatedAt)) {
            await localDataSource.saveSettings(remoteSettings);
            return remoteSettings;
          }
        }
      } catch (_) {}
    }
    return localSettings;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await localDataSource.saveSettings(settings);
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isNotEmpty && connectivity.first != ConnectivityResult.none) {
      try {
        await remoteDataSource.saveSettings(settings);
      } catch (_) {}
    }
  }

  // Transactions
  List<TranItem> getAllTransactions() {
    return localDataSource.getAllTransactions();
  }

  Future<void> saveTransaction(TranItem item) async {
    await localDataSource.saveTransaction(item.copyWith(isSynced: false));
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isNotEmpty && connectivity.first != ConnectivityResult.none) {
      try {
        await remoteDataSource.saveTransaction(item);
        await localDataSource.saveTransaction(item.copyWith(isSynced: true));
      } catch (_) {}
    }
  }

  Future<void> deleteTransaction(TranItem item) async {
    await localDataSource.deleteTransaction(item.id);
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isNotEmpty && connectivity.first != ConnectivityResult.none) {
      try {
        await remoteDataSource.deleteTransaction(item.monthKey, item.id);
      } catch (_) {}
    }
  }

  // Categories
  List<Map<String, dynamic>> getCategories() {
    return localDataSource.getCategories();
  }

  Future<void> saveCategory(Map<String, dynamic> category) async {
    final categories = localDataSource.getCategories();
    categories.add(category);
    await localDataSource.saveCategories(categories);
    
    // Sync to remote if online
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isNotEmpty && connectivity.first != ConnectivityResult.none) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('categories')
              .add(category);
        }
      } catch (_) {}
    }
  }

  Future<void> deleteCategory(String categoryId, String name) async {
    final categories = localDataSource.getCategories();
    categories.removeWhere((c) => c['id'] == categoryId || c['name'] == name);
    await localDataSource.saveCategories(categories);

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isNotEmpty && connectivity.first != ConnectivityResult.none) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && categoryId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('categories')
              .doc(categoryId)
              .delete();
        }
      } catch (_) {}
    }
  }

  // Sync Mechanism
  Future<void> syncData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isEmpty || connectivity.first == ConnectivityResult.none) return;

    // 1. Push unsynced Transactions
    final unsynced = localDataSource.getUnsyncedTransactions();
    for (var item in unsynced) {
      try {
        await remoteDataSource.saveTransaction(item);
        await localDataSource.saveTransaction(item.copyWith(isSynced: true));
      } catch (_) {}
    }

    // 2. Full Sync (Simplistic)
    try {
      final remoteItems = await remoteDataSource.fetchAllTransactions();
      if (remoteItems.isNotEmpty) {
        await localDataSource.saveAllTransactions(remoteItems);
      }
      
      // Sync Categories
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .get();
        final remoteCats = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();
        if (remoteCats.isNotEmpty) {
          await localDataSource.saveCategories(remoteCats);
        }
      }
    } catch (_) {}
  }

  // Budgets
  Future<void> saveBudget(BudgetModel budget) async {
    await localDataSource.budgetsBox.put(budget.id, budget);
  }

  List<BudgetModel> getAllBudgets() {
    return localDataSource.budgetsBox.values.toList();
  }

  Future<void> deleteBudget(String id) async {
    await localDataSource.budgetsBox.delete(id);
  }

  // Recurring
  Future<void> saveRecurring(RecurringModel model) async {
    await localDataSource.saveRecurring(model);
  }

  List<RecurringModel> getAllRecurring() {
    return localDataSource.getAllRecurring();
  }

  Future<void> deleteRecurring(String id) async {
    await localDataSource.deleteRecurring(id);
  }
}

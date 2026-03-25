import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Presentation/Features/Transcations/Model/tranModel.dart';
import '../../Presentation/Features/Setting/Model/settingsModel.dart';
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
    // 1. Check local
    final localSettings = localDataSource.getSettings();
    
    // 2. Try fetching remote if online to keep it updated
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      try {
        final remoteSettings = await remoteDataSource.fetchSettings();
        if (remoteSettings != null) {
          // Conflict Handling: Last Write Wins (using updatedAt)
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
    // 1. Save Local First
    await localDataSource.saveSettings(settings);

    // 2. Try Save Remote
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
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
    // 1. Save Local First
    await localDataSource.saveTransaction(item.copyWith(isSynced: false));

    // 2. Try Save Remote
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      try {
        await remoteDataSource.saveTransaction(item);
        await localDataSource.saveTransaction(item.copyWith(isSynced: true));
      } catch (_) {}
    }
  }

  Future<void> deleteTransaction(TranItem item) async {
    // 1. Delete Local First
    await localDataSource.deleteTransaction(item.id);

    // 2. Try Delete Remote
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      try {
        await remoteDataSource.deleteTransaction(item.monthKey, item.id);
      } catch (_) {}
    }
  }

  // Sync Mechanism
  Future<void> syncData() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    // 1. Push unsynced local data to Remote
    final unsynced = localDataSource.getUnsyncedTransactions();
    for (var item in unsynced) {
      try {
        await remoteDataSource.saveTransaction(item);
        await localDataSource.saveTransaction(item.copyWith(isSynced: true));
      } catch (_) {}
    }

    // 2. Pull new data from Remote (Full sync for simplicity in this example)
    try {
      final remoteItems = await remoteDataSource.fetchAllTransactions();
      if (remoteItems.isNotEmpty) {
        await localDataSource.saveAllTransactions(remoteItems);
      }
    } catch (_) {}
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../Repository/DataRepository.dart';

class SyncService extends GetxService {
  final DataRepository repository;
  StreamSubscription? _connectivitySubscription;

  SyncService({required this.repository});

  @override
  void onInit() {
    super.onInit();
    // Listen for connectivity changes (Updated for connectivity_plus 6.x+)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncNow();
      }
    });
  }

  Future<void> syncNow() async {
    try {
      await repository.syncData();
    } catch (e) {
      print("Sync failed: $e");
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}

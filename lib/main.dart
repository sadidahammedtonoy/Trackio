import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'App/app.dart';
import 'firebase_options.dart';
import 'Data/Local/LocalDataSource.dart';
import 'Data/Remote/RemoteDataSource.dart';
import 'Data/Repository/DataRepository.dart';
import 'Data/Sync/SyncService.dart';
import 'Presentation/Features/Recurring/Controller/Controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Database (Hive)
  final localDataSource = LocalDataSource();
  await localDataSource.init();

  // Initialize Data Layer Dependencies
  final remoteDataSource = RemoteDataSource();
  final repository = DataRepository(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );

  // Inject Dependencies using GetX
  Get.put(repository);
  Get.put(SyncService(repository: repository));
  Get.put(RecurringController());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Change to your color
      statusBarIconBrightness: Brightness.light, // For Android (white icons)
      statusBarBrightness: Brightness.dark, // For iOS
    ),
  );

  runApp(const MyApp());
}

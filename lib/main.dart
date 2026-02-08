import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'App/app.dart';
import 'Core/NotificationService.dart';
import 'Core/TrackioReminderManager.dart';
import 'firebase_options.dart';

Future<void> initFirestoreOffline() async {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initFirestoreOffline();

  runApp(const MyApp());
}

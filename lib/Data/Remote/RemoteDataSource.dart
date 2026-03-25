import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Presentation/Features/Transcations/Model/tranModel.dart';
import '../../Presentation/Features/Setting/Model/settingsModel.dart';

class RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // Settings
  Future<AppSettings?> fetchSettings() async {
    if (uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('app')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return AppSettings(
          languageCode: data['languageCode'] ?? 'en',
          countryCode: data['countryCode'] ?? 'US',
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
    } catch (e) {
      print("Error fetching settings: $e");
    }
    return null;
  }

  Future<void> saveSettings(AppSettings settings) async {
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('app')
        .set({
      'languageCode': settings.languageCode,
      'countryCode': settings.countryCode,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Transactions
  Future<List<TranItem>> fetchAllTransactions() async {
    if (uid == null) return [];
    final all = <TranItem>[];
    final monthsSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('monthly_transactions')
        .get();

    for (final monthDoc in monthsSnap.docs) {
      final monthKey = monthDoc.id;
      final itemsSnap = await monthDoc.reference.collection('items').get();
      all.addAll(itemsSnap.docs.map((d) => TranItem.fromDoc(d, monthKey: monthKey)));
    }
    return all;
  }

  Future<void> saveTransaction(TranItem item) async {
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('monthly_transactions')
        .doc(item.monthKey)
        .collection('items')
        .doc(item.id)
        .set(item.toMap(), SetOptions(merge: true));

    // Touch parent doc
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('monthly_transactions')
        .doc(item.monthKey)
        .set({"updatedAt": FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> deleteTransaction(String monthKey, String id) async {
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('monthly_transactions')
        .doc(monthKey)
        .collection('items')
        .doc(id)
        .delete();
  }
}

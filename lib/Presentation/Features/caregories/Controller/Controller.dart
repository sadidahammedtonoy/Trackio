import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/snakbar.dart';

class caregoriesController extends GetxController {
  final categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  CollectionReference<Map<String, dynamic>> _catRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories');
  }

  Future<void> fetchCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await _catRef(user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    categories.value = snap.docs
        .map((d) => {
      "id": d.id,
      ...d.data(),
    })
        .toList();
  }

  Future<void> addCategory(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      AppSnackbar.show("Category name can't be empty".tr);
      return;
    }

    // Optional: duplicate check (case-insensitive)
    final exists = categories.any((c) =>
    (c["name"] ?? "").toString().trim().toLowerCase() ==
        trimmed.toLowerCase());
    if (exists) {
      AppSnackbar.show("Category already exists".tr);
      return;
    }

    await _catRef(user.uid).add({
      "name": trimmed,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await fetchCategories();
  }

  Future<void> editCategory({
    required String categoryId,
    required String newName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      AppSnackbar.show("Category name can't be empty".tr);
      return;
    }

    // Optional: duplicate check (avoid same name for another category)
    final exists = categories.any((c) {
      final id = c["id"]?.toString();
      final name = (c["name"] ?? "").toString().trim().toLowerCase();
      return id != categoryId && name == trimmed.toLowerCase();
    });
    if (exists) {
      AppSnackbar.show("Another category already has this name".tr);
      return;
    }

    await _catRef(user.uid).doc(categoryId).update({
      "name": trimmed,
      // createdAt stays same
    });

    await fetchCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _catRef(user.uid).doc(categoryId).delete();
    await fetchCategories();
  }

}
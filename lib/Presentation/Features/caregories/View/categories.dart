import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/Controller.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons

class categories extends StatelessWidget {
  categories({super.key});
  final controller = Get.find<caregoriesController>();

  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Categories".tr),
          titleSpacing: -10,
        ),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.white,
          onPressed: () => _openAddDialog(),
          child: Icon(Icons.add, color: AppColors.primary,),
        ),
        body: Obx(() {
          final list = controller.categories;
      
          if (list.isEmpty) {
            return Center(
              child: Text("No categories yet".tr),
            );
          }
      
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = list[index];
              final id = item["id"].toString();
              final name = (item["name"] ?? "").toString();
              final createdAtText = _formatCreatedAt(item["createdAt"]);
      
              return Dismissible(
                key: ValueKey(id),
      
                // ✅ BOTH swipe directions allowed
                direction: DismissDirection.horizontal,
      
                // Background for LEFT ➜ RIGHT (Edit)
                background: _swipeBg(
                  color: const Color(0xFF1976D2),
                  icon: Icons.edit,
                  text: "Edit".tr,
                  alignLeft: true,
                ),
      
                // Background for RIGHT ➜ LEFT (Delete)
                secondaryBackground: _swipeBg(
                  color: const Color(0xFFD32F2F),
                  icon: Icons.delete,
                  text: "Delete".tr,
                  alignLeft: false,
                ),
      
                // ✅ Decide what happens before dismiss
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Left ➜ Right = EDIT (do not dismiss)
                    _openEditDialog(categoryId: id, currentName: name);
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    // Right ➜ Left = DELETE (confirm)
                    final ok = await _confirmDelete(name);
                    if (ok == true) {
                      await controller.deleteCategory(id);
                      return true; // remove from list animation
                    }
                    return false;
                  }
                  return false;
                },
      
                child: _categoryTile(
                  name: name,
                  createdAtText: createdAtText,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ---------- UI widgets ----------

  Widget _categoryTile({
    required String name,
    required String createdAtText,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.withOpacity(0.20),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF2F4F7),
                child: HugeIcon(icon: HugeIcons.strokeRoundedFavourite, // Updated icon
                    color: Colors.black87, size: 18), 
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.tr,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Important for dark background
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAtText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required String text,
    required bool alignLeft,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- dialogs ----------

  void _openAddDialog() {
    final tc = TextEditingController();

    if (Platform.isIOS) {
      // 🍎 iOS Dialog
      Get.dialog(
        CupertinoAlertDialog(
          title: Text("Add Category".tr),
          content: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: tc,
                autofocus: true,
                placeholder: "Category name".tr,
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                final name = tc.text.trim();
                Get.back();
                await controller.addCategory(name);
              },
              child: Text("Add".tr),
            ),
          ],
        ),
      );
    } else {
      // 🤖 Android Dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Add Category".tr),
          content: TextField(
            controller: tc,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Category name".tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = tc.text.trim();
                Get.back();
                await controller.addCategory(name);
              },
              child: Text("Add".tr),
            ),
          ],
        ),
      );
    }
  }
  void _openEditDialog({
    required String categoryId,
    required String currentName,
  }) {
    final tc = TextEditingController(text: currentName);

    if (GetPlatform.isIOS) {
      /// 🍎 iOS Style
      Get.dialog(
        CupertinoAlertDialog(
          title: Text("Edit Category".tr),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: tc,
              autofocus: true,
              placeholder: "Category name".tr,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                final newName = tc.text;
                Get.back();
                await controller.editCategory(
                  categoryId: categoryId,
                  newName: newName,
                );
              },
              child: Text("Save".tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      /// 🤖 Android Style
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Edit Category".tr),
          content: TextField(
            controller: tc,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Category name".tr,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel".tr,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = tc.text;
                Get.back();
                await controller.editCategory(
                  categoryId: categoryId,
                  newName: newName,
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text("Save".tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }


  Future<bool?> _confirmDelete(String name) {
    if (GetPlatform.isIOS) {
      /// 🍎 iOS Style
      return Get.dialog<bool>(
        CupertinoAlertDialog(
          title: Text("Delete Category?".tr),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${"Are you sure you want to delete".tr} "$name"?',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              child: Text("No".tr),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Get.back(result: true),
              child: Text("Delete".tr),
            ),
          ],
        ),
      );
    } else {
      /// 🤖 Android Style
      return Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete Category?".tr),
          content: Text(
            '${"Are you sure you want to delete".tr} "$name"?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                "No".tr,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Get.back(result: true),
              child: Text("Delete".tr),
            ),
          ],
        ),
      );
    }
  }


  // ---------- date formatter (simple) ----------
  String _formatCreatedAt(dynamic createdAt) {
    // Firestore serverTimestamp can be null briefly.
    if (createdAt == null) {
      return Get.locale?.languageCode == 'bn'
          ? "এইমাত্র"
          : "Just now";
    }

    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();

      final isBn = Get.locale?.languageCode == 'bn';

      const enMonths = [
        "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
      ];

      const bnMonths = [
        "জানুয়ারি","ফেব্রুয়ারি","মার্চ","এপ্রিল","মে","জুন",
        "জুলাই","আগস্ট","সেপ্টেম্বর","অক্টোবর","নভেম্বর","ডিসেম্বর"
      ];

      String toBnDigits(String input) {
        const map = {
          '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
          '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
        };
        return input.split('').map((c) => map[c] ?? c).join();
      }

      final ddEn = dt.day.toString().padLeft(2, '0');
      final yyyyEn = dt.year.toString();

      final dd = isBn ? toBnDigits(ddEn) : ddEn;
      final yyyy = isBn ? toBnDigits(yyyyEn) : yyyyEn;
      final mm = isBn ? bnMonths[dt.month - 1] : enMonths[dt.month - 1];

      return isBn
          ? "তৈরি: $dd $mm $yyyy"
          : "Created: $dd $mm $yyyy";
    }

    return Get.locale?.languageCode == 'bn'
        ? "তৈরি: —"
        : "Created: —";
  }
}

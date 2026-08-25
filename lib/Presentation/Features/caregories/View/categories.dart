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

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class categories extends StatelessWidget {
  categories({super.key});
  final controller = Get.find<caregoriesController>();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    Widget body = Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeletonLoader(tablet);
      }

      final list = controller.categories;
  
      if (list.isEmpty) {
        return Center(
          child: Text("No categories yet".tr, style: TextStyle(fontSize: tablet ? 16.0 : 14.0)),
        );
      }
  
      return ListView.separated(
        padding: EdgeInsets.all(tablet ? 24.0 : 16.0),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: tablet ? 14.0 : 10.0),
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
              tablet: tablet,
            ),
  
            // Background for RIGHT ➜ LEFT (Delete)
            secondaryBackground: _swipeBg(
              color: const Color(0xFFD32F2F),
              icon: Icons.delete,
              text: "Delete".tr,
              alignLeft: false,
              tablet: tablet,
            ),
  
            // ✅ Decide what happens before dismiss
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Left ➜ Right = EDIT (do not dismiss)
                _openEditDialog(categoryId: id, currentName: name, tablet: tablet);
                return false;
              } else if (direction == DismissDirection.endToStart) {
                // Right ➜ Left = DELETE (confirm)
                final ok = await _confirmDelete(name, tablet: tablet);
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
              tablet: tablet,
              index: index,
            ),
          );
        },
      );
    });

    if (tablet) {
      body = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: body,
        ),
      );
    }

    return background(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Categories".tr, style: tablet ? const TextStyle(fontSize: 18.0) : null),
          titleSpacing: -10,
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          onPressed: () => _openAddDialog(tablet: tablet),
          child: Icon(Icons.add, color: AppColors.primary, size: tablet ? 28.0 : 24.0),
        ),
        body: body,
      ),
    );
  }

  // ---------- UI widgets ----------

  Widget _buildSkeletonLoader(bool tablet) {
    return ListView.separated(
      padding: EdgeInsets.all(tablet ? 24.0 : 16.0),
      itemCount: 8, // Display 8 skeleton items
      separatorBuilder: (_, __) => SizedBox(height: tablet ? 14.0 : 10.0),
      itemBuilder: (context, index) => _skeletonTile(tablet),
    );
  }

  Widget _skeletonTile(bool tablet) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tablet ? 16.0 : 14.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: tablet ? 18.0 : 14.0, vertical: tablet ? 16.0 : 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(tablet ? 16.0 : 14.0),
            border: Border.all(
              color: Colors.grey.withOpacity(0.20),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: tablet ? 22.0 : 18.0,
                backgroundColor: Colors.grey.withOpacity(0.3),
              ),
              SizedBox(width: tablet ? 16.0 : 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: tablet ? 18.0 : 16.0,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: tablet ? 10.0 : 8.0),
                    Container(
                      height: tablet ? 14.0 : 12.0,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
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

  static const List<Color> _iconColors = [
    Color(0xFFFF6F00), // Deep Amber
    Color(0xFFAD1457), // Dark Pink
    Color(0xFF6A1B9A), // Deep Purple
    Color(0xFF00695C), // Dark Teal
    Color(0xFF0277BD), // Steel Blue
    Color(0xFFE65100), // Burnt Orange
    Color(0xFF558B2F), // Olive Green
    Color(0xFF4527A0), // Indigo
    Color(0xFF00838F), // Dark Cyan
    Color(0xFFC62828), // Crimson
    Color(0xFF283593), // Navy Blue
    Color(0xFF6D4C41), // Brown
    Color(0xFF37474F), // Blue Grey
    Color(0xFFAF4448), // Dusty Rose
    Color(0xFF00600F), // Forest
    Color(0xFF1A237E), // Deep Indigo
    Color(0xFF33691E), // Avocado
    Color(0xFF880E4F), // Fuchsia
    Color(0xFFBF360C), // Rust
    Color(0xFF01579B), // Ocean Blue
    Color(0xFF4E342E), // Espresso
    Color(0xFF006064), // Deep Cyan
    Color(0xFF8D6E63), // Warm Taupe
    Color(0xFF546E7A), // Slate
    Color(0xFF7B1FA2), // Violet
    Color(0xFFE91E63), // Hot Pink
    Color(0xFF00897B), // Emerald
    Color(0xFF1565C0), // Cobalt
    Color(0xFFF57F17), // Golden
    Color(0xFF5D4037), // Mocha
  ];

  Widget _categoryTile({
    required String name,
    required String createdAtText,
    required bool tablet,
    required int index,
  }) {
    final iconColor = _iconColors[index % _iconColors.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(tablet ? 16.0 : 14.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: tablet ? 18.0 : 14.0, vertical: tablet ? 16.0 : 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(tablet ? 16.0 : 14.0),
            border: Border.all(
              color: Colors.grey.withOpacity(0.20),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: tablet ? 22.0 : 18.0,
                backgroundColor: iconColor.withValues(alpha: 0.12),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: iconColor,
                  size: tablet ? 22.0 : 18.0
                ),
              ),
              SizedBox(width: tablet ? 16.0 : 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.tr,
                      style: TextStyle(
                        fontSize: tablet ? 16.5 : 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Important for dark background
                      ),
                    ),
                    SizedBox(height: tablet ? 6.0 : 4.0),
                    Text(
                      createdAtText,
                      style: TextStyle(
                        fontSize: tablet ? 13.5 : 12.5,
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
    required bool tablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: tablet ? 24.0 : 18.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(tablet ? 16.0 : 14.0),
      ),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: tablet ? 26.0 : 24.0),
          SizedBox(width: tablet ? 10.0 : 8.0),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: tablet ? 15.0 : 14.0,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- dialogs ----------

  void _openAddDialog({required bool tablet}) {
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
                padding: EdgeInsets.all(tablet ? 14.0 : 12.0),
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
            borderRadius: BorderRadius.circular(tablet ? 20.0 : 16.0),
          ),
          title: Text("Add Category".tr),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tablet ? 400.0 : double.infinity),
            child: TextField(
              controller: tc,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Category name".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    required bool tablet,
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
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tablet ? 400.0 : double.infinity),
            child: TextField(
              controller: tc,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Category name".tr,
              ),
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


  Future<bool?> _confirmDelete(String name, {required bool tablet}) {
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
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tablet ? 400.0 : double.infinity),
            child: Text(
              '${"Are you sure you want to delete".tr} "$name"?',
            ),
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

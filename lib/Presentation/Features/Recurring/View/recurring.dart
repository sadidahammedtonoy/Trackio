import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Core/numberTranslation.dart';
import 'package:uuid/uuid.dart';
import '../Controller/Controller.dart';
import '../Model/recurringModel.dart';
import '../../caregories/Controller/Controller.dart';
import 'package:sadid/Presentation/Share/Background.dart';

class RecurringPage extends StatelessWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RecurringController recurringController = Get.put(RecurringController());
    final catController = Get.find<caregoriesController>();

    return background(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Automation".tr,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28.sp),
            onPressed: () => _showAddRecurringSheet(context, recurringController, catController),
          ),
        ],
      ),
      body: Obx(() {
        final items = recurringController.getAllRecurring();
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_fix_high_rounded, size: 64.sp, color: Colors.grey.withOpacity(0.5)),
                SizedBox(height: 16.h),
                Text("No active automations".tr, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildRecurringTile(context, items[index], recurringController),
        );
      }),
    )
    );
  }

  void _showAddRecurringSheet(BuildContext context, RecurringController recurringController, caregoriesController catController) {
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    final selectedCat = "".obs;
    final selectedFreq = "Monthly".obs;

    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add Recurring Transaction".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),
                  _buildGlassTextField(controller: amountC, label: "Amount".tr, hint: "0.00", icon: Icons.money, keyboardType: TextInputType.number),
                  SizedBox(height: 16.h),
                  _buildGlassTextField(controller: noteC, label: "Note".tr, hint: "E.g. Netflix, Rent", icon: Icons.notes),
                  SizedBox(height: 20.h),
                  Text("Frequency".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                    spacing: 12.w,
                    children: ["Daily", "Weekly", "Monthly"].map((f) => _buildGlassChip(
                      isSelected: selectedFreq.value == f,
                      label: f.tr,
                      onTap: () => selectedFreq.value = f,
                    )).toList(),
                  )),
                  SizedBox(height: 20.h),
                  Text("Category".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: catController.categories.map((c) {
                      final name = c['name'].toString();
                      return _buildGlassChip(
                        isSelected: selectedCat.value == name,
                        label: name.tr,
                        onTap: () => selectedCat.value = name,
                      );
                    }).toList(),
                  )),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (amountC.text.isEmpty || selectedCat.value.isEmpty) return;
                        final recurring = RecurringModel(
                          id: const Uuid().v4(),
                          amount: double.tryParse(amountC.text) ?? 0,
                          category: selectedCat.value,
                          type: "Expense",
                          wallet: "Cash",
                          note: noteC.text,
                          frequency: selectedFreq.value,
                          lastExecutedMonthKey: "",
                        );
                        recurringController.addRecurring(recurring);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.all(16.r), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                      child: Text("Add Automation".tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildRecurringTile(BuildContext context, RecurringModel item, RecurringController recurringController) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: _buildGlassCard(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.repeat_rounded, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.note.isEmpty ? item.category.tr : item.note, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  Text("${item.frequency.tr} • ৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}", style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                ],
              ),
            ),
            Switch(
              value: item.isActive,
              onChanged: (_) => recurringController.toggleRecurring(item),
              activeColor: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await _showDeleteConfirmation(
                  context, 
                  "Delete Automation?".tr, 
                  "Are you sure you want to delete this recurring automation?".tr
                );
                if (confirm) {
                  recurringController.deleteRecurring(item.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String title, String content) async {
    if (GetPlatform.isIOS) {
      return await Get.dialog<bool>(
        CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel".tr),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Get.back(result: true),
              child: Text("Delete".tr),
            ),
          ],
        ),
      ) ?? false;
    } else {
      return await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(content),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text("Delete".tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(padding: padding ?? EdgeInsets.all(16.r), child: child),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black54)),
        SizedBox(height: 8.h),
        _buildGlassCard(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: hint, icon: Icon(icon, size: 20.sp, color: AppColors.primary), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassChip({required bool isSelected, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : Colors.black87)),
      ),
    );
  }
}

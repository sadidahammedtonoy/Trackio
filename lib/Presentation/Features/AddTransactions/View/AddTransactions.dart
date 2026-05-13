import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import 'package:intl/intl.dart';
import '../../../../App/assets_path.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'package:sadid/Core/snakbar.dart'; // Added AppSnackbar import

class addTranscations extends StatelessWidget {
  addTranscations({super.key});
  final addTranscationsController controller = Get.find<addTranscationsController>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController personNameController = TextEditingController();

  Color _getTypeColor(String type) {
    switch (type) {
      case "Expense":
        return Colors.red;
      case "Income":
        return Colors.green;
      case "Lent":
        return Colors.orange;
      case "Borrow":
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case "Expense":
        return Icons.trending_down;
      case "Income":
        return Icons.trending_up;
      case "Lent":
        return Icons.call_made;
      case "Borrow":
        return Icons.call_received;
      default:
        return Icons.category;
    }
  }



  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Add Transaction".tr,
            // style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.sp),
          ),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        "How much?".tr,
                        style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "৳",
                            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 200.w,
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "0",
                                hintStyle: TextStyle(color: Colors.black26),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Type Selector (Horizontal Chips)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Row(
                    children: controller.types.map((type) {
                      final isSelected = controller.selectedType.value == type;
                      final color = _getTypeColor(type);

                      return Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: ChoiceChip(
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) controller.selectedType.value = type;
                          },

                          // ✅ LABEL WITH ICON + TEXT
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(type),
                                size: 16.sp,
                                color: isSelected ? color : Colors.black54,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                type.tr,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? color : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          // ✅ COLORS
                          selectedColor: color.withOpacity(0.15),
                          backgroundColor: Colors.white.withOpacity(0.6),

                          // ✅ BORDER
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: isSelected ? color : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),

                          // ✅ REMOVE DEFAULT CHECK ICON
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  )),
                ),
                SizedBox(height: 20.h),

                // Details Card
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Payment Processed On".tr),
                      _DateButton(controller: controller),
                      const Divider(height: 30),
                      _fieldLabel("Wallet".tr),
                      _WalletSelector(controller: controller),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Category Section
                if (controller.selectedType.value == "Lent" || controller.selectedType.value == "Borrow")
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel("${controller.selectedType.value} Person Name".tr),
                        TextField(
                          controller: personNameController,
                          decoration: InputDecoration(
                            hintText: "Type here..".tr,
                            hintStyle: TextStyle(color: Colors.black26, fontSize: 14.sp),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Obx(() => _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _fieldLabel("Transaction Category".tr),
                            if (controller.selectedCategoryId.value == null || controller.selectedCategoryId.value!.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: HugeIcon(icon: HugeIcons.strokeRoundedBadgeInfo, color: Colors.orange, size: 20.sp),
                              ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        _CategoryPicker(controller: controller),
                      ],
                    ),
                  )),
                SizedBox(height: 20.h),

                // Remark Section
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Remark".tr),
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "You can leave a note here...".tr,
                          hintStyle: TextStyle(color: Colors.black26, fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmission(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 0,
                    ),
                    child: Text(
                      "Add ${controller.selectedType.value}".tr,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.dialog(CalculatorDialog(), barrierDismissible: true),
          backgroundColor: Colors.white.withOpacity(0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          child: Lottie.asset(
            assets_path.calculator,
            height: 30.h,
            repeat: false,
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }

  void _handleSubmission() {
    // Also ensure amount is not empty for any transaction type
    if (amountController.text.trim().isEmpty || (double.tryParse(amountController.text.trim()) ?? 0.0) <= 0) {
      AppSnackbar.show("Please enter a valid amount.".tr);
      return;
    }

    if (controller.selectedType.value == "Lent" || controller.selectedType.value == "Borrow") {
      if (personNameController.text.trim().isEmpty) {
        AppSnackbar.show("Please enter a person name.".tr);
        return; // Prevent submission
      }
      addTranModel model = addTranModel(
        type: controller.selectedType.value,
        date: controller.selectedDate.value,
        amount: amountController.text,
        wallet: controller.selectedWallet.value,
        category: personNameController.text.trim(),
        note: noteController.text.trim(),
      );
      controller.addMonthlyTransaction(model: model);
    } else {
      if (controller.selectedCategoryId.value == null || controller.selectedCategoryId.value!.isEmpty) {
        AppSnackbar.show("Please select a category.".tr);
        return; // Prevent submission
      }
      addTranModel model = addTranModel(
        type: controller.selectedType.value,
        date: controller.selectedDate.value,
        amount: amountController.text,
        wallet: controller.selectedWallet.value,
        category: controller.selectedCategoryId.value!,
        note: noteController.text.trim(),
      );
      controller.addMonthlyTransaction(model: model);
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final addTranscationsController controller;
  const _DateButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (Platform.isIOS) {
          _showIOSDatePicker(context);
        } else {
          _showAndroidDatePicker(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
              DateFormat('dd MMMM, yyyy').format(controller.selectedDate.value),
              style: TextStyle(color: Colors.black87, fontSize: 15.sp, fontWeight: FontWeight.bold),
            )),
            Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _showIOSDatePicker(BuildContext context) {
    DateTime temp = controller.selectedDate.value;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 320,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text("Cancel".tr),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text("Done".tr),
                    onPressed: () {
                      controller.selectedDate.value = temp;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: controller.selectedDate.value,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAndroidDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.selectedDate.value = picked;
  }
}

class _WalletSelector extends StatelessWidget {
  IconData _getWalletIcon(String wallet) {
    switch (wallet) {
      case "Cash":
        return Icons.money;
      case "Mobile Banking":
        return Icons.phone_iphone;
      case "Bank":
        return Icons.account_balance;
      case "Others":
        return Icons.category;
      default:
        return Icons.account_balance_wallet;
    }
  }
  final addTranscationsController controller;
  const _WalletSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
            () => Row(
          children: controller.wallets.map((wallet) {
            final isSelected = controller.selectedWallet.value == wallet;
            final icon = _getWalletIcon(wallet);

            return Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => controller.selectedWallet.value = wallet,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 18.sp,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.black54,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        wallet.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
class _CategoryPicker extends StatelessWidget {
  final addTranscationsController controller;
  const _CategoryPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text("No categories found".tr, style: const TextStyle(color: Colors.black26)),
        );
      }

      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: controller.categories.map((cat) {
          final name = (cat["name"] ?? "").toString();
          final isSelected = controller.selectedCategoryId.value == name;

          return InkWell(
            onTap: () => controller.selectedCategoryId.value = name,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_outlined, size: 16.sp, color: isSelected ? AppColors.primary : Colors.black45),
                  SizedBox(width: 6.w),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected ? AppColors.primary : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

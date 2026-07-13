import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import 'package:intl/intl.dart';
import '../../../../App/assets_path.dart';
import '../../../../Core/snakbar.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class editTransactions extends StatelessWidget {
  final TranItem model;
  editTransactions({super.key, required this.model});

  final controller = Get.find<editTransactionsController>();

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
          title: Text("Edit Transaction".tr),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountSection(),
              SizedBox(height: 20.h),
              _buildTypeSelector(),
              SizedBox(height: 30.h),
              _buildDetailFields(context),
              SizedBox(height: 30.h),
              _buildUpdateButton(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        floatingActionButton: _buildCalculatorButton(),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Center(
      child: Column(
        children: [
          Text(
            "How much?".tr,
            style: TextStyle(fontSize: 16.sp, color: Colors.black54),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
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
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SingleChildScrollView(
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
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(type), size: 16.sp, color: isSelected ? color : Colors.black54),
                      SizedBox(width: 6.w),
                      Text(
                        type.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  selectedColor: color.withOpacity(0.15),
                  backgroundColor: Colors.white.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: isSelected ? color : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildDetailFields(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() {
                  final isLentBorrow = controller.selectedType.value == "Lent" || controller.selectedType.value == "Borrow";
                  return _InfoCard(
                    icon: isLentBorrow ? Icons.person_outline : Icons.category_outlined,
                    label: isLentBorrow ? "Person".tr : "Category".tr,
                    content: isLentBorrow
                        ? TextField(
                            controller: controller.personNameController,
                            decoration: InputDecoration(
                              hintText: "Enter Name".tr,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                            ),
                            style: TextStyle(color: Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            controller.selectedCategoryId.value?.tr ?? "Select".tr,
                            style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: isLentBorrow ? null : () => _showCategoryPicker(context),
                  );
                }),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Obx(() => _InfoCard(
                      icon: HugeIcons.strokeRoundedWallet01,
                      label: "Wallet".tr,
                      content: Text(
                        controller.selectedWallet.value.tr,
                        style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showWalletPicker(context),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => _InfoCard(
              isFullWidth: true,
              icon: HugeIcons.strokeRoundedCalendar01,
              label: "Date".tr,
              content: Text(
                DateFormat('dd MMMM, yyyy').format(controller.selectedDate.value),
                style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              onTap: () => _showDatePicker(context),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.black45),
            )),
        SizedBox(height: 16.h),
        _InfoCard(
          isFullWidth: true,
          icon: HugeIcons.strokeRoundedStickyNote01,
          label: "Remark".tr,
          content: TextField(
            controller: controller.noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Add a note...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 0,
            ),
            child: Text(
              "Update ${controller.selectedType.value}".tr,
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }

  Widget _buildCalculatorButton() {
    return FloatingActionButton(
      onPressed: () => Get.dialog(CalculatorDialog(), barrierDismissible: true),
      backgroundColor: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Lottie.asset(assets_path.calculator, height: 30.h, repeat: false),
    );
  }

  void _handleUpdate() {
    final old = controller.oldItem;
    if (old == null) {
      AppSnackbar.show("No transaction selected".tr);
      return;
    }

    if (controller.amountController.text.trim().isEmpty || (double.tryParse(controller.amountController.text.trim()) ?? 0.0) <= 0) {
      AppSnackbar.show("Please enter a valid amount.".tr);
      return;
    }

    final isLentBorrow = controller.selectedType.value == "Lent" || controller.selectedType.value == "Borrow";

    if (isLentBorrow) {
      if (controller.personNameController.text.trim().isEmpty) {
        AppSnackbar.show("Please enter a person name.".tr);
        return;
      }
    } else {
      if (controller.selectedCategoryId.value == null || controller.selectedCategoryId.value!.isEmpty) {
        AppSnackbar.show("Please select a category.".tr);
        return;
      }
    }

    final updated = TranItem(
      id: old.id,
      monthKey: old.monthKey,
      type: controller.selectedType.value,
      date: controller.selectedDate.value,
      amount: double.parse(controller.amountController.text.trim()),
      wallet: controller.selectedWallet.value,
      category: isLentBorrow ? controller.personNameController.text.trim() : controller.selectedCategoryId.value!,
      note: controller.noteController.text.trim(),
      marked: old.marked,
    );
    controller.editMonthlyTransaction(oldItem: old, updatedItem: updated);
  }

  void _showDatePicker(BuildContext context) {
    if (Platform.isIOS) {
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
                    CupertinoButton(child: Text("Cancel".tr), onPressed: () => Navigator.pop(context)),
                    CupertinoButton(
                        child: Text("Done".tr),
                        onPressed: () {
                          controller.selectedDate.value = temp;
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
              Expanded(child: CupertinoDatePicker(mode: CupertinoDatePickerMode.date, initialDateTime: controller.selectedDate.value, onDateTimeChanged: (d) => temp = d)),
            ],
          ),
        ),
      );
    } else {
      showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ).then((picked) {
        if (picked != null) controller.selectedDate.value = picked;
      });
    }
  }

  void _showWalletPicker(BuildContext context) {
    Get.bottomSheet(
      _PickerSheet(
        title: "Select Wallet".tr,
        items: controller.wallets
            .map((w) => PickerItem(
                  icon: _getWalletIcon(w),
                  label: w.tr,
                  isSelected: controller.selectedWallet.value == w,
                  onTap: () {
                    controller.selectedWallet.value = w;
                    Get.back();
                  },
                ))
            .toList(),
      ),
    );
  }

  dynamic _getWalletIcon(String wallet) {
    switch (wallet) {
      case "Cash":
        return Icons.money_outlined;
      case "Mobile Banking":
        return Icons.phone_android_outlined;
      case "Bank":
        return Icons.account_balance_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  void _showCategoryPicker(BuildContext context) {
    if (controller.categories.isEmpty) {
      AppSnackbar.show("No categories available.".tr);
      return;
    }
    Get.bottomSheet(
      _PickerSheet(
        title: "Select Category".tr,
        items: controller.categories.map((cat) {
          final name = cat["name"] as String;
          return PickerItem(
            icon: Icons.category_outlined, // Generic icon for all categories
            label: name.tr,
            isSelected: controller.selectedCategoryId.value == name,
            onTap: () {
              controller.selectedCategoryId.value = name;
              Get.back();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Widget content;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.content,
    this.onTap,
    this.isFullWidth = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent;
    if (isFullWidth) {
      cardContent = Row(
        children: [
          (icon is IconData) ? Icon(icon, size: 22.sp, color: Colors.black54) : HugeIcon(icon: icon, size: 22.sp, color: Colors.black54),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.black45, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                content,
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
    } else {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (icon is IconData) ? Icon(icon, size: 22.sp, color: Colors.black54) : HugeIcon(icon: icon, size: 22.sp, color: Colors.black54),
          const Spacer(),
          Text(label, style: TextStyle(color: Colors.black45, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          content,
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: EdgeInsets.all(16.r),
        child: cardContent,
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<PickerItem> items;
  const _PickerSheet({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, index) => items[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickerItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PickerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            (icon is IconData)
                ? Icon(icon, size: 20.sp, color: isSelected ? AppColors.primary : Colors.black54)
                : HugeIcon(icon: icon, size: 20.sp, color: isSelected ? AppColors.primary : Colors.black54),
            SizedBox(width: 12.w),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15.sp))),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

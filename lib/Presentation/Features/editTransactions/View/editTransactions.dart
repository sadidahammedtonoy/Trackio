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

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

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
    final tablet = _isTablet(context);

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 24.0 : 20.w, 
        vertical: tablet ? 16.0 : 10.h
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(tablet),
          SizedBox(height: tablet ? 24.0 : 20.h),
          _buildTypeSelector(tablet),
          SizedBox(height: tablet ? 32.0 : 30.h),
          _buildDetailFields(context, tablet),
          SizedBox(height: tablet ? 32.0 : 30.h),
          _buildUpdateButton(tablet),
          SizedBox(height: tablet ? 24.0 : 20.h),
        ],
      ),
    );

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Edit Transaction".tr,
            style: tablet ? const TextStyle(fontSize: 18.0) : null,
          ),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: body,
        floatingActionButton: _buildCalculatorButton(tablet),
      ),
    );
  }

  Widget _buildAmountSection(bool tablet) {
    return Center(
      child: Column(
        children: [
          Text(
            "How much?".tr,
            style: TextStyle(fontSize: tablet ? 16.0 : 16.sp, color: Colors.black54),
          ),
          SizedBox(height: tablet ? 12.0 : 10.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tablet ? 16.0 : 16.w, 
              vertical: tablet ? 8.0 : 8.h
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "৳",
                  style: TextStyle(
                    fontSize: tablet ? 32.0 : 32.sp, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black
                  ),
                ),
                SizedBox(width: tablet ? 10.0 : 10.w),
                SizedBox(
                  width: tablet ? 220.0 : 200.w,
                  child: TextField(
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: tablet ? 48.0 : 48.sp, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.black
                    ),
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

  Widget _buildTypeSelector(bool tablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
            children: controller.types.map((type) {
              final isSelected = controller.selectedType.value == type;
              final color = _getTypeColor(type);
              return Padding(
                padding: EdgeInsets.only(right: tablet ? 12.0 : 10.w),
                child: ChoiceChip(
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) controller.selectedType.value = type;
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(type), 
                        size: tablet ? 16.0 : 16.sp, 
                        color: isSelected ? color : Colors.black54
                      ),
                      SizedBox(width: tablet ? 6.0 : 6.w),
                      Text(
                        type.tr,
                        style: TextStyle(
                          fontSize: tablet ? 14.0 : 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  selectedColor: color.withOpacity(0.15),
                  backgroundColor: Colors.white.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tablet ? 20.0 : 20.r),
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

  Widget _buildDetailFields(BuildContext context, bool tablet) {
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
                    tablet: tablet,
                    icon: isLentBorrow ? Icons.person_outline : Icons.category_outlined,
                    label: isLentBorrow ? "Person".tr : "Category".tr,
                    content: isLentBorrow
                        ? TextField(
                            controller: controller.personNameController,
                            decoration: InputDecoration(
                              hintText: "Enter Name".tr,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: tablet ? 8.0 : 8.h, 
                                horizontal: tablet ? 12.0 : 12.w
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.black87, 
                              fontSize: tablet ? 14.0 : 14.sp, 
                              fontWeight: FontWeight.bold
                            ),
                          )
                        : Text(
                            controller.selectedCategoryId.value?.tr ?? "Select".tr,
                            style: TextStyle(
                              color: Colors.black87, 
                              fontSize: tablet ? 16.0 : 16.sp, 
                              fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: isLentBorrow ? null : () => _showCategoryPicker(context, tablet),
                  );
                }),
              ),
              SizedBox(width: tablet ? 16.0 : 16.w),
              Expanded(
                child: Obx(() => _InfoCard(
                      tablet: tablet,
                      icon: HugeIcons.strokeRoundedWallet01,
                      label: "Wallet".tr,
                      content: Text(
                        controller.selectedWallet.value.tr,
                        style: TextStyle(
                          color: Colors.black87, 
                          fontSize: tablet ? 16.0 : 16.sp, 
                          fontWeight: FontWeight.bold
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showWalletPicker(context, tablet),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: tablet ? 16.0 : 16.h),
        Obx(() => _InfoCard(
              tablet: tablet,
              isFullWidth: true,
              icon: HugeIcons.strokeRoundedCalendar01,
              label: "Date".tr,
              content: Text(
                DateFormat('dd MMMM, yyyy').format(controller.selectedDate.value),
                style: TextStyle(
                  color: Colors.black87, 
                  fontSize: tablet ? 16.0 : 16.sp, 
                  fontWeight: FontWeight.bold
                ),
              ),
              onTap: () => _showDatePicker(context),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded, 
                size: tablet ? 14.0 : 14.sp, 
                color: Colors.black45
              ),
            )),
        SizedBox(height: tablet ? 16.0 : 16.h),
        _InfoCard(
          tablet: tablet,
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
              fontSize: tablet ? 14.0 : 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(bool tablet) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: tablet ? 56.0 : 56.h,
          child: ElevatedButton(
            onPressed: _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tablet ? 16.0 : 16.r)),
              elevation: 0,
            ),
            child: Text(
              "Update ${controller.selectedType.value}".tr,
              style: TextStyle(
                color: Colors.white, 
                fontSize: tablet ? 18.0 : 18.sp, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ));
  }

  Widget _buildCalculatorButton(bool tablet) {
    return FloatingActionButton(
      onPressed: () => Get.dialog(CalculatorDialog(), barrierDismissible: true),
      backgroundColor: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tablet ? 16.0 : 15.r),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Lottie.asset(
        assets_path.calculator, 
        height: tablet ? 32.0 : 30.h, 
        repeat: false
      ),
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _showWalletPicker(BuildContext context, bool tablet) {
    Widget sheet = _PickerSheet(
      title: "Select Wallet".tr,
      tablet: tablet,
      items: controller.wallets
          .map((w) => PickerItem(
                icon: _getWalletIcon(w),
                label: w.tr,
                isSelected: controller.selectedWallet.value == w,
                tablet: tablet,
                onTap: () {
                  controller.selectedWallet.value = w;
                  Get.back();
                },
              ))
          .toList(),
    );

    if (tablet) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: sheet,
            ),
          ),
        )
      );
    } else {
      Get.bottomSheet(sheet);
    }
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

  void _showCategoryPicker(BuildContext context, bool tablet) {
    if (controller.categories.isEmpty) {
      AppSnackbar.show("No categories available.".tr);
      return;
    }
    
    Widget sheet = _PickerSheet(
      title: "Select Category".tr,
      tablet: tablet,
      items: controller.categories.map((cat) {
        final name = cat["name"] as String;
        return PickerItem(
          icon: Icons.category_outlined,
          label: name.tr,
          isSelected: controller.selectedCategoryId.value == name,
          tablet: tablet,
          onTap: () {
            controller.selectedCategoryId.value = name;
            Get.back();
          },
        );
      }).toList(),
    );

    if (tablet) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: sheet,
            ),
          ),
        )
      );
    } else {
      Get.bottomSheet(sheet);
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool tablet;
  const _GlassCard({required this.child, this.padding, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tablet ? 20.0 : 20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? EdgeInsets.all(tablet ? 16.0 : 16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(tablet ? 20.0 : 20.r),
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
  final bool tablet;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.content,
    this.onTap,
    this.isFullWidth = false,
    this.trailing,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent;
    if (isFullWidth) {
      cardContent = Row(
        children: [
          (icon is IconData) 
            ? Icon(icon, size: tablet ? 22.0 : 22.sp, color: Colors.black54) 
            : HugeIcon(icon: icon, size: tablet ? 22.0 : 22.sp, color: Colors.black54),
          SizedBox(width: tablet ? 16.0 : 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: TextStyle(
                    color: Colors.black45, 
                    fontSize: tablet ? 12.0 : 12.sp, 
                    fontWeight: FontWeight.w600
                  )
                ),
                SizedBox(height: tablet ? 4.0 : 4.h),
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
          (icon is IconData) 
            ? Icon(icon, size: tablet ? 22.0 : 22.sp, color: Colors.black54) 
            : HugeIcon(icon: icon, size: tablet ? 22.0 : 22.sp, color: Colors.black54),
          const Spacer(),
          Text(
            label, 
            style: TextStyle(
              color: Colors.black45, 
              fontSize: tablet ? 12.0 : 12.sp, 
              fontWeight: FontWeight.w600
            )
          ),
          SizedBox(height: tablet ? 4.0 : 4.h),
          content,
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        tablet: tablet,
        padding: EdgeInsets.all(tablet ? 16.0 : 16.r),
        child: cardContent,
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<PickerItem> items;
  final bool tablet;
  const _PickerSheet({required this.title, required this.items, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: tablet ? 16.0 : 16.h, 
          horizontal: tablet ? 12.0 : 12.w
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: tablet 
            ? BorderRadius.circular(24.0) 
            : BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: tablet ? 18.0 : 18.sp, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87
              )
            ),
            SizedBox(height: tablet ? 16.0 : 16.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: tablet ? 8.0 : 8.h),
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
  final bool tablet;

  const PickerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tablet ? 16.0 : 16.w, 
          vertical: tablet ? 12.0 : 12.h
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r),
        ),
        child: Row(
          children: [
            (icon is IconData)
                ? Icon(icon, size: tablet ? 20.0 : 20.sp, color: isSelected ? AppColors.primary : Colors.black54)
                : HugeIcon(icon: icon, size: tablet ? 20.0 : 20.sp, color: isSelected ? AppColors.primary : Colors.black54),
            SizedBox(width: tablet ? 12.0 : 12.w),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: tablet ? 15.0 : 15.sp))),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: tablet ? 20.0 : 20.sp),
          ],
        ),
      ),
    );
  }
}

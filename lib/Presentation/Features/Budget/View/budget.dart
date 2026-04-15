import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Core/numberTranslation.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import 'package:sadid/Presentation/Features/Recurring/Model/recurringModel.dart';
import 'package:uuid/uuid.dart';
import '../Controller/Controller.dart';
import '../Model/budgetModel.dart';

class InsightsPage extends StatelessWidget {
  InsightsPage({super.key});

  final controller = Get.put(InsightsController());

  @override
  Widget build(BuildContext context) {
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
          title: Obx(() => Text(
            numberTranslation.formatMonthYearBnFromKey(controller.selectedMonthKey.value),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          )),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 24.sp),
              onPressed: () => _showMonthFilterSheet(context),
            ),
            IconButton(
              icon: Icon(Icons.auto_fix_high_rounded, color: AppColors.primary, size: 24.sp),
              onPressed: () => _showRecurringListSheet(context),
            ),
            IconButton(
              icon: Icon(Icons.add_task_rounded, color: AppColors.primary, size: 26.sp),
              onPressed: () => _showAddBudgetSheet(context),
            ),
          ],
        ),
        body: Obx(() {
          return _buildBudgetSection(context);
        }),
      ),
    );
  }

  Widget _buildBudgetSection(BuildContext context) {
    final items = controller.budgetStatuses;
    
    // If no budgets are set for this month, show empty state
    if (items.isEmpty) return _buildEmptyState(context);

    final totalLimit = items.fold(0.0, (sum, i) => sum + i.limit);
    final totalSpent = items.fold(0.0, (sum, i) => sum + i.spent);
    final totalPercent = totalLimit > 0 ? (totalSpent / totalLimit) : 0.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
      children: [
        _buildSummaryCard(totalLimit, totalSpent, totalPercent),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Category Limits".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              "${items.length} ${"Budgets".tr}",
              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...items.map((item) => _buildBudgetCard(context, item)),
      ],
    );
  }

  Widget _buildSummaryCard(double limit, double spent, double percent) {
    final isOver = percent > 1.0;
    // Color logic: < 80% Green, 80-100% Orange, > 100% Red
    final color = percent > 1.0 ? Colors.red : percent >= 0.8 ? Colors.orange : Colors.green;

    return _GlassCard(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: "Budgeted Limit".tr, value: "৳${numberTranslation.toBnDigits(limit.toStringAsFixed(0))}", color: Colors.black87),
              _StatItem(label: "Budgeted Spent".tr, value: "৳${numberTranslation.toBnDigits(spent.toStringAsFixed(0))}", color: color),
            ],
          ),
          SizedBox(height: 20.h),
          Stack(
            children: [
              Container(
                height: 12.h,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10.r)),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(percent * 100).toStringAsFixed(1)}% ${"used".tr}",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color),
              ),
              if (limit > 0)
                Text(
                  isOver 
                    ? "${"Over by".tr} ৳${numberTranslation.toBnDigits((spent - limit).toStringAsFixed(0))}"
                    : "${"Left:".tr} ৳${numberTranslation.toBnDigits((limit - spent).toStringAsFixed(0))}",
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isOver ? Colors.red : Colors.black54),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetStatus item) {
    // Color logic: < 80% Green, 80-100% Orange, > 100% Red
    final color = item.percentage > 1.0 ? Colors.red : item.percentage >= 0.8 ? Colors.orange : Colors.green;
    final remaining = item.limit - item.spent;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: _GlassCard(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.category.tr, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                Text("৳${numberTranslation.toBnDigits(item.spent.toStringAsFixed(0))} / ৳${numberTranslation.toBnDigits(item.limit.toStringAsFixed(0))}", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(item.percentage * 100).toStringAsFixed(0)}% ${"completed".tr}",
                  style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                ),
                if (item.limit > 0)
                  Text(
                    remaining >= 0 
                      ? "৳${numberTranslation.toBnDigits(remaining.toStringAsFixed(0))} ${"left".tr}"
                      : "${"Exceeded by".tr} ৳${numberTranslation.toBnDigits(remaining.abs().toStringAsFixed(0))}",
                    style: TextStyle(fontSize: 11.sp, color: remaining >= 0 ? Colors.black45 : Colors.red),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: item.percentage.clamp(0.0, 1.0), 
                backgroundColor: Colors.black.withOpacity(0.05), 
                valueColor: AlwaysStoppedAnimation<Color>(color), 
                minHeight: 6.h
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.edit_outlined, size: 18.sp, color: Colors.blueGrey),
                  onPressed: () => _showAddBudgetSheet(context, initialCategory: item.category, initialAmount: item.limit),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.delete_outline_rounded, size: 18.sp, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await _showDeleteConfirmation(context, "Delete Budget?".tr, "Are you sure you want to delete this category budget?".tr);
                    if (confirm == true) {
                      final b = controller.budgets.firstWhereOrNull((b) => b.category == item.category);
                      if (b != null) controller.deleteBudget(b.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80.sp, color: Colors.grey.withOpacity(0.3)),
          SizedBox(height: 20.h),
          Text("No budgets set for this month".tr, style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: () => _showAddBudgetSheet(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            child: Text("Set Your First Budget".tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, {String? initialCategory, double? initialAmount}) {
    if (initialCategory != null) {
      controller.selectedCategory.value = initialCategory;
      controller.amountC.text = initialAmount?.toStringAsFixed(0) ?? "";
      controller.budgetMonthKey.value = controller.selectedMonthKey.value;
    } else {
      controller.amountC.clear();
      controller.selectedCategory.value = "";
      controller.budgetMonthKey.value = controller.selectedMonthKey.value;
    }

    final now = DateTime.now();
    final months = List.generate(12, (index) => DateTime(now.year, now.month - 6 + index, 1));

    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Set Category Budget".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),
                  Text("Budget Month".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black54)),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 45.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final m = months[index];
                        final mKey = "${m.year}-${m.month.toString().padLeft(2, '0')}";
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Obx(() => _GlassChip(
                            isSelected: controller.budgetMonthKey.value == mKey,
                            label: numberTranslation.formatMonthYearBnFromKey(mKey),
                            onTap: () => controller.budgetMonthKey.value = mKey,
                          )),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _GlassTextField(controller: controller.amountC, label: "Monthly Limit".tr, hint: "0.00".tr, icon: Icons.money_rounded, keyboardType: TextInputType.number),
                  SizedBox(height: 20.h),
                  Text("Select Category".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black54)),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: controller.categories.map((c) {
                      final name = c['name'].toString();
                      return _GlassChip(isSelected: controller.selectedCategory.value == name, label: name.tr, onTap: () => controller.selectedCategory.value = name);
                    }).toList(),
                  )),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.addOrUpdateBudget,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.all(16.r), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                      child: Text("Save Budget".tr, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
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

  void _showRecurringListSheet(BuildContext context) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 600.h,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recurring Transactions".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    IconButton(icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primary), onPressed: () => _showAddRecurringSheet(context)),
                  ],
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: Obx(() {
                    if (controller.recurringItems.isEmpty) return Center(child: Text("No recurring items".tr, style: const TextStyle(color: Colors.grey)));
                    return ListView.builder(
                      itemCount: controller.recurringItems.length,
                      itemBuilder: (context, index) => _buildRecurringTile(context, controller.recurringItems[index]),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddRecurringSheet(BuildContext context) {
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
                  Text("Add Recurring".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),
                  _GlassTextField(controller: amountC, label: "Amount".tr, hint: "0.00", icon: Icons.money, keyboardType: TextInputType.number),
                  SizedBox(height: 16.h),
                  _GlassTextField(controller: noteC, label: "Note".tr, hint: "E.g. Netflix, Rent", icon: Icons.notes),
                  SizedBox(height: 20.h),
                  Text("Frequency".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                    spacing: 12.w,
                    children: ["Daily", "Weekly", "Monthly"].map((f) => _GlassChip(isSelected: selectedFreq.value == f, label: f.tr, onTap: () => selectedFreq.value = f)).toList(),
                  )),
                  SizedBox(height: 20.h),
                  Text("Category".tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: controller.categories.map((c) {
                      final name = c['name'].toString();
                      return _GlassChip(isSelected: selectedCat.value == name, label: name.tr, onTap: () => selectedCat.value = name);
                    }).toList(),
                  )),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (amountC.text.isEmpty || selectedCat.value.isEmpty) return;
                        controller.addRecurring(RecurringModel(
                          id: const Uuid().v4(),
                          amount: double.tryParse(amountC.text) ?? 0,
                          category: selectedCat.value,
                          type: "Expense",
                          wallet: "Cash",
                          note: noteC.text,
                          frequency: selectedFreq.value,
                          lastExecutedMonthKey: "",
                        ));
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

  Widget _buildRecurringTile(BuildContext context, RecurringModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: _GlassCard(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.note.isEmpty ? item.category.tr : item.note, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  Text("${item.frequency.tr} • ৳${item.amount.toStringAsFixed(0)}", style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                ],
              ),
            ),
            Switch(value: item.isActive, onChanged: (_) => controller.toggleRecurring(item), activeColor: AppColors.primary),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () async {
              final confirm = await _showDeleteConfirmation(context, "Delete Automation?".tr, "Are you sure?".tr);
              if (confirm == true) controller.deleteRecurring(item.id);
            }),
          ],
        ),
      ),
    );
  }

  void _showMonthFilterSheet(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(12, (index) => DateTime(now.year, now.month - index, 1));
    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Month".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final m = months[index];
                      final mKey = "${m.year}-${m.month.toString().padLeft(2, '0')}";
                      return Obx(() {
                        final isSel = controller.selectedMonthKey.value == mKey;
                        return ListTile(
                          title: Text(numberTranslation.formatMonthYearBnFromKey(mKey), style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? AppColors.primary : Colors.black87)),
                          trailing: isSel ? Icon(Icons.check_circle, color: AppColors.primary) : null,
                          onTap: () { controller.setMonth(m); Get.back(); },
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String title, String content) async {
    return await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54))),
          TextButton(onPressed: () => Get.back(result: true), child: Text("Delete".tr, style: const TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black54, fontWeight: FontWeight.w600)),
      SizedBox(height: 4.h),
      Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: color)),
    ]);
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  const _GlassCard({required this.child, this.padding, this.borderRadius, this.borderColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: Padding(padding: padding ?? EdgeInsets.all(16.r), child: child)),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  const _GlassTextField({required this.controller, required this.label, required this.hint, required this.icon, this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black54)),
      SizedBox(height: 8.h),
      _GlassCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        borderRadius: BorderRadius.circular(14.r),
        child: TextField(controller: controller, keyboardType: keyboardType, style: const TextStyle(fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: hint, icon: Icon(icon, size: 20.sp, color: AppColors.primary), border: InputBorder.none)),
      ),
    ]);
  }
}

class _GlassChip extends StatelessWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onTap;
  const _GlassChip({required this.isSelected, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        borderRadius: BorderRadius.circular(12.r),
        borderColor: isSelected ? AppColors.primary : Colors.transparent,
        child: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : Colors.black87)),
      ),
    );
  }
}

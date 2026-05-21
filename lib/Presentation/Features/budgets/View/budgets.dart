import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import 'package:sadid/Presentation/Share/glass_card.dart';
import '../Controller/controller.dart';
import '../Model/budget_model.dart';
import 'package:flutter/foundation.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BudgetsController controller = Get.put(BudgetsController());

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Budgets'.tr),
          titleSpacing: -10.w,
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(routes.add_budget_screen);
              },
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedAddCircleHalfDot),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              _buildHistogram(controller),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    DateFormat('MMMM yyyy').format(controller.selectedMonth.value),
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.7)),
                  )),
                  IconButton(
                    onPressed: () => controller.selectMonth(context),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedSortByDown01),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Obx(() {
                  if (controller.budgets.isEmpty) {
                    return Center(child: Text("No budgets added for this month.".tr));
                  }
                  return ListView.builder(
                    itemCount: controller.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = controller.budgets[index];
                      return _buildBudgetCard(context, controller, budget);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, BudgetsController controller, BudgetModel budget) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text('Delete Budget'.tr),
            content: Text('Are you sure you want to delete this budget?'.tr),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Get.back(),
                child: Text('Cancel'.tr),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  controller.deleteBudget(budget.id);
                  Get.back();
                },
                isDestructiveAction: true,
                child: Text('Delete'.tr),
              ),
            ],
          );
        },
      );
    } else {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete Budget".tr),
          content: Text("Are you sure you want to delete this budget?".tr),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () {
                controller.deleteBudget(budget.id);
                Get.back();
              },
              child: Text("Delete".tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }


  Widget _buildBudgetCard(BuildContext context, BudgetsController controller, BudgetModel budget) {
    final percentage = budget.budget > 0 ? (budget.spent / budget.budget) : 0.0;
    final color = budget.spent > budget.budget
        ? Colors.red
        : (percentage >= 0.8 ? Colors.orange : AppColors.primary);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GlassCard(
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 40.r,
              lineWidth: 8.0,
              percent: percentage > 1.0 ? 1.0 : percentage,
              center: Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              progressColor: color,
              backgroundColor: AppColors.primary.withOpacity(0.1), // Brighter background
              circularStrokeCap: CircularStrokeCap.round,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(budget.groupName,
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (budget.isGrouped)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        budget.categories.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Text('Budget: ৳${budget.budget.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  SizedBox(height: 4.h),
                  Text('Spent: ৳${budget.spent.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14.sp, color: color)),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            PopupMenuButton<String>(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoreVerticalCircle01),
              onSelected: (value) {
                if (value == 'edit') {
                  Get.toNamed(routes.add_budget_screen, arguments: {'budgetId': budget.id, 'category': budget.groupName, 'amount': budget.budget});
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, controller, budget);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: const HugeIcon(icon: HugeIcons.strokeRoundedAiEditing, color: Colors.blue),
                    title: Text('Edit'.tr, style: TextStyle(color: Colors.blue),),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: const HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: Colors.red),
                    title: Text('Delete'.tr, style: TextStyle(color: Colors.red),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistogram(BudgetsController controller) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Budget'.tr,
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.black54)),
                  Obx(() => Text('৳ ${controller.totalBudget.value.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Spent'.tr,
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.black54)),
                  Obx(() {
                    final spent = controller.totalSpent.value;
                    final budget = controller.totalBudget.value;
                    final percentage = budget > 0 ? (spent / budget) * 100 : 0;
                    final color = spent > budget
                        ? Colors.red
                        : (percentage >= 80 ? Colors.orange : Colors.green);
                    return Row(
                      children: [
                        Text('৳ ${spent.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(width: 8.w),
                        Text(
                            '(${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: color)),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final spent = controller.totalSpent.value;
            final budget = controller.totalBudget.value;
            final progress = budget > 0 ? (spent / budget) : 0.0;
            final percentage = progress * 100;
            final color = spent > budget
                ? Colors.red
                : (percentage >= 80 ? Colors.orange : AppColors.primary);
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10.h,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          }),
        ],
      ),
    );
  }
}

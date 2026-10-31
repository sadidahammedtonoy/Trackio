import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BudgetsController controller = Get.put(BudgetsController());
    final tablet = _isTablet(context);

    Widget body = Padding(
      padding: EdgeInsets.symmetric(horizontal: tablet ? 16.0 : 16.w),
      child: Column(
        children: [
          SizedBox(height: tablet ? 12.0 : 10.h),
          _buildHistogram(controller, tablet),
          SizedBox(height: tablet ? 16.0 : 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                DateFormat('MMMM yyyy').format(controller.selectedMonth.value),
                style: TextStyle(
                  fontSize: tablet ? 18.0 : 18.sp, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black.withOpacity(0.7)
                ),
              )),
              IconButton(
                onPressed: () => controller.selectMonth(context),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSortByDown01,
                  size: tablet ? 24.0 : 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: tablet ? 20.0 : 20.h),
          Expanded(
            child: Obx(() {
              if (controller.budgets.isEmpty) {
                return Center(child: Text("No budgets added for this month.".tr));
              }
              return ListView.builder(
                itemCount: controller.budgets.length,
                itemBuilder: (context, index) {
                  final budget = controller.budgets[index];
                  return _buildBudgetCard(context, controller, budget, tablet);
                },
              );
            }),
          ),
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
            'Budgets'.tr,
            style: tablet ? const TextStyle(fontSize: 18.0) : null,
          ),
          titleSpacing: tablet ? -10.0 : -10.w,
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(routes.add_budget_screen);
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedAddCircleHalfDot,
                size: tablet ? 24.0 : 24.sp,
              ),
            ),
          ],
        ),
        body: body,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, BudgetsController controller, BudgetModel budget, bool tablet) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tablet ? 12.0 : 12.r)),
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


  Widget _buildBudgetCard(BuildContext context, BudgetsController controller, BudgetModel budget, bool tablet) {
    final percentage = budget.budget > 0 ? (budget.spent / budget.budget) : 0.0;
    final color = budget.spent > budget.budget
        ? Colors.red
        : (percentage >= 0.8 ? Colors.orange : AppColors.primary);

    return Padding(
      padding: EdgeInsets.only(bottom: tablet ? 16.0 : 16.h),
      child: Slidable(
        key: ValueKey(budget.id),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                Get.toNamed(routes.add_budget_screen, arguments: {'budgetId': budget.id, 'category': budget.groupName, 'amount': budget.budget});
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit'.tr,
              borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          dismissible: DismissiblePane(onDismissed: () {
             _showDeleteConfirmationDialog(context, controller, budget, tablet);
          }),
          children: [
            SlidableAction(
              onPressed: (_) {
                _showDeleteConfirmationDialog(context, controller, budget, tablet);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete'.tr,
              borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
            ),
          ],
        ),
        child: GlassCard(
          padding: EdgeInsets.all(tablet ? 16.0 : 16.r),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: tablet ? 36.0 : 40.r,
                lineWidth: tablet ? 6.0 : 8.0,
                percent: percentage > 1.0 ? 1.0 : percentage,
                center: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: tablet ? 14.0 : 16.sp, fontWeight: FontWeight.bold),
                ),
                progressColor: color,
                backgroundColor: AppColors.primary.withOpacity(0.1), 
                circularStrokeCap: CircularStrokeCap.round,
              ),
              SizedBox(width: tablet ? 16.0 : 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.groupName,
                        style: TextStyle(
                            fontSize: tablet ? 16.0 : 18.sp, fontWeight: FontWeight.bold)),
                    if (budget.isGrouped)
                      Padding(
                        padding: EdgeInsets.only(top: tablet ? 4.0 : 4.h),
                        child: Text(
                          budget.categories.join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: tablet ? 11.0 : 12.sp, color: Colors.black54),
                        ),
                      ),
                    SizedBox(height: tablet ? 6.0 : 8.h),
                    Text('Budget: ৳${budget.budget.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: tablet ? 13.0 : 14.sp, color: Colors.grey[600])),
                    SizedBox(height: tablet ? 2.0 : 4.h),
                    Text('Spent: ৳${budget.spent.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: tablet ? 13.0 : 14.sp, color: color)),
                  ],
                ),
              ),
              SizedBox(width: tablet ? 8.0 : 8.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistogram(BudgetsController controller, bool tablet) {
    return GlassCard(
      padding: EdgeInsets.all(tablet ? 20.0 : 16.r),
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
                          fontSize: tablet ? 14.0 : 14.sp, color: Colors.black54)),
                  Obx(() => Text('৳ ${controller.totalBudget.value.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: tablet ? 24.0 : 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Spent'.tr,
                      style: TextStyle(
                          fontSize: tablet ? 14.0 : 14.sp, color: Colors.black54)),
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
                                fontSize: tablet ? 18.0 : 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(width: tablet ? 6.0 : 8.w),
                        Text(
                            '(${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                                fontSize: tablet ? 14.0 : 14.sp,
                                fontWeight: FontWeight.bold,
                                color: color)),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
          SizedBox(height: tablet ? 16.0 : 16.h),
          Obx(() {
            final spent = controller.totalSpent.value;
            final budget = controller.totalBudget.value;
            final progress = budget > 0 ? (spent / budget) : 0.0;
            final percentage = progress * 100;
            final color = spent > budget
                ? Colors.red
                : (percentage >= 80 ? Colors.orange : AppColors.primary);
            return ClipRRect(
              borderRadius: BorderRadius.circular(tablet ? 8.0 : 10.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: tablet ? 8.0 : 10.h,
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

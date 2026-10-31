import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Core/numberTranslation.dart';
import '../../../../App/AppColors.dart';
import '../../../../Core/snakbar.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:collection/collection.dart';

import '../Controller/Controller.dart';
import '../Model/savingHistoryModel.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class AllSavingsListWidget extends StatefulWidget {
  const AllSavingsListWidget({
    super.key,
    this.uid,
    this.limit,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.emptyText = "No savings yet.",
    this.enableSwipeActions = true,
  });

  final String? uid;
  final int? limit;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final String emptyText;
  final bool enableSwipeActions;

  @override
  State<AllSavingsListWidget> createState() => _AllSavingsListWidgetState();
}

class _AllSavingsListWidgetState extends State<AllSavingsListWidget> {
  List<SavingItem> _cache = const [];

  CollectionReference<Map<String, dynamic>> _listRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savings')
        .doc('items')
        .collection('list');
  }

  Query<Map<String, dynamic>> _query(String uid) {
    Query<Map<String, dynamic>> q =
    _listRef(uid).orderBy("date", descending: true);
    if (widget.limit != null) q = q.limit(widget.limit!);
    return q;
  }

  String _friendlyError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case "permission-denied":
          return "You don't have permission to do this.".tr;
        case "unauthenticated":
          return "Please login and try again.".tr;
        case "unavailable":
          return "No internet connection. Please try again.".tr;
        default:
          return e.message ?? "Something went wrong. Please try again.".tr;
      }
    }
    return "Something went wrong. Please try again.".tr;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
     final res = await showCupertinoDialog<bool>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Delete saving?".tr),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("This item will be deleted permanently.".tr),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel".tr),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete".tr),
            ),
          ],
        ),
      );
      return res ?? false;
  }

  void _toast(BuildContext context, String msg) {
    AppSnackbar.show(msg);
  }

  Future<bool> _handleDelete({
    required BuildContext context,
    required String uid,
    required SavingItem item,
  }) async {
    final ok = await _confirmDelete(context);
    if (!ok) return false;

    try {
      await _listRef(uid).doc(item.id).delete();
      _toast(context, "Deleted".tr);
      return true;
    } catch (e) {
      _toast(context, _friendlyError(e));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
    final tablet = _isTablet(context);

    if (uid == null) {
      return _ErrorBox(message: "Please login to view savings.".tr, tablet: tablet);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query(uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && _cache.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snap.hasError && _cache.isEmpty) {
          return _ErrorBox(message: _friendlyError(snap.error!), tablet: tablet);
        }

        if (snap.hasData) {
          _cache = snap.data!.docs.map((d) => SavingItem.fromDoc(d)).toList();
        }

        final list = _cache;

        if (list.isEmpty) {
          return Center(
            child: Text(
              widget.emptyText.tr,
              style: TextStyle(color: Colors.black.withOpacity(0.5)),
            ),
          );
        }

        final groupedData = groupBy(list, (SavingItem item) {
          return DateFormat('yyyy-MM-dd').format(item.date);
        });

        final sortedKeys = groupedData.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return Column(
          children: [
             _TotalSavingsHeader(tablet: tablet),
             SizedBox(height: tablet ? 10.0 : 10.h),
            ListView.builder(
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics,
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final dateKey = sortedKeys[index];
                final itemsOnDate = groupedData[dateKey]!;
                final date = itemsOnDate.first.date;
                
                return _DateGroup(
                  date: date,
                  items: itemsOnDate,
                  onDelete: (item) => _handleDelete(context: context, uid: uid, item: item),
                  onEdit: (item) => Get.find<savingController>().openEditSavingSheet(context, item),
                  enableSwipeActions: widget.enableSwipeActions,
                  tablet: tablet,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _TotalSavingsHeader extends StatelessWidget {
  final bool tablet;
  const _TotalSavingsHeader({this.tablet = false});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      tablet: tablet,
      child: StreamBuilder<String>(
        stream: Get.find<savingController>().streamTotalSavingsText(),
        builder: (context, snapshot) {
          final totalText = snapshot.data ?? "0";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: double.infinity),
              Text(
                "Total Savings in History".tr,
                style: TextStyle(
                  fontSize: tablet ? 13.0 : 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Text(
                "৳${numberTranslation.toBnDigits(totalText)}",
                style: TextStyle(
                  fontSize: tablet ? 24.0 : 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<SavingItem> items;
  final bool enableSwipeActions;
  final Function(SavingItem) onEdit;
  final Future<bool> Function(SavingItem) onDelete;
  final bool tablet;

  const _DateGroup({
    required this.date,
    required this.items,
    required this.onDelete,
    required this.onEdit,
    required this.enableSwipeActions,
    this.tablet = false,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return "Today".tr;
    } else if (dateToCompare == yesterday) {
      return "Yesterday".tr;
    } else {
      return DateFormat('dd MMM, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyTotal = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tablet ? 8.0 : 8.w, 
            vertical: tablet ? 12.0 : 12.h
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: tablet ? 16.0 : 16.sp,
                  color: Colors.black87,
                ),
              ),
              Text(
                "৳${numberTranslation.toBnDigits(dailyTotal.toStringAsFixed(0))}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: tablet ? 14.0 : 14.sp,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        _GlassCard(
          tablet: tablet,
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1, 
              color: Colors.grey.withOpacity(0.1), 
              indent: tablet ? 16.0 : 16.w, 
              endIndent: tablet ? 16.0 : 16.w
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final historyItem = _TimelineSavingItem(item: item, tablet: tablet);

               if (!enableSwipeActions) return historyItem;

                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r)
                    ),
                     child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.edit_outlined, color: Colors.blue),
                        SizedBox(width: tablet ? 8.0 : 8.w),
                        Text(
                          "Edit".tr,
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Delete".tr,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: tablet ? 8.0 : 8.w),
                        const Icon(Icons.delete_outline, color: Colors.red),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // This is the delete swipe
                      return await onDelete(item);
                    } else if (direction == DismissDirection.startToEnd) {
                      // This is the edit swipe
                      onEdit(item);
                      return false; // Do not dismiss the item
                    }
                    return false;
                  },
                  child: historyItem,
                );
            },
          ),
        ),
        SizedBox(height: tablet ? 20.0 : 20.h),
      ],
    );
  }
}
class _TimelineSavingItem extends StatelessWidget {
  final SavingItem item;
  final bool tablet;
  const _TimelineSavingItem({required this.item, this.tablet = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 16.0 : 16.w, 
        vertical: tablet ? 12.0 : 12.h
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.source.isEmpty ? "Saving".tr : item.source.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: tablet ? 15.0 : 15.sp, 
                    color: Colors.black87
                  ),
                ),
              ),
              SizedBox(width: tablet ? 8.0 : 8.w),
              Text(
                "+৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: tablet ? 15.0 : 15.sp,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: tablet ? 4.0 : 4.h),
          Text(
            item.wallet.tr,
            style: TextStyle(color: Colors.black54, fontSize: tablet ? 12.0 : 11.sp),
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            SizedBox(height: tablet ? 6.0 : 6.h),
            Text(
              item.note!,
              style: TextStyle(
                fontSize: tablet ? 13.0 : 12.sp,
                color: Colors.black.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final bool tablet;
  const _ErrorBox({required this.message, this.tablet = false});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      tablet: tablet,
      padding: EdgeInsets.all(tablet ? 14.0 : 14.r),
      borderColor: Colors.red.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: tablet ? 10.0 : 10.w),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final bool tablet;

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.tablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(tablet ? 16.0 : 20.r),
        border: Border.all(color: borderColor ?? Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(tablet ? 16.0 : 20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? EdgeInsets.all(tablet ? 16.0 : 16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}
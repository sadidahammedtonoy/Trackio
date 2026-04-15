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

import '../Controller/Controller.dart';

class SavingItem {
  final String id;
  final double amount;
  final DateTime date;
  final String wallet;
  final String source;
  final String? note;

  SavingItem({
    required this.id,
    required this.amount,
    required this.date,
    required this.wallet,
    required this.source,
    this.note,
  });

  factory SavingItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    double parseAmount(dynamic raw) {
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw.replaceAll(',', '')) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      return DateTime.now();
    }

    final noteRaw = data["note"];

    return SavingItem(
      id: doc.id,
      amount: parseAmount(data["amount"]),
      date: parseDate(data["date"]),
      wallet: (data["wallet"] ?? "").toString(),
      source: (data["source"] ?? "").toString(),
      note: (noteRaw == null || noteRaw.toString().trim().isEmpty)
          ? null
          : noteRaw.toString(),
    );
  }
}

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

  /// If false, disables swipe actions
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
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // 🍎 iOS Style
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
    } else {
      // 🤖 Android Style
      final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete saving?".tr),
          content: Text("This item will be deleted permanently.".tr),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel".tr,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Delete".tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      return res ?? false;
    }
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
      return true; // allow dismiss
    } catch (e) {
      _toast(context, _friendlyError(e));
      return false; // don't dismiss
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return _ErrorBox(message: "Please login to view savings.".tr);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query(uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && _cache.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snap.hasError && _cache.isEmpty) {
          return _ErrorBox(message: _friendlyError(snap.error!));
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassCard(child: StreamBuilder<String>(
              stream: Get.find<savingController>().streamTotalSavingsText(),
              builder: (context, snapshot) {
                final totalText = snapshot.data ?? "0";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(width: double.infinity,),
                    Text(
                      "Total History Savings".tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "৳${numberTranslation.toBnDigits(totalText)}",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            )),
            SizedBox(height: 10.h),

            ListView.separated(
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics,
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, i) {
                final item = list[i];
                final dateText = numberTranslation.formatDateBnFromString(
                  DateFormat("dd MMM yyyy").format(item.date),
                );

                final card = _GlassCard(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.savings_rounded,
                              color: AppColors.primary,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.source.isEmpty ? "Saving".tr : item.source.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined, size: 12.sp, color: Colors.black45),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item.wallet.tr,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.sp,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                dateText,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 10.sp,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, left: 58.w),
                          child: Text(
                            item.note!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );

                if (!widget.enableSwipeActions) return card;

                return Dismissible(
                  key: ValueKey(item.id),

                  // ✅ Only Right->Left (Delete)
                  direction: DismissDirection.endToStart,

                  // ✅ Delete background only
                  background: const SizedBox.shrink(),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Delete".tr,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete_outline, color: Colors.red),
                      ],
                    ),
                  ),

                  confirmDismiss: (direction) async {
                    return _handleDelete(context: context, uid: uid, item: item);
                  },

                  child: card,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.all(14.r),
      borderColor: Colors.red.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 10.w),
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

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
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
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

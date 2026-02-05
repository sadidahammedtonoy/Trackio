import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Core/numberTranslation.dart';
import '../../../../Core/snakbar.dart';
import 'package:get/get.dart';

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
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete saving?".tr),
        content: Text("This item will be deleted permanently.".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel".tr, style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete".tr, style: TextStyle(color: Colors.red),),
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

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = list[i];
            final dateText = numberTranslation.formatDateBnFromString(
              DateFormat("dd MMM yyyy").format(item.date),
            );

            final card = Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(10,10)
                    ),
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(-10,-10)
                    )
                  ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${item.source} ",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Saving".tr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "৳ ${numberTranslation.toBnDigits(item.amount.toStringAsFixed(1))}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.wallet, size: 15,),
                      Text(
                        "Wallet".tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ": ${item.wallet.tr}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (item.note != null) ...[
                    const SizedBox(height: 8),
                    Text(item.note!, style: const TextStyle(fontSize: 12)),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

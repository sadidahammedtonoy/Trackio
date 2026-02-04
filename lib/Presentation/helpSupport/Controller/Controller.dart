import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/loading.dart';
import '../../../Core/snakbar.dart';

class HelpSupportController extends GetxController {
  final search = "".obs;
  final selectedCategory = "All".obs;

  final categories = <String>[
    "All",
    "Account",
    "Data & Sync",
    "Transactions",
    "Security",
    "Troubleshooting",
  ].obs;

  final faqs = <Map<String, dynamic>>[
    {
      "category": "Account",
      "q": "How do I log in as Guest?",
      "a":
      "Tap 'Continue as Guest' on the login screen. Your data will be stored under an anonymous Firebase UID. If you logout as guest, data may be lost.",
    },
    {
      "category": "Account",
      "q": "How do I change my password?",
      "a":
      "Password change is available only for Email/Password accounts. Go to Settings → Security → Change Password.",
    },
    {
      "category": "Data & Sync",
      "q": "Where is my data stored?",
      "a":
      "Your financial records are stored in Firebase Firestore using your UID, so only your account can access your data.",
    },
    {
      "category": "Data & Sync",
      "q": "Why is my data not syncing?",
      "a":
      "Please check internet connection, login status, and try again. If you are in guest mode and logged out, previous data may not be recoverable.",
    },
    {
      "category": "Transactions",
      "q": "How do I add income/expense?",
      "a":
      "Go to Add Transaction → Press on (+) icon → choose type (Income/Expense/Saving/Lend/Borrow) → add amount, category, and date → Add Transaction Button.",
    },
    {
      "category": "Security",
      "q": "Is my data secure?",
      "a":
      "We use Firebase Authentication and Firestore security rules. Your data is linked to your UID. Keep your device secure and use a strong password.",
    },
    {
      "category": "Troubleshooting",
      "q": "The app is slow or stuck on loading. What should I do?",
      "a":
      "Close and reopen the app, check network, and update to the latest version. You can also clear cache from Settings if available.",
    },
  ].obs;

  List<Map<String, dynamic>> get filteredFaqs {
    final s = search.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    return faqs.where((f) {
      final matchesCategory = cat == "All" || f["category"] == cat;
      if (!matchesCategory) return false;

      if (s.isEmpty) return true;

      final q = (f["q"] ?? "").toString().toLowerCase();
      final a = (f["a"] ?? "").toString().toLowerCase();
      return q.contains(s) || a.contains(s);
    }).toList();
  }

  void openReportSheet() {
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Report a problem".tr,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Title".tr,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailsCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Describe the issue".tr,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send, color: Colors.white,),
                  label: Text("Submit".tr, style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final details = detailsCtrl.text.trim();

                    if (title.isEmpty || details.isEmpty) {
                      AppSnackbar.show("Please fill title and details.".tr);
                      return;
                    }

                    // TODO: Send to Firestore / API / email
                    Get.back();
                    await sendUserReportToFirebase(
                    title: titleCtrl.text,
                    message: detailsCtrl.text,
                    category: selectedCategory.value,
                    extra: {
                      "screen": "HelpSupportPage",
                      "appVersion": "1.0.0",
                    },
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<bool> sendUserReportToFirebase({
    required String title,
    required String message,
    String category = "General",
    Map<String, dynamic>? extra, // optional: any extra fields
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (title.trim().isEmpty || message.trim().isEmpty) {
        AppSnackbar.show("Please provide title and details.".tr);
        return false;
      }

      AppLoader.show(message: "Submitting report...".tr);

      final uid = user?.uid ?? "unknown";
      final isAnonymous = user?.isAnonymous ?? false;

      // name/email fallbacks
      final displayName = (user?.displayName ?? "").trim();
      final email = (user?.email ?? "").trim();

      // Create doc with auto ID
      await FirebaseFirestore.instance.collection('userReports').add({
        "uid": uid,
        "isAnonymous": isAnonymous,
        "email": email.isEmpty ? null : email,
        "name": displayName.isEmpty ? null : displayName,

        "category": category,
        "title": title.trim(),
        "message": message.trim(),

        "status": "open", // open / in_progress / resolved (your choice)
        "createdAt": FieldValue.serverTimestamp(),

        // optional extra info
        "extra": extra ?? {},
      });

      AppLoader.hide();
      AppSnackbar.show("Thanks! Your report has been submitted.".tr);
      return true;
    } catch (e, s) {
      AppLoader.hide();
      if (kDebugMode) {
        print("sendUserReportToFirebase error: $e");
        print(s);
      }
      AppSnackbar.show("Failed to submit report. Please try again.".tr);
      return false;
    }
  }
}


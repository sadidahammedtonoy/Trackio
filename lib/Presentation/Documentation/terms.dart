import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Presentation/Share/Background.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    Widget body = ListView(
      padding: EdgeInsets.fromLTRB(
        tablet ? 24.0 : 16, 
        tablet ? 24.0 : 16, 
        tablet ? 24.0 : 16, 
        tablet ? 32.0 : 24
      ),
      children: [
        const _Header(),
  
        _Section(
          title: "Using Trackio".tr,
          points: [
            "You must use this app for lawful and personal financial tracking purposes only.".tr,
            "You are responsible for the accuracy of the data you enter.".tr,
          ],
        ),
  
        _Section(
          title: "Accounts & Access".tr,
          points: [
            "Accounts are managed through Firebase Authentication.".tr,
            "Guest users may lose data if they log out or delete the account.".tr,
            "You are responsible for keeping your login method secure.".tr,
          ],
        ),
  
        _Section(
          title: "Financial Disclaimer".tr,
          points: [
            "This app does not provide financial, tax, or legal advice.".tr,
            "All reports and summaries are for informational purposes only.".tr,
          ],
        ),
  
        _Section(
          title: "Service Availability".tr,
          points: [
            "We strive to keep the app available at all times.".tr,
            "Internet connectivity is required for syncing data.".tr,
            "Features may change or be updated without notice.".tr,
          ],
        ),
  
        _Section(
          title: "Limitation of Liability".tr,
          points: [
            "We are not responsible for losses due to incorrect data entry.".tr,
            "We are not liable for service interruptions or data loss beyond our control.".tr,
          ],
        ),
  
        _Section(
          title: "Account Termination".tr,
          points: [
            "You may delete your account at any time from the app.".tr,
            "Deleting an account may permanently remove associated data.".tr,
          ],
        ),
  
        const _Footer(),
      ],
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
        appBar: AppBar(
          title: Text(
            "Terms & Conditions".tr,
            style: tablet ? const TextStyle(fontSize: 18.0) : null,
          ),
          titleSpacing: -10,
        ),
        body: body,
      ),
    );
  }
}

/* ---------------- UI Helpers ---------------- */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Terms & Conditions".tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "By using this app, you agree to these terms.".tr,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Text(
            "Last updated: February 2026",
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> points;

  const _Section({required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("• $p",
                  style: const TextStyle(fontSize: 13.5, height: 1.4)),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Acceptance of Terms".tr,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "If you do not agree with these terms, please stop using the app.".tr,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text("Back".tr, style: const TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

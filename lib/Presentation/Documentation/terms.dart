import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const [
          _Header(),

          _Section(
            title: "Using the App",
            points: [
              "You must use this app for lawful and personal financial tracking purposes only.",
              "You are responsible for the accuracy of the data you enter.",
            ],
          ),

          _Section(
            title: "Accounts & Access",
            points: [
              "Accounts are managed through Firebase Authentication.",
              "Guest users may lose data if they log out or delete the account.",
              "You are responsible for keeping your login method secure.",
            ],
          ),

          _Section(
            title: "Financial Disclaimer",
            points: [
              "This app does not provide financial, tax, or legal advice.",
              "All reports and summaries are for informational purposes only.",
            ],
          ),

          _Section(
            title: "Service Availability",
            points: [
              "We strive to keep the app available at all times.",
              "Internet connectivity is required for syncing data.",
              "Features may change or be updated without notice.",
            ],
          ),

          _Section(
            title: "Limitation of Liability",
            points: [
              "We are not responsible for losses due to incorrect data entry.",
              "We are not liable for service interruptions or data loss beyond our control.",
            ],
          ),

          _Section(
            title: "Account Termination",
            points: [
              "You may delete your account at any time from the app.",
              "Deleting an account may permanently remove associated data.",
            ],
          ),

          _Footer(),
        ],
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
        children: const [
          Text(
            "Terms & Conditions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            "By using this app, you agree to these terms.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 10),
          Text(
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
          const Text(
            "Acceptance of Terms",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            "If you do not agree with these terms, please stop using the app.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text("Back", style: TextStyle(color: Colors.white),),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

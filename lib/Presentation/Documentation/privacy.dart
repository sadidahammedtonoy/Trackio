import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const [
          _Header(
            title: "Privacy Policy",
            subtitle:
            "Your privacy matters to us. This explains how your data is collected, stored, and protected.",
          ),

          _Section(
            title: "Information We Collect",
            points: [
              "Account information from Firebase Authentication (email, UID, display name, profile image if available).",
              "Financial records you add such as income, expenses, savings, lend/borrow entries, notes, and categories.",
              "Anonymous (guest) users are assigned a temporary UID by Firebase.",
            ],
          ),

          _Section(
            title: "How We Use Your Information",
            points: [
              "To securely store and sync your financial data across devices.",
              "To generate summaries, reports, and insights about your spending and income.",
              "To improve app performance, stability, and security.",
            ],
          ),

          _Section(
            title: "Data Storage & Security",
            points: [
              "All data is stored in Firebase Firestore under your unique user ID (UID).",
              "Firebase security rules restrict access so only your account can read or write your data.",
              "We do not store your passwords on our servers.",
            ],
          ),

          _Section(
            title: "Guest (Anonymous) Accounts",
            points: [
              "Guest users can use the app without creating an account.",
              "Data is linked to an anonymous Firebase UID.",
              "If you log out or delete the guest account, the data may be permanently lost.",
            ],
          ),

          _Section(
            title: "Data Sharing",
            points: [
              "We do not sell or rent your personal data.",
              "Data may be processed by Firebase services to provide authentication and cloud storage.",
              "We may disclose data if required by law.",
            ],
          ),

          _Section(
            title: "Account Deletion",
            points: [
              "You can delete your account from the app settings.",
              "Once deleted, your data may be permanently removed and cannot be recovered.",
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
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle,
              style:
              const TextStyle(fontSize: 14, color: Colors.black54)),
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
          Text(
            title,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("•  ",
                      style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
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
            "Questions?",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            "If you have any questions about this Privacy Policy, please contact support.",
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

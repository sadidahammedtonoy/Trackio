import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/assets_path.dart';
import '../Controller/Controller.dart';

class MakePermanentDialog extends StatelessWidget {
  const MakePermanentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MakePermanentController());

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22), // 🔥 smoother radius
          child: Obx(() {
            final guest = c.isGuest.value;

            return Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Container(color: Colors.white,)
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),

                        // Header
                        Row(
                          children: [
                            Text(
                              "Make Permanent Account".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.close),
                            )
                          ],
                        ),

                        const SizedBox(height: 10),

                        _statusCard(
                          guest: guest,
                          email: c.displayEmail.value,
                        ),

                        const SizedBox(height: 14),

                        if (!guest) ...[
                          Text(
                            "Your account is already permanent.".tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                "Done".tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ] else ...[
                          Text(
                            "Create with Email".tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: c.emailC,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email".tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Obx(() => TextField(
                            controller: c.passC,
                            obscureText: c.hidePass.value,
                            decoration: InputDecoration(
                              labelText: "Password".tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => c.hidePass.value =
                                !c.hidePass.value,
                                icon: Icon(
                                  c.hidePass.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          )),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: c.isLoading.value
                                  ? null
                                  : c.makePermanentWithEmail,
                              child: Text(
                                "Make Permanent".tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: Text(
                              "OR".tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: c.isLoading.value
                                  ? null
                                  : c.makePermanentWithGoogle,
                              icon: Image.asset(
                                assets_path.google,
                                width: 25,
                              ),
                              label: Text(
                                "Continue with Google".tr,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "This upgrades your guest account to a permanent account."
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 15),
                        ],
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (c.isLoading.value)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _statusCard({required bool guest, required String email}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: guest ? Colors.orange.withOpacity(0.12) : Colors.green.withOpacity(0.12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(
            guest ? Icons.person_outline : Icons.verified,
            color: guest ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              guest
                  ? "You are using a Guest account. Make it permanent to keep data forever.".tr
                  : "Permanent account${email.isNotEmpty ? ": $email" : ""}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

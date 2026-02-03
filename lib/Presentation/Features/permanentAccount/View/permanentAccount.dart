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
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Obx(() {
        final guest = c.isGuest.value;

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        "Make Permanent Account",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Status card
                  _statusCard(guest: guest, email: c.displayEmail.value),

                  const SizedBox(height: 14),

                  if (!guest) ...[
                    const Text(
                      "Your account is already permanent.",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text("Done", style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ] else ...[
                    const Text(
                      "Create with Email",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: c.emailC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(() => TextField(
                      controller: c.passC,
                      obscureText: c.hidePass.value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => c.hidePass.value = !c.hidePass.value,
                          icon: Icon(c.hidePass.value ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    )),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: c.isLoading.value ? null : c.makePermanentWithEmail,
                        child: const Text("Make Permanent", style: TextStyle(color: Colors.white),),
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Center(
                      child: Text("OR", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: c.isLoading.value ? null : c.makePermanentWithGoogle,
                        icon: Image.asset(assets_path.google, width: 25,),
                        label: const Text("Continue with Google"),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "This upgrades your guest account to a permanent account.",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            // Loading overlay
            if (c.isLoading.value) ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
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
                  ? "You are using a Guest account. Make it permanent to keep data forever."
                  : "Permanent account${email.isNotEmpty ? ": $email" : ""}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

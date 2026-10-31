import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/assets_path.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class MakePermanentDialog extends StatelessWidget {
  const MakePermanentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MakePermanentController());
    final tablet = _isTablet(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: tablet ? 24.0 : 16.0, 
        vertical: tablet ? 32.0 : 24.0
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tablet ? 400.0 : double.infinity),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
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
                  padding: EdgeInsets.all(tablet ? 24.0 : 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: tablet ? 18.0 : 14.0),
  
                        // Header
                        Row(
                          children: [
                            Text(
                              "Make Permanent Account".tr,
                              style: TextStyle(
                                fontSize: tablet ? 18.0 : 16.0,
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
  
                        SizedBox(height: tablet ? 14.0 : 10.0),
  
                        _statusCard(
                          guest: guest,
                          email: c.displayEmail.value,
                          tablet: tablet,
                        ),
  
                        SizedBox(height: tablet ? 18.0 : 14.0),
  
                        if (!guest) ...[
                          Text(
                            "Your account is already permanent.".tr,
                            style: TextStyle(
                              fontSize: tablet ? 15.0 : 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: tablet ? 16.0 : 12.0),
                          SizedBox(
                            width: double.infinity,
                            height: tablet ? 50.0 : 46.0,
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
                            style: TextStyle(
                              fontSize: tablet ? 15.0 : 14.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: tablet ? 14.0 : 10.0),
  
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
  
                          SizedBox(height: tablet ? 16.0 : 12.0),
  
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
  
                          SizedBox(height: tablet ? 16.0 : 12.0),
  
                          SizedBox(
                            width: double.infinity,
                            height: tablet ? 50.0 : 46.0,
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
  
                          SizedBox(height: tablet ? 18.0 : 14.0),
  
                          Center(
                            child: Text(
                              "OR".tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
  
                          SizedBox(height: tablet ? 18.0 : 14.0),
  
                          SizedBox(
                            width: double.infinity,
                            height: tablet ? 50.0 : 46.0,
                            child: OutlinedButton.icon(
                              onPressed: c.isLoading.value
                                  ? null
                                  : c.makePermanentWithGoogle,
                              icon: Image.asset(
                                assets_path.google,
                                width: tablet ? 28.0 : 25.0,
                              ),
                              label: Text(
                                "Continue with Google".tr,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
  
                          SizedBox(height: tablet ? 14.0 : 10.0),
  
                          Text(
                            "This upgrades your guest account to a permanent account."
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: tablet ? 13.0 : 12.0,
                            ),
                          ),
  
                          SizedBox(height: tablet ? 20.0 : 15.0),
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
                      child: Center(
                        child: SizedBox(
                          width: tablet ? 42.0 : 34.0,
                          height: tablet ? 42.0 : 34.0,
                          child: const CircularProgressIndicator.adaptive(),
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

  Widget _statusCard({required bool guest, required String email, required bool tablet}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tablet ? 16.0 : 12.0),
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
            size: tablet ? 28.0 : 24.0,
          ),
          SizedBox(width: tablet ? 14.0 : 10.0),
          Expanded(
            child: Text(
              guest
                  ? "You are using a Guest account. Make it permanent to keep data forever.".tr
                  : "Permanent account${email.isNotEmpty ? ": $email" : ""}",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: tablet ? 15.0 : 14.0),
            ),
          ),
        ],
      ),
    );
  }
}

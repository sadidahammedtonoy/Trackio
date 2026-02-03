import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../App/AppColors.dart';

class AppLoader {
  static void show({String message = "Loading..."}) {
    // Prevent multiple dialogs
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.primary,
        elevation: 0,
        child: _LoaderWidget(message: message),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print("AppLoader.hide() error: $e");
      }
    }
  }
}

class _LoaderWidget extends StatelessWidget {
  final String message;

  const _LoaderWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Colors.white,
              ),
            ),
            child: const CircularProgressIndicator.adaptive(),
          ),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}

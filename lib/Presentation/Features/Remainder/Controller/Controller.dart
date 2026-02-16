import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Core/snakbar.dart';
import 'dart:io';
import '../../../../Core/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/remainderModel.dart';


class ReminderController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String userId;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var reminders = <Reminder>[].obs;

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;

  @override
  void onInit() {
    super.onInit();
    final user = auth.currentUser;
    if (user == null) {
      AppSnackbar.show("User not logged in".tr);
      return;
    }
    userId = user.uid;
    loadReminders();
  }

  CollectionReference<Map<String, dynamic>> get reminderCollection =>
      firestore.collection('users').doc(userId).collection('reminders');

  void loadReminders() {
    reminderCollection.snapshots().listen((snapshot) {
      reminders.value = snapshot.docs
          .map((doc) => Reminder.fromMap(doc.id, doc.data()))
          .toList();
      // Sort by date
      reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
  }

  // Generate unique notification ID
  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime tempDate =
    selectedDate.value.isBefore(now) ? now : selectedDate.value;

    if (Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Cancel / Done
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Done".tr,
                        style: TextStyle(color: Colors.cyan),
                      ),
                      onPressed: () {
                        selectedDate.value = tempDate;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Date Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: now,
                  onDateTimeChanged: (val) {
                    tempDate = val; // update temp variable only
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate:
        selectedDate.value.isBefore(now) ? now : selectedDate.value,
        firstDate: now,
        lastDate: DateTime(2100),
      );
      if (picked != null) selectedDate.value = picked;
    }
  }


  Future<void> pickTime(BuildContext context) async {
    if (Platform.isIOS) {
      Duration tempDuration = Duration(
        hours: selectedTime.value.hour,
        minutes: selectedTime.value.minute,
      );

      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Cancel / Done
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Done".tr,
                        style: TextStyle(color: Colors.cyan),
                      ),
                      onPressed: () {
                        // Save selected time
                        selectedTime.value = TimeOfDay(
                          hour: tempDuration.inHours,
                          minute: tempDuration.inMinutes % 60,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: tempDuration,
                  onTimerDurationChanged: (duration) {
                    tempDuration = duration; // update temp variable
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final picked = await showTimePicker(
        context: context,
        initialTime: selectedTime.value,
      );
      if (picked != null) selectedTime.value = picked;
    }
  }

  Future<void> addReminder() async {
    if (titleController.text.isEmpty) {
      AppSnackbar.show("Title cannot be empty".tr);
      return;
    }

    DateTime dt = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    // Check if the selected time is in the past
    if (dt.isBefore(DateTime.now())) {
      AppSnackbar.show("Cannot set reminder for past time".tr);

      return;
    }

    // Generate unique notification ID
    int notificationId = _generateNotificationId();

    try {
      Get.back();
      // Schedule notification first
      await NotificationService.scheduleNotification(
        id: notificationId,
        title: titleController.text,
        body: descriptionController.text,
        dateTime: dt,
      );

      // Then save to Firestore
      await reminderCollection.add({
        'title': titleController.text,
        'description': descriptionController.text,
        'dateTime': dt.toIso8601String(),
        'notificationId': notificationId,
      });
      AppSnackbar.show("Reminder added successfully".tr);

      clearFields();
    } catch (e) {
      AppSnackbar.show("Failed to add reminder".tr);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (titleController.text.isEmpty) {
      AppSnackbar.show("Title cannot be empty".tr);
      return;
    }

    DateTime dt = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    // Check if the selected time is in the past
    if (dt.isBefore(DateTime.now())) {
      AppSnackbar.show("Cannot set reminder for past time".tr);
      return;
    }

    try {
      // Cancel old notification
      await NotificationService.cancelNotification(reminder.notificationId);

      // Schedule new notification with same ID
      await NotificationService.scheduleNotification(
        id: reminder.notificationId,
        title: titleController.text,
        body: descriptionController.text,
        dateTime: dt,
      );

      // Update Firestore
      await reminderCollection.doc(reminder.id).update({
        'title': titleController.text,
        'description': descriptionController.text,
        'dateTime': dt.toIso8601String(),
      });
      AppSnackbar.show("Reminder updated successfully".tr);

      clearFields();
      Get.back();
    } catch (e) {
      AppSnackbar.show("Failed to update reminder".tr);
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      // Cancel notification
      await NotificationService.cancelNotification(reminder.notificationId);

      // Delete from Firestore
      await reminderCollection.doc(reminder.id).delete();
    } catch (e) {
      AppSnackbar.show("Failed to delete reminder".tr);
    }
  }

  void openAddEditDialog({Reminder? reminder, required BuildContext context}) {
    if (reminder != null) {
      titleController.text = reminder.title;
      descriptionController.text = reminder.description;
      selectedDate.value = reminder.dateTime;
      selectedTime.value =
          TimeOfDay(hour: reminder.dateTime.hour, minute: reminder.dateTime.minute);
    } else {
      clearFields();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Platform.isIOS ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("New Reminder".tr, style: TextStyle(fontSize: 22.sp),),
              Text("Never forget important tasks add your reminder now.".tr),
              SizedBox(height: 15),
              TextField(
                controller: titleController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                    labelText: "Title".tr,
                  labelStyle: TextStyle(color: Colors.black)
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Description".tr,
                  labelStyle: const TextStyle(color: Colors.black),
                ),
              ),

              SizedBox(height: 10),
              Obx(() => ListTile(
                title: Text(
                    "${"Date:".tr} ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}", style: TextStyle(color: Colors.black),),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18,),
                onTap: () => pickDate(Get.context!),
              )),
              Obx(() => ListTile(
                title:
                Text("${"Time:".tr} ${selectedTime.value.format(Get.context!)}"),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18,),
                onTap: () => pickTime(Get.context!),
              )),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (reminder != null) {
                    updateReminder(reminder);
                  } else {
                    addReminder();
                  }
                },
                style:
                ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text(reminder != null ? "Update Reminder".tr : "Add Reminder".tr, style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmDelete(Reminder reminder) async {
    bool confirmed = false;

    if (Platform.isIOS) {
      confirmed = await showCupertinoDialog<bool>(
        context: Get.context!,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Delete Reminder".tr),
          content: Text("Are you sure you want to delete this reminder?".tr),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel".tr),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              child: Text("Delete".tr, style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ) ??
          false;
    } else {
      confirmed = await showDialog<bool>(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text("Delete Reminder".tr),
          content: Text("Are you sure you want to delete this reminder?".tr),
          actions: [
            TextButton(
              child:  Text("Cancel".tr),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Delete".tr, style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ) ??
          false;
    }

    if (confirmed) {
      await deleteReminder(reminder);
      AppSnackbar.show("Reminder removed successfully".tr);
    }
  }
}
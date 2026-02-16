import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../Core/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Reminder {
  String id;
  String title;
  String description;
  DateTime dateTime;
  int notificationId; // Add this field

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.notificationId,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'notificationId': notificationId,
  };

  factory Reminder.fromMap(String id, Map<String, dynamic> map) {
    return Reminder(
      id: id,
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      notificationId: map['notificationId'] ?? id.hashCode,
    );
  }
}

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
      Get.snackbar("Error", "User not logged in");
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
    if (Platform.isIOS) {
      DateTime initial =
      selectedDate.value.isBefore(now) ? now : selectedDate.value;

      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 250,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initial,
            minimumDate: now,
            onDateTimeChanged: (val) => selectedDate.value = val,
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
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 250,
          color: Colors.white,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(
              hours: selectedTime.value.hour,
              minutes: selectedTime.value.minute,
            ),
            onTimerDurationChanged: (duration) {
              selectedTime.value = TimeOfDay(
                hour: duration.inHours,
                minute: duration.inMinutes % 60,
              );
            },
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
      Get.snackbar("Error", "Title cannot be empty");
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
      Get.snackbar(
        "Error",
        "Cannot set reminder for past time",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Generate unique notification ID
    int notificationId = _generateNotificationId();

    try {
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

      Get.snackbar(
        "Success",
        "Reminder added successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      clearFields();
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add reminder: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (titleController.text.isEmpty) {
      Get.snackbar("Error", "Title cannot be empty");
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
      Get.snackbar(
        "Error",
        "Cannot set reminder for past time",
        snackPosition: SnackPosition.BOTTOM,
      );
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

      Get.snackbar(
        "Success",
        "Reminder updated successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      clearFields();
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update reminder: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      // Cancel notification
      await NotificationService.cancelNotification(reminder.notificationId);

      // Delete from Firestore
      await reminderCollection.doc(reminder.id).delete();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete reminder: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openAddEditDialog({Reminder? reminder}) {
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Platform.isIOS ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              Obx(() => ListTile(
                title: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => pickDate(Get.context!),
              )),
              Obx(() => ListTile(
                title:
                Text("Time: ${selectedTime.value.format(Get.context!)}"),
                trailing: Icon(Icons.access_time),
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
                child: Text(reminder != null ? "Update Reminder" : "Add Reminder"),
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
          title: const Text("Delete Reminder"),
          content: const Text("Are you sure you want to delete this reminder?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
          title: const Text("Delete Reminder"),
          content: const Text("Are you sure you want to delete this reminder?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ) ??
          false;
    }

    if (confirmed) {
      await deleteReminder(reminder);
      Get.snackbar("Deleted", "Reminder removed successfully");
    }
  }
}
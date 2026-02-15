import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Controller.dart';
import 'package:intl/intl.dart';

class ReminderHomePage extends StatelessWidget {
  final ReminderController controller = Get.put(ReminderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reminders")),
      body: Obx(() {
        if (controller.reminders.isEmpty) {
          return Center(child: Text("No Reminders Yet"));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.reminders.length,
          itemBuilder: (context, index) {
            final reminder = controller.reminders[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(reminder.title),
                subtitle: Text(
                  "${reminder.description}\n${DateFormat('yyyy-MM-dd – HH:mm').format(reminder.dateTime)}",
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => controller.openAddEditDialog(reminder: reminder),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteReminder(reminder),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openAddEditDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

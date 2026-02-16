import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ReminderHomePage extends StatelessWidget {
  final ReminderController controller = Get.put(ReminderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reminders".tr), titleSpacing: -10,),
      body: Obx(() {
        if (controller.reminders.isEmpty) {
          return Center(child: Text("No Reminders Yet".tr));
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: controller.reminders.length,
          itemBuilder: (context, index) {
            final reminder = controller.reminders[index];
            return Dismissible(
              key: Key(reminder.id),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    Text("Edit".tr, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),),
                  ],
                ),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Delete".tr, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),),
                    const Icon(Icons.delete, color: Colors.red),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  controller.openAddEditDialog(reminder: reminder, context: context);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  controller.confirmDelete(reminder);
                }
                return false;
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(10, 10)),
                    // BoxShadow(
                    //     color: Colors.black.withOpacity(0.08),
                    //     blurRadius: 12,
                    //     offset: const Offset(-10, -10)),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    reminder.title,
                    style:
                    TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.description),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              color: Colors.cyan, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('yyyy-MM-dd').format(reminder.dateTime),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.access_time,
                              color: Colors.cyan, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('HH:mm').format(reminder.dateTime),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: () => controller.openAddEditDialog(context: context),
        child: Icon(Icons.alarm_add, color: Colors.black,),
      ),
    );
  }
}

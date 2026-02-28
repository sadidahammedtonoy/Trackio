import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../../../../App/AppColors.dart';
import '../../../../App/assets_path.dart';
import '../../../../Core/snakbar.dart';
import '../../Transcations/Model/tranModel.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';

class editTransactions extends StatelessWidget {
  TranItem model;
  editTransactions({super.key, required this.model});

  final controller = Get.find<editTransactionsController>();

  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Transaction".tr),
          centerTitle: false,
          titleSpacing: -10,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type of Transaction".tr, style: TextStyle(fontSize: 16)),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue:
                        controller.types.contains(controller.selectedType.value)
                        ? controller.selectedType.value
                        : null,

                    hint: Text(
                      "Select type".tr,
                      style: TextStyle(color: Colors.grey),
                    ),

                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),

                    items: controller.types.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item.tr,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value != null) controller.selectedType.value = value;
                    },

                    decoration: const InputDecoration(
                      filled: false,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Text("Payment Processed On".tr, style: TextStyle(fontSize: 16)),
                Obx(
                  () => InkWell(
                    onTap: () async {
                      if (Platform.isIOS) {
                        // ✅ iOS: Cupertino picker in bottom sheet
                        DateTime temp = controller.selectedDate.value;

                        await showCupertinoModalPopup(
                          context: context,
                          builder: (_) => Container(
                            height: 320,
                            color: Colors.white, // ✅ white background
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Text(
                                          "Cancel".tr,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Text(
                                          "Done".tr,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.selectedDate.value = temp;
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    initialDateTime:
                                        controller.selectedDate.value,
                                    minimumDate: DateTime(2000),
                                    maximumDate: DateTime(2100),
                                    onDateTimeChanged: (d) => temp = d,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // ✅ Android: Material date picker with white background
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate.value,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary:
                                      Colors.black, // header / buttons color
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          controller.selectedDate.value = pickedDate;
                        }
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor:
                            Colors.white, // ✅ field background already white
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: Colors.black87,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: Text(
                        "${controller.selectedDate.value.day.toString().padLeft(2, '0')}-"
                        "${controller.selectedDate.value.month.toString().padLeft(2, '0')}-"
                        "${controller.selectedDate.value.year}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Text("Amount".tr, style: TextStyle(fontSize: 16)),
                TextFormField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Enter Amount".tr),
                ),
                Text("Wallet".tr, style: TextStyle(fontSize: 16)),
                Obx(
                  () => DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    initialValue: controller.selectedWallet.value,
                    items: controller.wallets.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item.tr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        controller.selectedWallet.value = value;
                    },
                    decoration: InputDecoration(),
                  ),
                ),

                Obx(
                  () =>
                      controller.selectedType.value == "Lent" ||
                          controller.selectedType.value == "Borrow"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${controller.selectedType.value} Person Name".tr,
                              style: TextStyle(fontSize: 16),
                            ),
                            TextFormField(
                              controller: controller.personNameController,
                              decoration: InputDecoration(
                                hintText: "Type here..".tr,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaction Category".tr,
                              style: TextStyle(fontSize: 16),
                            ),
                            Obx(
                              () => DropdownButtonFormField<String>(
                                initialValue:
                                    controller.categories.any(
                                      (e) =>
                                          e["name"] ==
                                          controller.selectedCategoryId.value,
                                    )
                                    ? controller.selectedCategoryId.value
                                    : null,

                                hint: Text(
                                  "Select category".tr,
                                  style: TextStyle(color: Colors.grey),
                                ),

                                dropdownColor: Colors.white,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black87,
                                ),

                                items: controller.categories.map((cat) {
                                  final name = (cat["name"] ?? "").toString();

                                  return DropdownMenuItem<String>(
                                    value: name, // ⭐ store TEXT
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  controller.selectedCategoryId.value =
                                      value ?? '';
                                },

                                decoration: const InputDecoration(
                                  filled: false,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                Text("Remark".tr, style: TextStyle(fontSize: 16)),
                TextFormField(
                  minLines: 4,
                  maxLines: 5,
                  controller: controller.noteController,
                  decoration: InputDecoration(
                    hintText: "You can leave a note here...".tr,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final old = controller.oldItem;
                    if (old == null) {
                      AppSnackbar.show("No transaction selected".tr);
                      return;
                    }

                    final rawAmount = controller.amountController.text.trim();
                    final amount = double.tryParse(rawAmount);

                    if (amount == null || amount <= 0) {
                      AppSnackbar.show("Please enter a valid amount".tr);
                      return;
                    }

                    final isLentOrBorrow =
                        controller.selectedType.value == "Lent" ||
                        controller.selectedType.value == "Borrow";

                    final category = isLentOrBorrow
                        ? controller.personNameController.text.trim()
                        : (controller.selectedCategoryId.value ?? "");

                    final updated = TranItem(
                      id: old.id,
                      monthKey: old
                          .monthKey, // recalculated inside edit method if date changes
                      type: controller.selectedType.value,
                      date: controller.selectedDate.value,
                      amount: amount,
                      wallet: controller.selectedWallet.value,
                      category: category,
                      note: controller.noteController.text.trim(),
                      marked: old.marked,
                    );

                    await controller.editMonthlyTransaction(
                      oldItem: old,
                      updatedItem: updated,
                    );
                  },
                  child: Obx(
                    () => Text(
                      "Edit ${controller.selectedType.value}".tr,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            Get.dialog(CalculatorDialog(), barrierDismissible: true);
          },
          child: SizedBox(
            width: 50,
            height: 50,
            child: Lottie.asset(
              assets_path.calculator,
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),
        ),
      ),
    );
  }
}

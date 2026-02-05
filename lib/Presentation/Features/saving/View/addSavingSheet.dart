import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sadid/App/AppColors.dart';

import '../Controller/Controller.dart';

class AddSavingSheet extends StatelessWidget {
  final savingController controller;
  const AddSavingSheet({required this.controller});

  String _dateText(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Future<void> _pickDate(BuildContext context) async {
    if (Platform.isIOS) {
      DateTime temp = controller.selectedDate.value;

      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 320,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text("Cancel".tr, style: TextStyle(color: Colors.black),),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text("Done".tr, style: TextStyle(color: AppColors.primary),),
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
                  initialDateTime: controller.selectedDate.value,
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
      final picked = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) controller.selectedDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        titleSpacing: -10,
        title: Text("Add Saving".tr)

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.motivationTitle.value.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.motivationSubtitle.value.tr,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              // Amount
              TextField(
                controller: controller.amountC,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Amount".tr,
                  hintText: "Enter amount".tr,
                  border: OutlineInputBorder(),
                ),
              ),
          
              const SizedBox(height: 12),
          
              // Date
              Obx(() => InkWell(
                onTap: () => _pickDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Date".tr,
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.calendar_month, color: Colors.black87),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dateText(controller.selectedDate.value),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              )),
          
              const SizedBox(height: 12),
          
              // Wallet dropdown
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedWallet.value,
                items: controller.wallets
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.tr)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedWallet.value = v;
                },
                dropdownColor: Colors.white, // ✅ dropdown background color
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Wallet".tr,
                  border: OutlineInputBorder(),
                ),
              )),
          
          
              const SizedBox(height: 12),
          
              // Source
              TextField(
                controller: controller.sourceC,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Source".tr,
                  hintText: "From where this money came from".tr,
                  border: OutlineInputBorder(),
                ),
              ),
          
              const SizedBox(height: 12),
          
              // Note
              TextField(
                controller: controller.noteC,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Note (optional)".tr,
                  hintText: "Anything you want to remember about this saving...".tr,
                  border: OutlineInputBorder(),
                ),
              ),
          
              const SizedBox(height: 14),
          
              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  label: Text(
                    "Add".tr,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  onPressed: controller.addSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

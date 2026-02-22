import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../../../../App/assets_path.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';

class addTranscations extends StatelessWidget {
  addTranscations({super.key});
  final addTranscationsController controller = Get.find<addTranscationsController>();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController personNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Add Transactions".tr),
          centerTitle: false,
          titleSpacing: -10,
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            Get.dialog(
              CalculatorDialog(),
              barrierDismissible: true,
            );
          },
          child: SizedBox(
            width: 50,
            height: 50,
            child: Lottie.asset(
              assets_path.calculator,
              fit: BoxFit.contain,
              repeat: false
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type of Transaction".tr, style: TextStyle(fontSize: 16),),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.types.contains(controller.selectedType.value)
                      ? controller.selectedType.value
                      : null,
            
                  hint: Text(
                    "Select type".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
            
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            
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
                )),
                Text("Payment Processed On".tr, style: TextStyle(fontSize: 16),),
                Obx(() => InkWell(
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                color: Colors.white,
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
                      // ✅ Android: Material date picker with white background
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dialogBackgroundColor: Colors.white, // ✅ white background
                              colorScheme: const ColorScheme.light(
                                primary: Colors.black, // header / buttons color
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
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
                      fillColor: Colors.white, // ✅ field background already white
                      suffixIcon: Icon(Icons.calendar_month, color: Colors.black87),
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
                )),
                Text("Amount".tr, style: TextStyle(fontSize: 16),),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Amount".tr,
                  ),
                ),
                Text("Wallet".tr, style: TextStyle(fontSize: 16),),
                Obx(() => DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: controller.selectedWallet.value,
                  items: controller.wallets.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item.tr),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectedWallet.value = value;
                  },
                  decoration: InputDecoration(
      
                  ),
                )),
      
                Obx(() => controller.selectedType.value == "Lent" || controller.selectedType.value == "Borrow" ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${controller.selectedType.value} Person Name".tr, style: TextStyle(fontSize: 16),),
                    TextFormField(
                      controller: personNameController,
                      decoration: InputDecoration(
                        hintText: "Type here..".tr,
                      ),
                    )
                  ],
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Transaction Category".tr, style: TextStyle(fontSize: 16),),
                    Obx(() => DropdownButtonFormField<String>(
                      value: controller.categories.any(
                              (e) => e["name"] == controller.selectedCategoryId.value)
                          ? controller.selectedCategoryId.value
                          : null,
      
                      hint: Text(
                        "Select category".tr,
                        style: TextStyle(color: Colors.grey),
                      ),
      
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
      
                      items: controller.categories.map((cat) {
                        final name = (cat["name"] ?? "").toString();
      
                        return DropdownMenuItem<String>(
                          value: name, // ⭐ store TEXT
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
      
                      onChanged: (value) {
                        controller.selectedCategoryId.value = value ?? '';
                      },
      
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor: Colors.white,
                      ),
                    )),
                  ],
                ),),
      
                Text("Remark".tr, style: TextStyle(fontSize: 16),),
                TextFormField(
                  minLines: 4,
                  maxLines: 5,
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: "You can leave a note here...".tr,
                  ),
                ),
      
                ElevatedButton(onPressed: (){
                  if(controller.selectedType.value == "Lent" || controller.selectedType.value == "Borrow"){
                    addTranModel model = addTranModel(type: controller.selectedType.value, date: controller.selectedDate.value, amount: amountController.text, wallet: controller.selectedWallet.value, category: personNameController.text, note: noteController.text);
                    controller.addMonthlyTransaction(model: model);
                  }else{
                    addTranModel model = addTranModel(type: controller.selectedType.value, date: controller.selectedDate.value, amount: amountController.text, wallet: controller.selectedWallet.value, category: controller.selectedCategoryId.value ?? "", note: noteController.text);
                    controller.addMonthlyTransaction(model: model);
                  }
                }, child: Obx(() => Text("Add ${controller.selectedType.value}".tr, style: TextStyle(color: Colors.white),))),
                const SizedBox(height: 15,)
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

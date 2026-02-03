import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Add Transactions"),
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
              Text("Type of Transaction", style: TextStyle(fontSize: 16),),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.types.contains(controller.selectedType.value)
                    ? controller.selectedType.value
                    : null,
          
                hint: const Text(
                  "Select type",
                  style: TextStyle(color: Colors.grey),
                ),
          
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          
                items: controller.types.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
          
                onChanged: (value) {
                  if (value != null) controller.selectedType.value = value;
                },
          
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              )),
              Text("Payment Processed On", style: TextStyle(fontSize: 16),),
              Obx(() => InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value, // 👈 today by default
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
          
                  if (pickedDate != null) {
                    controller.selectedDate.value = pickedDate;
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.calendar_month, color: Colors.black87,),

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
              Text("Amount", style: TextStyle(fontSize: 16),),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Amount",
                ),
              ),
              Text("Wallet", style: TextStyle(fontSize: 16),),
              Obx(() => DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: controller.selectedWallet.value,
                items: controller.wallets.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
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
                  Text("${controller.selectedType.value} Person Name", style: TextStyle(fontSize: 16),),
                  TextFormField(
                    controller: personNameController,
                    decoration: InputDecoration(
                      hintText: "Type here..",
                    ),
                  )
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Transaction Category", style: TextStyle(fontSize: 16),),
                  Obx(() => DropdownButtonFormField<String>(
                    value: controller.categories.any(
                            (e) => e["name"] == controller.selectedCategoryId.value)
                        ? controller.selectedCategoryId.value
                        : null,

                    hint: const Text(
                      "Select category",
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
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  )),
                ],
              ),),

              Text("Remark", style: TextStyle(fontSize: 16),),
              TextFormField(
                minLines: 4,
                maxLines: 5,
                controller: noteController,
                decoration: InputDecoration(
                  hintText: "You can leave a note here...",
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
              }, child: Obx(() => Text("Add ${controller.selectedType.value}", style: TextStyle(color: Colors.white),)))
              
            ],
          ),
        ),
      ),
    );
  }
}

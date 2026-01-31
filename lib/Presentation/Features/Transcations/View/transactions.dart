import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import '../Controller/Controller.dart';

class transcations_page extends StatelessWidget {
  transcations_page({super.key});
  final transactionsController Controller = Get.find<transactionsController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => Get.toNamed(routes.addTranscations_screen),
        backgroundColor: Colors.white,
      child: Icon(Icons.add, color: Colors.deepPurple,),
      ),
    );
  }
}

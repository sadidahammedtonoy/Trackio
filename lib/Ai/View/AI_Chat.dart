import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sadid/Ai/Model/aiModel.dart';
import '../Controller/Controller.dart';

class AiScreen extends StatelessWidget {
  AiScreen({super.key});

  final ai_controller controller = Get.put(ai_controller());
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Chat/List area
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.aiModels.length,
                  itemBuilder: (context, index) {
                    final aiModel aiModelContext = controller.aiModels[index];
                    final text = aiModelContext.text;

                    if (text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MarkdownBody(
                        data: text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 15, height: 1.4),
                          strong: const TextStyle(fontWeight: FontWeight.bold),
                          h3: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Input
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    controller: textEditingController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final msg = textEditingController.text.trim();
                            if (msg.isEmpty) return;

                            controller.askGemini(msg);
                            textEditingController.clear();
                          },
                          child: const Text("Send"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = await controller.pickAndAnalyzeImage(
                              prompt: "Describe this image briefly",
                              source: ImageSource.gallery,
                            );

                            if (result != null && result.trim().isNotEmpty) {
                              // If you want it to appear in the list:
                              // controller.aiModels.add(aiModel(text: result));
                              debugPrint(result);
                            }
                          },
                          child: const Text("Pick & Analyze"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        controller.generateImage("create a dog");
                      },
                      icon: const Icon(Icons.image_search_sharp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

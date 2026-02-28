import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:sadid/Ai/Model/aiModel.dart';

class ai_controller extends GetxController {
  final model = GenerativeModel(
    model: 'gemini-3-flash-preview',
    apiKey: 'AIzaSyC4094F0y2wEPzg6g1tDz4AEjy4EAdrWT8',
  );

  var aiModels = [].obs;

  Future<void> askGemini(String userPrompt) async {
    final content = [Content.text(userPrompt)];
    aiModels.add(aiModel(isMe: true, text: userPrompt));

    try {
      final response = await model.generateContent(content);
      print('Gemini says: ${response.text}');
      aiModels.add(aiModel(isMe: false, text: response.text.toString()));
    } catch (e) {
      print('Error: $e');
      aiModels.add(aiModel(isMe: false, text: e.toString()));
    }
  }

  Future<String?> pickAndAnalyzeImage({
    required String prompt,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // 1) Pick image
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85, // compress a bit (0-100)
      );

      if (file == null) return null; // user cancelled

      // 2) Read bytes
      final Uint8List bytes = await file.readAsBytes();

      // 3) Detect mime type (fallback to jpeg)
      final mimeType =
          lookupMimeType(file.path, headerBytes: bytes) ?? 'image/jpeg';

      // 4) Build content & call model
      final content = [
        Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
      ];

      final response = await model.generateContent(content);

      return response.text;
    } catch (e, st) {
      debugPrint("pickAndAnalyzeImage error: $e");
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<Uint8List?> generateImage(String description) async {
    final model = GenerativeModel(
      model: 'gemini-3-pro-image-preview',
      apiKey: 'AIzaSyC4094F0y2wEPzg6g1tDz4AEjy4EAdrWT8',
    );

    // In 2026, you often need to explicitly ask for the image modality
    // if your model supports both text and image output.
    final content = [Content.text("Generate an image of: $description")];

    try {
      final response = await model.generateContent(content);

      // 1. Find the first candidate
      final candidate = response.candidates.first;

      // 2. Look for the DataPart specifically
      // The property is '.bytes', which returns the Uint8List
      final imagePart = candidate.content.parts
          .whereType<DataPart>()
          .firstOrNull;

      if (imagePart != null) {
        return imagePart.bytes; // This is the Uint8List of the image
      } else {
        print(
          "No image data found in response. Text received: ${response.text}",
        );
        return null;
      }
    } catch (e) {
      print('Generation failed: $e');
      return null;
    }
  }
}

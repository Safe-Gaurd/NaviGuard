import 'dart:io';
import 'package:dio/dio.dart';

class CustomVideoUrlGenerator {
  Future<String?> uploadToCloudinary(File videoFile) async {
    final String cloudName =
        "dvd0mdeon"; // Change to your actual Cloudinary cloud name
    final String apiKey = "364113567663957"; // Change to your actual API key
    final String uploadPreset = "recordings"; // Ensure this preset is correct

    // Cloudinary upload URL for video files
    String uploadUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/video/upload";

    // Prepare the FormData to send to Cloudinary
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(videoFile.path),
      "upload_preset": uploadPreset,
      "api_key": apiKey,
      "folder": "recordings",
      "resource_type": "video",
    });

    try {
      Dio dio = Dio();
      Response response = await dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        String uploadedVideoUrl = response.data["secure_url"];
        //print("✅ Video Uploaded Successfully: $uploadedVideoUrl");
        return uploadedVideoUrl;
      } else {
        //print("❌ Upload Failed: ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      //print("❌ Error uploading video: $e");
      return null;
    }
  }
}

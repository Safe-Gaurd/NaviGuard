import 'dart:async';
import 'dart:io';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/constants/video_url_generator.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/constants/date_time.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  bool _isUploading = false;
  late Timer _timer;
  int _seconds = 0;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController =
          CameraController(cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _isTimerActive = true;
        _seconds = 0;
      });
      _startTimer();
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController != null &&
        _cameraController!.value.isRecordingVideo) {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isTimerActive = false;
        _isUploading = true; // Show the uploading indicator
      });
      _timer.cancel();
      //print("Recorded Video Path: }");
      File recordedFile = File(videoFile.path);
      //print("Recorded Video Path: ${videoFile.path}");

      String timestamp = "$formattedDate, $formattedTime";

      // Upload video to Cloudinary and store URL
      String? videoUrl =
          await CustomVideoUrlGenerator().uploadToCloudinary(recordedFile);

      if (videoUrl != null) {
        // Add video URL to Firestore
        UserProvider provider = Provider.of(context, listen: false);
        await provider.uploadVideo(
            videoURL: videoUrl,
            timestamp: timestamp); // Ensure upload completes

        toastMessage(
          context: context,
          message: "Video Saved successfully",
          position: DelightSnackbarPosition.top,
          leadingIcon: const Icon(Icons.check),
          toastColor: Colors.green[500],
          borderColor: Colors.green,
        );
      } else {
        toastMessage(
          context: context,
          message: "Upload failed. Try again.",
          position: DelightSnackbarPosition.top,
          leadingIcon: const Icon(Icons.error),
          toastColor: Colors.red[500],
          borderColor: Colors.red,
        );
      }

      // Hide the uploading indicator after upload is finished
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Timer logic
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTimerActive) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera Preview
          _cameraController != null && _cameraController!.value.isInitialized
              ? AspectRatio(
                  // aspectRatio: _cameraController!.value.aspectRatio,
                  aspectRatio: 1,
                  child: CameraPreview(_cameraController!),
                )
              : Center(child: CircularProgressIndicator()),

          const SizedBox(
            height: 25,
          ),
          // Timer Display
          if (_isRecording)
            Text(
              "Recording Time: ${_seconds}s",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

          // Start/Stop Button
          SizedBox(
            width: 170,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: _isUploading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: backgroundColor,
                      ),
                    )
                  : Text(
                      _isRecording ? 'Stop Recording' : 'Start Recording',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

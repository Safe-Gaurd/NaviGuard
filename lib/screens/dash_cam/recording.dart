import 'dart:async';
import 'dart:io';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
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
      _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
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
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isTimerActive = false;
      });
      _timer.cancel();

      File recordedFile = File(videoFile.path);
      print("Recorded Video Path: ${videoFile.path}");

      String timestamp = "$formattedDate, $formattedTime";
      // Upload video to Cloudinary and store URL
      String? videoUrl = await CustomVideoUrlGenerator().uploadToCloudinary(recordedFile);
      if (videoUrl != null) {
        setState(() {
          _isUploading = true;
        });

        // Add video URL to the list of videos
        UserProvider provider = Provider.of(context, listen: false);
        provider.uploadVideo(videoURL: videoUrl, timestamp: timestamp);
        print("Video URL uploaded to Firestore");

        toastMessage(
          context: context,
          message: "Video Saved successfully",
          position: DelightSnackbarPosition.top,
          leadingIcon: const Icon(Icons.check),
          toastColor: Colors.green[500],
          borderColor: Colors.green,
        );

        setState(() {
          _isUploading = false;
        });
      }
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

          // Timer Display
          if (_isRecording)
            Text(
              "Recording Time: ${_seconds}s",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

          // Start/Stop Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Text(
              _isRecording ? 'Stop Recording' : 'Start Recording',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Uploading Indicator
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/video_url_generator.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/constants/date_time.dart';

class RecordingScreen extends StatefulWidget {

  RecordingScreen();

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  bool _isUploading = false;

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
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

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

  
        

        setState(() {
          _isUploading = false;
        });

      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _cameraController != null && _cameraController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              )
            : Center(child: CircularProgressIndicator()),
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
        if (_isUploading) CircularProgressIndicator(),
      ],
    );
  }
}

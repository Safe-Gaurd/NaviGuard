// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:navigaurd/constants/colors.dart';
// import 'package:navigaurd/screens/widgets/appbar.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';

// class DashcamScreen extends StatefulWidget {
//   const DashcamScreen({super.key});

//   @override
//   _DashcamScreenState createState() => _DashcamScreenState();
// }

// class _DashcamScreenState extends State<DashcamScreen> {
//   int selectedScreen = 0;
//   List<File> recordedVideos = []; 

//   void _addRecordedVideo(File videoFile) {
//     setState(() {
//       recordedVideos.add(videoFile);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppbar(label: "DashCam"),
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: selectedScreen == 0 ? Colors.white :  blueColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero,
//                       ),
//                       padding: EdgeInsets.zero,
//                       elevation: 2,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         selectedScreen = 0;
//                       });
//                     },
//                     child: Text(
//                       'Recording',
//                       style: TextStyle(
//                         color: selectedScreen == 0 ?  blueColor : backgroundColor,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: SizedBox(
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: selectedScreen == 1 ? Colors.white : blueColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero,
//                       ),
//                       padding: EdgeInsets.zero,
//                       elevation: 2,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         selectedScreen = 1;
//                       });
//                     },
//                     child: Text(
//                       'Recorded',
//                       style: TextStyle(
//                         color: selectedScreen == 1 ?  blueColor : backgroundColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: selectedScreen == 0
//                 ? RecordingScreen(onVideoRecorded: _addRecordedVideo)
//                 : RecordedScreen(recordedVideos: recordedVideos),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class RecordingScreen extends StatefulWidget {
//   final Function(File) onVideoRecorded;

//   RecordingScreen({required this.onVideoRecorded});

//   @override
//   _RecordingScreenState createState() => _RecordingScreenState();
// }

// class _RecordingScreenState extends State<RecordingScreen> {
//   CameraController? _cameraController;
//   List<CameraDescription>? cameras;
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     cameras = await availableCameras();
//     if (cameras != null && cameras!.isNotEmpty) {
//       _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
//       await _cameraController!.initialize();
//       if (mounted) setState(() {});
//     }
//   }

//   Future<void> _startRecording() async {
//     if (_cameraController != null && _cameraController!.value.isInitialized) {
//       await _cameraController!.startVideoRecording();
//       setState(() {
//         _isRecording = true;
//       });
//     }
//   }

//   Future<void> _stopRecording() async {
//     if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
//       XFile videoFile = await _cameraController!.stopVideoRecording();
      
//       setState(() {
//         _isRecording = false;
//       });

//       // Convert XFile to File
//       File recordedFile = File(videoFile.path);

//       // Print the recorded video path (for debugging)
//       print("Recorded Video Path: ${videoFile.path}");

//       // Pass the recorded file to parent
//       widget.onVideoRecorded(recordedFile);
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _cameraController != null && _cameraController!.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _cameraController!.value.aspectRatio,
//                 child: CameraPreview(_cameraController!),
//               )
//             : Center(child: CircularProgressIndicator()),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue[400],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           onPressed: _isRecording ? _stopRecording : _startRecording,
//           child: Text(_isRecording ? 'Stop Recording' : 'Start Recording', style: TextStyle(color: Colors.white),),
//         ),
        
//       ],
//     );
//   }
// }


// class RecordedScreen extends StatelessWidget {
//   final List<File> recordedVideos;

//   RecordedScreen({required this.recordedVideos});

//   @override
//   Widget build(BuildContext context) {
//     return recordedVideos.isEmpty
//         ? Center(child: Text("No recorded videos available"))
//         : ListView.builder(
//             itemCount: recordedVideos.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text('Video ${index + 1}', style: TextStyle(fontSize: 22),),
//                 onTap: () => _playVideo(context, recordedVideos[index]),
//               );
//             },
//           );
//   }

//   void _playVideo(BuildContext context, File file) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VideoPlayerScreen(videoFile: file),
//       ),
//     );
//   }
// }

// class VideoPlayerScreen extends StatefulWidget {
//   final File videoFile;
//   VideoPlayerScreen({required this.videoFile});

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(widget.videoFile)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Play Video')),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               )
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
// }

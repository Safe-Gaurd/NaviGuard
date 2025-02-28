import 'package:flutter/material.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/video_player.dart';
import 'package:provider/provider.dart';

class RecordedScreen extends StatefulWidget {
  const RecordedScreen({super.key});

  @override
  State<RecordedScreen> createState() => _RecordedScreenState();
}

class _RecordedScreenState extends State<RecordedScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).listenToVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        

        return Scaffold(
          body: provider.videosList.isEmpty
              ? Center(child: Text("No recorded videos available"))
              : ListView.builder(
  itemCount: provider.videosList.length,
  itemBuilder: (context, index) {
    final videoData = provider.videosList[index];
    final timestamp = videoData['timestamp'];
    final videoURL = videoData['videoURL'];

    return ListTile(
      title: Text(
        timestamp!, 
        style: TextStyle(fontSize: 22),
      ),
      trailing: Icon(Icons.play_circle_fill, color: Colors.blue, size: 30),
      onTap: () => _playVideo(context, videoURL!),  
    );
  },
));
      },
    );
  }

  // Opens VideoPlayerScreen with the video URL
  void _playVideo(BuildContext context, String videoURL) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoURL: videoURL),
      ),
    );
  }
}

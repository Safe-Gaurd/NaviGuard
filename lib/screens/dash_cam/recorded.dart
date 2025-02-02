import 'package:flutter/material.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/video_player.dart';
import 'package:provider/provider.dart';

class RecordedScreen extends StatefulWidget {
  @override
  _RecordedScreenState createState() => _RecordedScreenState();
}

class _RecordedScreenState extends State<RecordedScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to video updates when screen loads
    Provider.of<UserProvider>(context, listen: false).listenToVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        

        return Scaffold(
          appBar: AppBar(title: Text("Recorded Videos")),
          body: provider.videosList.isEmpty
              ? Center(child: Text("No recorded videos available"))
              : ListView.builder(
                  itemCount: provider.videosList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'Video ${index + 1}',
                        style: TextStyle(fontSize: 22),
                      ),
                      trailing: Icon(Icons.play_circle_fill, color: Colors.blue, size: 30),
                      onTap: () => _playVideo(context, provider.videosList[index]),
                    );
                  },
                ),
        );
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

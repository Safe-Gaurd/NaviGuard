import 'dart:convert';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:navigaurd/constants/toast.dart';

class MapButtonScreen extends StatefulWidget {
  @override
  _MapButtonScreenState createState() => _MapButtonScreenState();
}

class _MapButtonScreenState extends State<MapButtonScreen> {
String _responseText = "Click the button to send a request";

 Future<void> _sendRequestToModel() async {
  final url = "https://navigaurd-ml-model.onrender.com/predict";
  // final url = "http://10.0.2.2:5000/predict";
  final requestBody = jsonEncode({'latitude': 16.54365482976982, 'longitude': 81.52578326246233});

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _responseText = "Slow Region: ${data['slow_region']}, Group: ${data['group']}";
      });

      // Ensure that the toast is displayed after the UI is updated
      if (data['slow_region'].contains("1")) {
        toastMessage(
          context: context,
          message: "There is a ${data['group']} NearBy. Please Go Slow",
          leadingIcon: const Icon(Icons.message),
          toastColor: Colors.yellow[300],
          borderColor: Colors.orange,
          position: DelightSnackbarPosition.top
        );
      }
    } else {
      setState(() {
        _responseText = "Request failed: ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      _responseText = "Error: $e";
    });
  }

  print(_responseText);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Request Button')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendRequestToModel,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.black,
              ),
              child:
                  Text("Send Request", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Text(_responseText,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

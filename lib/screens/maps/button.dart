import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ButtonScreen extends StatefulWidget {
  @override
  _ButtonScreenState createState() => _ButtonScreenState();
}

class _ButtonScreenState extends State<ButtonScreen> {
  String _responseText = "Click the button to send a request";

  Future<void> _sendRequestToModel() async {
    final url = "https://navigaurd-ml-model.onrender.com/predict";
    // final url = "http://10.0.2.2:5000/predict";
    final requestBody = jsonEncode({'latitude': 16.5662, 'longitude': 81.5225});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseText =
              "Slow Region: ${data['slow_region']}, Group: ${data['group']}";
        });
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

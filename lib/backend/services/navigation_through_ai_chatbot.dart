import 'package:flutter/material.dart';
import 'package:navigaurd/screens/maps/maps.dart';

// Create this file in a services or utils folder
class NavigationService {
  // Parse the navigation command from the chatbot
  static Map<String, String>? parseMapCommand(String response) {
    // Look for MAP_SCREEN: command in the response
    final RegExp regex = RegExp(r'MAP_SCREEN:(.*?)(?:\n|$)');
    final match = regex.firstMatch(response);
    
    if (match != null && match.group(1) != null) {
      final String commandString = match.group(1)!;
      final Map<String, String> params = {};
      
      // Parse parameters (destination=X;mode=Y)
      final paramPairs = commandString.split(';');
      for (var pair in paramPairs) {
        final keyValue = pair.split('=');
        if (keyValue.length == 2) {
          params[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
      
      return params;
    }
    
    return null;
  }
  
  // Navigate to the map screen with the parsed parameters
  static void navigateToMapScreen(BuildContext context, String chatbotResponse) {
    final navigationParams = parseMapCommand(chatbotResponse);
    
    if (navigationParams != null && navigationParams.containsKey('destination')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            destination: navigationParams['destination'],
            navigationMode: navigationParams['mode'] ?? 'driving',
          ),
        ),
      );
    }
  }
}
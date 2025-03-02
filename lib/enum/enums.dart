import 'package:flutter/material.dart';

enum Officer {
  police,
  hospitalMembers,
  bloodBankMembers,
  user,
}

// Function to get the title for each enum
String getOfficerTitle(Officer officer) {
  switch (officer) {
    case Officer.police:
      return "Police";
    case Officer.hospitalMembers:
      return "Hospital Members";
    case Officer.bloodBankMembers:
      return "Blood Bank Members";
    default:
      return "User";
  }
}

// Function to get the icon for each enum
IconData getOfficerIcon(Officer officer) {
  switch (officer) {
    case Officer.police:
      return Icons.local_police; 
    case Officer.hospitalMembers:
      return Icons.local_hospital; 
    case Officer.bloodBankMembers:
      return Icons.bloodtype; 
    default:
      return Icons.person;
  }
}
import 'package:flutter/material.dart';

class Navbaritems extends StatelessWidget {

  final IconData? icon;
  final String label;
  final void Function() onTap;
  final Color? labelColor;
  const Navbaritems({
  super.key, 
  required this.icon,
  required this.label,
  required this.onTap,
  this.labelColor
  });



  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: TextStyle(color: labelColor),),
      onTap: onTap,
    );
  }
}
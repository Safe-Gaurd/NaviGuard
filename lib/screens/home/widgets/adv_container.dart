import 'package:flutter/material.dart';

class AdvContainer extends StatelessWidget {

  final String image;

  const AdvContainer({
    super.key,
    required this.image
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(image),
        fit: BoxFit.cover, 
      ),
      borderRadius: BorderRadius.all(Radius.circular(30))
      )
    );
  }
}
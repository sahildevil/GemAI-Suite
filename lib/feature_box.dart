import 'package:assistant/pallete.dart';
import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final Color colour;
  final String headertext;
  final String desctext;
  const FeatureBox({
    super.key,
    required this.colour,
    required this.headertext,
    required this.desctext,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500, // Set the fixed width for the FeatureBox
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 15, bottom: 20, right: 15),
          child: Column(
            // Align text to the start
            children: [
              Text(
                headertext,
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 10), // Add spacing between the header and description
              Text(
                desctext,
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.blackColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

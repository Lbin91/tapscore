import 'package:flutter/material.dart';

class ScoreBox extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final bool hasServe;
  final int score;
  final VoidCallback onTap;

  const ScoreBox({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.hasServe,
    required this.score,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasServe ? Colors.yellow : borderColor,
            width: hasServe ? 4.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

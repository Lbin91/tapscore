import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SportCard extends StatelessWidget {
  final String sportName;
  final String sportIcon;
  final VoidCallback onTap;

  const SportCard({
    Key? key,
    required this.sportName,
    required this.sportIcon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sportIcon,
              style: TextStyle(fontSize: 42),
            ),
            SizedBox(height: 12),
            Text(
              sportName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

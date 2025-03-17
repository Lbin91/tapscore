import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_colors.dart';

class OptionCard extends StatelessWidget {
  final String optionName;
  final String optionIcon;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.optionName,
    required this.optionIcon,
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
              optionIcon,
              style: TextStyle(fontSize: 42),
            ),
            SizedBox(height: 12),
            Text(
              optionName.tr(),
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

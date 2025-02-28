import 'package:flutter/material.dart';
import '../widgets/sport_card.dart';
import '../models/sports.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import '../screens/option_screen.dart';

class MainScreen extends StatelessWidget {
  final List<Sport> sports = [
    Sport(
      id: 21,
      name: '탁구',
      icon: '🏓',
      maxRound: 5,
      scorePerRound: 11,
    ),
    Sport(
      id: 2,
      name: '피클볼',
      icon: '🥒',
      maxRound: 3,
      scorePerRound: 11,
    ),
    Sport(
      id: 3,
      name: '배드민턴',
      icon: '🏸',
      maxRound: 3,
      scorePerRound: 21,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('TapScore',
            style: TextStyle(
              color: AppColors.subMainTitleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: AppColors.subMainColor,
        elevation: 4.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  return SportCard(
                    sportName: sports[index].name,
                    sportIcon: sports[index].icon,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OptionScreen(
                            sport: sports[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          const BannerAdWidget(type: BannerAdType.main),
        ],
      ),
    );
  }
}

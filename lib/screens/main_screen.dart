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

  void _navigateToOptionScreen(BuildContext context, Sport sport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionScreen(
          originalSport: sport,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 통해 하단 패딩값 가져오기
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                      _navigateToOptionScreen(context, sports[index]);
                    },
                  );
                },
              ),
            ),
          ),
          Column(
            children: [
              const BannerAdWidget(type: BannerAdType.main),
              SizedBox(height: bottomPadding), // 하단 SafeArea 영역만큼 패딩 추가
            ],
          ),
        ],
      ),
    );
  }
}

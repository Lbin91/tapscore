import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../widgets/sport_card.dart';
import '../models/sports.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import '../screens/option_screen.dart';

// 앱의 메인 화면을 구성하는 클래스
// 지원하는 스포츠 종목들을 그리드 형태로 표시하고 광고를 포함
class MainScreen extends StatelessWidget {
  // 지원하는 스포츠 종목 리스트 정의
  final List<Sport> sports = [
    Sport.withOfficialSettings(SportType.tableTennis),
    Sport.withOfficialSettings(SportType.pickleball),
    Sport.withOfficialSettings(SportType.badminton),
  ];

  // 선택한 스포츠의 옵션 설정 화면으로 이동하는 메소드
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
    // 기기의 하단 안전영역 크기를 계산하여 광고 배너 위치 조정
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
          // 스포츠 종목 그리드 영역
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2열 그리드 레이아웃
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // 정사각형 카드
                ),
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  return SportCard(
                    sportName: sports[index].translatedName,
                    sportIcon: sports[index].icon,
                    onTap: () {
                      _navigateToOptionScreen(context, sports[index]);
                    },
                  );
                },
              ),
            ),
          ),
          // 광고 배너 영역
          Column(
            children: [
              const BannerAdWidget(type: BannerAdType.main),
              SizedBox(height: bottomPadding), // 하단 안전영역 패딩 적용
            ],
          ),
        ],
      ),
    );
  }
}

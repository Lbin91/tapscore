import 'package:flutter/material.dart';
import '../widgets/option_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../theme/app_colors.dart';
import '../models/score_option.dart';

class OptionScreen extends StatelessWidget {
  final String sportName; // 선택된 스포츠 이름

  const OptionScreen({
    Key? key,
    required this.sportName,
  }) : super(key: key);

  final List<ScoreOption> options = const [
    ScoreOption(
      id: 'official',
      name: '공식 규칙',
      icon: '📋',
      description: '공식 규칙에 따라 점수를 기록합니다.',
    ),
    ScoreOption(
      id: 'custom',
      name: '커스텀',
      icon: '⚙️',
      description: '원하는 방식으로 점수를 기록합니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildOptionCards(context),
          ),
          SizedBox(height: 8),
          const BannerAdWidget(type: BannerAdType.detail),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '$sportName 점수 방식',
        style: TextStyle(
          color: AppColors.subMainTitleColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.subMainColor,
      elevation: 4.0,
      iconTheme: IconThemeData(color: Colors.white), // 뒤로가기 버튼 색상
    );
  }

  Widget _buildOptionCards(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard(context, options[0]),
            SizedBox(width: 18),
            _buildOptionCard(context, options[1]),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, ScoreOption option) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OptionCard(
          optionName: option.name,
          optionIcon: option.icon,
          onTap: () => _showOptionSelectedSnackBar(context, option),
        ),
      ),
    );
  }

  void _showOptionSelectedSnackBar(BuildContext context, ScoreOption option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${option.name} 선택됨'),
        backgroundColor: AppColors.subMainColor,
      ),
    );
  }
}

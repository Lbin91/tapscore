import 'package:flutter/material.dart';
import '../widgets/option_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../theme/app_colors.dart';
import '../models/score_option.dart';
import '../models/sports.dart';
import '../widgets/score_settings_dialog.dart';

class OptionScreen extends StatelessWidget {
  final Sport sport; // 선택된 스포츠 객체

  const OptionScreen({
    Key? key,
    required this.sport,
  }) : super(key: key);

  final List<ScoreOption> options = const [
    ScoreOption(
      id: 'official',
      name: '공식 규칙',
      icon: '📋',
      description: '공식 규칙에 따라 점수를 기록합니다.',
    ),
    ScoreOption(
      id: 'single',
      name: '단일 라운드',
      icon: '1️⃣',
      description: '단일 라운드로 게임을 진행합니다.',
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
      body: _buildBody(context),
    );
  }

  // 메인 화면의 body를 구성하는 메소드
  // 옵션 카드 목록과 광고 배너를 포함
  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildOptionCards(context),
        ),
        SizedBox(height: 8),
        const BannerAdWidget(type: BannerAdType.detail),
      ],
    );
  }

  // 앱바를 구성하는 메소드
  // 스포츠 이름과 뒤로가기 버튼을 포함한 상단바 구성
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      backgroundColor: AppColors.subMainColor,
      elevation: 4.0,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  // 앱바의 타이틀을 구성하는 메소드
  // 스포츠 이름과 점수 방식 텍스트를 표시
  Widget _buildAppBarTitle() {
    return Text(
      '${sport.name} 점수 방식',
      style: TextStyle(
        color: AppColors.subMainTitleColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 옵션 카드들의 전체 레이아웃을 구성하는 메소드
  // 패딩과 카드 배치를 담당
  Widget _buildOptionCards(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Center(
        child: Column(
          children: [
            _buildOptionCardRow(context),
            SizedBox(height: 18),
            _buildSingleOptionCard(context),
          ],
        ),
      ),
    );
  }

  // 개별 옵션 카드를 구성하는 메소드
  // 카드의 비율과 터치 이벤트 처리를 담당
  Widget _buildOptionCard(BuildContext context, ScoreOption option,
      {bool useExpanded = true}) {
    Widget card = AspectRatio(
      aspectRatio: 1,
      child: OptionCard(
        optionName: option.name,
        optionIcon: option.icon,
        onTap: () => _handleOptionSelected(context, option),
      ),
    );

    return useExpanded ? Expanded(child: card) : card;
  }

  // 첫 번째 줄의 옵션 카드들을 구성하는 메소드
  // 공식 규칙과 단일 라운드 카드를 가로로 배치
  Widget _buildOptionCardRow(BuildContext context) {
    return Row(
      children: [
        _buildOptionCard(context, options[0]),
        SizedBox(width: 18),
        _buildOptionCard(context, options[1]),
      ],
    );
  }

  // 두 번째 줄의 단일 옵션 카드를 구성하는 메소드
  // 커스텀 옵션 카드를 화면 절반 크기로 배치
  Widget _buildSingleOptionCard(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 36) / 2,
      child: _buildOptionCard(context, options[2], useExpanded: false),
    );
  }

  // 옵션 선택 시 스낵바를 표시하는 메소드
  // 선택된 옵션의 이름과 함께 알림을 표시
  void _showOptionSelectedSnackBar(BuildContext context, ScoreOption option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${option.name} 설정이 적용되었습니다.'),
        backgroundColor: AppColors.subMainColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _handleOptionSelected(BuildContext context, ScoreOption option) {
    // 선택된 옵션에 따라 설정 팝업 표시
    _showSettingsDialog(context, option);
  }

  void _showSettingsDialog(BuildContext context, ScoreOption option) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => ScoreSettingsDialog(
        sport: sport,
        option: option,
        onSettingsChanged: (maxRound, scorePerRound) {
          sport.updateRoundSettings(
            newMaxRound: maxRound,
            newScorePerRound: scorePerRound,
          );
          _showOptionSelectedSnackBar(context, option);
        },
      ),
    );
  }
}

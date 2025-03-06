import 'package:flutter/material.dart';
import '../widgets/option_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../theme/app_colors.dart';
import '../models/score_option.dart';
import '../models/sports.dart';
import '../widgets/score_settings_dialog.dart';

class OptionScreen extends StatefulWidget {
  final Sport originalSport; // 원본 스포츠 객체

  const OptionScreen({
    Key? key,
    required this.originalSport,
  }) : super(key: key);

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  late Sport sport; // 작업용 복사본 스포츠 객체

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
  void initState() {
    super.initState();
    // 원본 Sport 객체의 복사본 생성
    _createSportCopy();
  }

  // 원본 Sport 객체로부터 복사본 생성
  void _createSportCopy() {
    sport = Sport(
      name: widget.originalSport.name,
      icon: widget.originalSport.icon,
      id: widget.originalSport.id,
      maxRound: widget.originalSport.maxRound,
      scorePerRound: widget.originalSport.scorePerRound,
    );

    // 종목별 기본값 설정
    _setDefaultSettings();
  }

  // 종목별 기본 설정 적용
  void _setDefaultSettings() {
    // 스포츠에 따라 기본 설정 초기화
    if (sport.name == '배드민턴') {
      sport.updateRoundSettings(newMaxRound: 3, newScorePerRound: 21);
    } else if (sport.name == '탁구') {
      sport.updateRoundSettings(newMaxRound: 5, newScorePerRound: 11);
    } else if (sport.name == '피클볼') {
      sport.updateRoundSettings(newMaxRound: 3, newScorePerRound: 11);
    } else {
      sport.updateRoundSettings(newMaxRound: 3, newScorePerRound: 21);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 설정 초기화
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(context),
      ),
    );
  }

  // 메인 화면의 body를 구성하는 메소드
  // 옵션 카드 목록과 광고 배너를 포함
  Widget _buildBody(BuildContext context) {
    // MediaQuery를 통해 하단 패딩값 가져오기
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        Expanded(
          child: _buildOptionCards(context),
        ),
        Column(
          children: [
            const BannerAdWidget(type: BannerAdType.detail),
            SizedBox(height: bottomPadding), // 하단 SafeArea 영역만큼 패딩 추가
          ],
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬을 위해 추가
        children: [
          _buildOptionCardRow(context),
          SizedBox(height: 18),
          _buildSingleOptionCard(context),
        ],
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
  // 커스텀 옵션 카드를 화면 절반 크기로 왼쪽 정렬
  Widget _buildSingleOptionCard(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // 왼쪽 정렬
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 36) / 2,
        child: _buildOptionCard(context, options[2], useExpanded: false),
      ),
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
    // 선택된 옵션에 따라 Sport 객체의 기본값 재설정
    switch (option.id) {
      case 'official':
        // 공식 규칙: 종목별 기본값 설정
        if (sport.name == '배드민턴') {
          sport.updateRoundSettings(newMaxRound: 3, newScorePerRound: 21);
        } else if (sport.name == '탁구') {
          sport.updateRoundSettings(newMaxRound: 5, newScorePerRound: 11);
        } else if (sport.name == '피클볼') {
          sport.updateRoundSettings(newMaxRound: 3, newScorePerRound: 11);
        } else {
          sport.updateRoundSettings(newMaxRound: 3, newScorePerRound: 21);
        }
        break;
      case 'single':
        // 단일 라운드: 종목별 점수 설정
        if (sport.name == '배드민턴') {
          sport.updateRoundSettings(newMaxRound: 1, newScorePerRound: 21);
        } else if (sport.name == '탁구' || sport.name == '피클볼') {
          sport.updateRoundSettings(newMaxRound: 1, newScorePerRound: 11);
        } else {
          sport.updateRoundSettings(newMaxRound: 1, newScorePerRound: 21);
        }
        break;
      case 'custom':
        // 커스텀: 현재 값 유지
        break;
    }

    // 선택된 옵션에 따라 설정 팝업 표시
    _showSettingsDialog(context, option);
  }

  void _showSettingsDialog(BuildContext context, ScoreOption option) {
    // 커스텀 옵션인 경우에만 사용자가 설정 가능하도록 함
    bool allowCustomSettings = option.id == 'custom';

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => ScoreSettingsDialog(
        sport: sport,
        option: option,
        allowCustomSettings: allowCustomSettings,
        onSettingsChanged: (maxRound, scorePerRound) {
          setState(() {
            sport.updateRoundSettings(
              newMaxRound: maxRound,
              newScorePerRound: scorePerRound,
            );
          });
          _showOptionSelectedSnackBar(context, option);
        },
      ),
    );
  }
}

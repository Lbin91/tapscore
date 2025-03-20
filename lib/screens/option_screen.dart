import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/option_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../theme/app_colors.dart';
import '../models/score_option.dart';
import '../models/sports.dart';
import '../widgets/score_settings_dialog.dart';

// 스포츠 점수 설정 화면을 구성하는 위젯
// 공식 규칙, 단일 라운드, 커스텀 설정 등의 옵션을 제공하는 화면
class OptionScreen extends StatefulWidget {
  final Sport originalSport;

  const OptionScreen({
    Key? key,
    required this.originalSport,
  }) : super(key: key);

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

// OptionScreen의 상태를 관리하는 클래스
// 스포츠 설정 옵션의 상태 관리 및 UI 구성을 담당
class _OptionScreenState extends State<OptionScreen> {
  late Sport sport;
  late Sport initialSport; // 초기 설정을 저장할 변수 추가

  // 점수 설정 옵션 목록 정의
  // 공식 규칙, 단일 라운드, 커스텀 설정의 기본 정보를 포함
  final List<ScoreOption> options = const [
    ScoreOption(
      id: 'official',
      name: 'options.official.name',
      icon: '📋',
      description: 'options.official.description',
    ),
    ScoreOption(
      id: 'single',
      name: 'options.single.name',
      icon: '1️⃣',
      description: 'options.single.description',
    ),
    ScoreOption(
      id: 'custom',
      name: 'options.custom.name',
      icon: '⚙️',
      description: 'options.custom.description',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _createSportCopy();
  }

  // 원본 스포츠 객체의 복사본을 생성하는 메소드
  // 설정 변경 시 원본 데이터 보호를 위해 사용
  void _createSportCopy() {
    sport = widget.originalSport.copyWith();
    // 초기 설정 저장
    initialSport = widget.originalSport.copyWith();
    _setDefaultSettings();
  }

  // 스포츠 종목별 기본 설정을 적용하는 메소드
  // 각 종목의 공식 규칙에 따른 라운드 수와 점수를 설정
  void _setDefaultSettings() {
    sport.applyDefaultSettings(GameSettingType.official);
  }

  // 설정 변경 여부를 확인하는 메소드
  bool _hasSettingsChanged() {
    return sport.maxRound != initialSport.maxRound ||
        sport.scorePerRound != initialSport.scorePerRound;
  }

  // 설정 변경사항을 적용하고 스낵바를 표시하는 메소드
  // 설정 변경 후 사용자에게 피드백을 제공
  void _applySettingsAndShowFeedback(
    BuildContext context,
    ScoreOption option,
    int maxRound,
    int scorePerRound,
  ) {
    setState(() {
      sport.updateRoundSettings(
        newMaxRound: maxRound,
        newScorePerRound: scorePerRound,
      );
    });
    _showOptionSelectedSnackBar(context, option);
  }

  // 설정 다이얼로그의 UI를 구성하는 메소드
  // 옵션에 따라 다이얼로그의 내용과 동작을 설정
  Widget _buildSettingsDialog(
    BuildContext context,
    ScoreOption option,
    bool allowCustomSettings,
  ) {
    return ScoreSettingsDialog(
      sport: sport,
      option: option,
      allowCustomSettings: allowCustomSettings,
      onSettingsChanged: (maxRound, scorePerRound) {
        _applySettingsAndShowFeedback(
          context,
          option,
          maxRound,
          scorePerRound,
        );
      },
    );
  }

  // 설정 다이얼로그를 표시하는 메소드
  // 선택된 옵션에 따라 설정 가능 여부를 결정하고 다이얼로그 표시
  void _showSettingsDialog(BuildContext context, ScoreOption option) {
    bool allowCustomSettings = option.id == 'custom';

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => _buildSettingsDialog(
        context,
        option,
        allowCustomSettings,
      ),
    );
  }

  // 화면 종료 처리를 담당하는 메소드
  // 설정 변경 여부를 확인하고 적절한 처리를 수행
  Future<void> _handleScreenExit(bool didPop) async {
    if (didPop) return;

    // TODO: Navigator.pop()의 두 번째 파라미터로 변경된 sport 객체를 전달하여
    // 이전 화면에서 설정 변경사항을 반영할 수 있음
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // TODO: onPopInvokedWithResult를 통해 변경된 설정 값을 이전 화면으로 전달할 수 있음
      // result 파라미터를 활용하여 sport 객체의 변경된 설정을 전달하고, 이전 화면에서 처리하도록 개선 가능
      onPopInvokedWithResult: (didPop, result) async {
        await _handleScreenExit(didPop);
        return;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(context),
      ),
    );
  }

  // 화면의 본문을 구성하는 메소드
  // 옵션 카드 목록과 하단 광고 배너를 포함
  Widget _buildBody(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Column(
      children: [
        Expanded(
          child: _buildOptionCards(context),
        ),
        Column(
          children: [
            const BannerAdWidget(type: BannerAdType.detail),
            SizedBox(height: bottomPadding),
          ],
        ),
      ],
    );
  }

  // 상단 앱바를 구성하는 메소드
  // 스포츠 이름과 설정 타이틀을 표시
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      backgroundColor: AppColors.subMainColor,
      elevation: 4.0,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  // 앱바 타이틀을 구성하는 메소드
  // 현재 선택된 스포츠의 이름을 다국어 지원하여 표시
  Widget _buildAppBarTitle() {
    return Text(
      'dialog.settings.title'.tr(args: [sport.name.tr()]),
      style: TextStyle(
        color: AppColors.subMainTitleColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 옵션 카드들의 레이아웃을 구성하는 메소드
  // 공식 규칙, 단일 라운드, 커스텀 설정 카드를 배치
  Widget _buildOptionCards(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionCardRow(context),
          SizedBox(height: 18),
          _buildSingleOptionCard(context),
        ],
      ),
    );
  }

  // 개별 옵션 카드를 생성하는 메소드
  // 카드의 크기와 터치 이벤트를 설정
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
  // 공식 규칙과 단일 라운드 옵션을 가로로 배치
  Widget _buildOptionCardRow(BuildContext context) {
    return Row(
      children: [
        _buildOptionCard(context, options[0]),
        SizedBox(width: 18),
        _buildOptionCard(context, options[1]),
      ],
    );
  }

  // 두 번째 줄의 커스텀 옵션 카드를 구성하는 메소드
  // 화면 절반 크기로 왼쪽에 배치
  Widget _buildSingleOptionCard(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 36) / 2,
        child: _buildOptionCard(context, options[2], useExpanded: false),
      ),
    );
  }

  // 옵션 선택 시 알림 메시지를 표시하는 메소드
  // 선택된 설정이 적용되었음을 사용자에게 알림
  void _showOptionSelectedSnackBar(BuildContext context, ScoreOption option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('snackbar.settingsApplied'.tr(args: [option.name.tr()])),
        backgroundColor: AppColors.subMainColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  // 옵션 선택 시 처리를 담당하는 메소드
  // 선택된 옵션에 따라 스포츠 설정을 업데이트하고 다이얼로그 표시
  void _handleOptionSelected(BuildContext context, ScoreOption option) {
    switch (option.id) {
      case 'official':
        sport.applyDefaultSettings(GameSettingType.official);
        break;
      case 'single':
        sport.applyDefaultSettings(GameSettingType.single);
        break;
      case 'custom':
        break;
    }
    _showSettingsDialog(context, option);
  }
}

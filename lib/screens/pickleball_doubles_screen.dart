import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode를 위한 import
import 'dart:math' as math; // math 함수 사용을 위한 import
import '../models/sports.dart';
import '../models/game_action.dart';
import '../widgets/score_box.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart'; // AdConfig import 추가
import 'package:easy_localization/easy_localization.dart';

// 피클볼 복식 게임 화면 클래스
// 복식 규칙에 맞는 서브 처리와 점수 계산 로직을 구현
class PickleballDoublesScreen extends StatefulWidget {
  final Sport sport;
  final int maxRound;
  final int scorePerRound;

  const PickleballDoublesScreen({
    Key? key,
    required this.sport,
    required this.maxRound,
    required this.scorePerRound,
  }) : super(key: key);

  @override
  State<PickleballDoublesScreen> createState() =>
      _PickleballDoublesScreenState();
}

class _PickleballDoublesScreenState extends State<PickleballDoublesScreen> {
  // 테이블 점수 상태
  int redScore = 0;
  int blueScore = 0;

  // 현재 서브권을 가진 테이블 (-1: 아직 없음, 0: 레드, 1: 블루)
  int serverTeamIndex = -1;

  // 현재 서브 플레이어 인덱스 (0: 첫 번째 플레이어, 1: 두 번째 플레이어)
  int serverPlayerIndex = 0;

  // 각 팀의 현재 서브 플레이어 인덱스 (0 또는 1)
  int redTeamServerIndex = 0;
  int blueTeamServerIndex = 0;

  // 게임 액션 기록
  List<GameAction> gameActions = [];

  // 현재 라운드
  int currentRound = 1;

  // 플레이어 정보 추가
  // player1과 player2는 레드 팀, player3과 player4는 블루 팀
  int redTeamSetWins = 0; // 레드 팀의 세트 승리 횟수
  int blueTeamSetWins = 0; // 블루 팀의 세트 승리 횟수

  // 전면 광고 관련 변수
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: kDebugMode
          ? AdConfig.testInterstitialAdUnitId
          : AdConfig.releaseDetailInterstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('전면 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${'game.title'.tr(args: [
              widget.sport.translatedName
            ])} (${'gameType.doubles_short'.tr()})',
        style: TextStyle(
          color: AppColors.mainTitleColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.mainColor,
      elevation: 4.0,
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Text(
              '${'game.round_short'.tr()} $currentRound/${widget.maxRound}',
              style: TextStyle(
                color: AppColors.mainTitleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    // MediaQuery를 통해 하단 패딩값 가져오기
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildScoreArea(),
                SizedBox(height: 24),
                _buildUndoButton(),
              ],
            ),
          ),
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

  Widget _buildScoreArea() {
    // TODO: 피클볼 복식 규칙에 맞는 UI 구성
    // 현재는 임시 UI로 구현
    return Center(
      child: Text(
        '피클볼 복식 게임 화면 - 개발 중',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUndoButton() {
    return ElevatedButton(
      onPressed: gameActions.isEmpty ? null : _undoLastAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainColor,
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        elevation: 0,
        disabledBackgroundColor: Colors.grey[300],
      ),
      child: Icon(
        Icons.refresh,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  // 마지막 액션 취소
  void _undoLastAction() {
    // TODO: 피클볼 복식 규칙에 맞는 되돌리기 로직 구현
    if (gameActions.isEmpty) return;

    setState(() {
      // 마지막 액션 제거
      gameActions.removeLast();

      if (gameActions.isEmpty) {
        // 더 이상 액션이 없으면 초기 상태로
        redScore = 0;
        blueScore = 0;
        serverTeamIndex = -1;
        serverPlayerIndex = 0;
        redTeamServerIndex = 0;
        blueTeamServerIndex = 0;
      } else {
        // 마지막 액션의 상태로 복원
        // TODO: 복식 게임에 맞게 상태 복원 로직 구현
      }
    });
  }
}

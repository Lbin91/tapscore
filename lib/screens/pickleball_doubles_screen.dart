import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode를 위한 import
import 'dart:math' as math; // math 함수 사용을 위한 import
import '../models/sports.dart';
import '../models/game_action.dart';
import '../widgets/doubles_score_box.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import 'package:easy_localization/easy_localization.dart';

// 피클볼 복식 GameAction 클래스 확장
class DoublesGameAction extends GameAction {
  final int redTeamServerIndex;
  final int blueTeamServerIndex;
  final int serverTeamIndex;
  final int serverPlayerIndex;

  DoublesGameAction({
    required int teamIndex,
    required bool isScoreAction,
    required int redScore,
    required int blueScore,
    required this.redTeamServerIndex,
    required this.blueTeamServerIndex,
    required this.serverTeamIndex,
    required this.serverPlayerIndex,
  }) : super(
          teamIndex: teamIndex,
          isScoreAction: isScoreAction,
          redScore: redScore,
          blueScore: blueScore,
          serverIndex: serverTeamIndex,
        );
}

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
  List<DoublesGameAction> gameActions = [];

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
        // 피클볼 복식 점수 표시 (0-0-2 형식)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Row(
              children: [
                // 라운드 표시
                Text(
                  '${'game.round_short'.tr()} $currentRound/${widget.maxRound}',
                  style: TextStyle(
                    color: AppColors.mainTitleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                // 점수 형식 표시 (서브팀 점수-상대팀 점수-서브자 순서)
                if (serverTeamIndex != -1)
                  Text(
                    'game.serve.score'.tr(args: [
                      serverTeamIndex == 0 ? '$redScore' : '$blueScore',
                      serverTeamIndex == 0 ? '$blueScore' : '$redScore',
                      '${serverPlayerIndex + 1}',
                    ]),
                    style: TextStyle(
                      color: AppColors.mainTitleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
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
    return Expanded(
      child: Column(
        children: [
          // 라운드 스코어 표시
          _buildRoundScores(),
          SizedBox(height: 16),
          // 점수 테이블
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // 화면 높이의 40%
            child: Row(
              children: [
                Expanded(
                  child: DoublesScoreBox(
                    backgroundColor: Color(0xFFFFCDD2),
                    borderColor: Colors.red.shade300,
                    hasServe: serverTeamIndex == 0,
                    score: redScore,
                    onTap: () => _handleTeamTap(0),
                    serverPlayerIndex: redTeamServerIndex,
                    isServingTeam: serverTeamIndex == 0,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DoublesScoreBox(
                    backgroundColor: Color(0xFFBBDEFB),
                    borderColor: Colors.blue.shade300,
                    hasServe: serverTeamIndex == 1,
                    score: blueScore,
                    onTap: () => _handleTeamTap(1),
                    serverPlayerIndex: blueTeamServerIndex,
                    isServingTeam: serverTeamIndex == 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundScores() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                'game.table.red'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade300,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'game.player.short.p1'.tr() +
                    '/' +
                    'game.player.short.p2'.tr() +
                    ' (${'game.player.wins'.tr(args: [
                          redTeamSetWins.toString()
                        ])})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade300,
                ),
              ),
              if (serverTeamIndex == 0)
                Text(
                  serverPlayerIndex == 0
                      ? 'game.serve.first'.tr()
                      : 'game.serve.second'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade300,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'game.table.blue'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade300,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'game.player.short.p1'.tr() +
                    '/' +
                    'game.player.short.p2'.tr() +
                    ' (${'game.player.wins'.tr(args: [
                          blueTeamSetWins.toString()
                        ])})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade300,
                ),
              ),
              if (serverTeamIndex == 1)
                Text(
                  serverPlayerIndex == 0
                      ? 'game.serve.first'.tr()
                      : 'game.serve.second'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade300,
                  ),
                ),
            ],
          ),
        ),
      ],
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

  // 팀 탭 처리 로직
  void _handleTeamTap(int teamIndex) {
    if (serverTeamIndex == -1) {
      // 첫 탭은 서브권 설정 (복식 게임에서 첫 번째 서브 플레이어도 설정)
      setState(() {
        serverTeamIndex = teamIndex;
        serverPlayerIndex = 0; // 첫 번째 서브 플레이어로 시작

        if (teamIndex == 0) {
          redTeamServerIndex = 0;
        } else {
          blueTeamServerIndex = 0;
        }

        // 게임 액션 기록
        gameActions.add(DoublesGameAction(
          teamIndex: teamIndex,
          isScoreAction: false,
          redScore: redScore,
          blueScore: blueScore,
          redTeamServerIndex: redTeamServerIndex,
          blueTeamServerIndex: blueTeamServerIndex,
          serverTeamIndex: serverTeamIndex,
          serverPlayerIndex: serverPlayerIndex,
        ));
      });
      return;
    }

    // 서브권 설정 후 피클볼 복식 규칙에 따라 처리
    _handlePickleballDoublesRule(teamIndex);

    // 라운드 승리 체크
    _checkRoundWin();
  }

  // 피클볼 복식 규칙: 서브권을 가진 팀이 이길 때만 점수가 쌓이고 서브 플레이어가 두 명 모두 서브한 후 서브권 이동
  void _handlePickleballDoublesRule(int teamIndex) {
    setState(() {
      bool scoreAdded = false;

      // 서브권을 가진 팀이 이긴 경우에만 점수 추가
      if (serverTeamIndex == teamIndex) {
        if (teamIndex == 0) {
          redScore++;
        } else {
          blueScore++;
        }
        scoreAdded = true;

        // 서브권을 가진 팀이 이겼을 때 서브 플레이어 변경
        if (scoreAdded && ((redScore + blueScore) > 1)) {
          if (serverTeamIndex == 0) {
            // 레드팀이 서브권을 가진 경우 서브 플레이어 변경
            redTeamServerIndex = (redTeamServerIndex + 1) % 2;
            serverPlayerIndex = redTeamServerIndex;
          } else {
            // 블루팀이 서브권을 가진 경우 서브 플레이어 변경
            blueTeamServerIndex = (blueTeamServerIndex + 1) % 2;
            serverPlayerIndex = blueTeamServerIndex;
          }
        }
      } else {
        // 서브권이 없는 팀이 이기면 서브권만 변경
        serverTeamIndex = teamIndex;

        // 서브권이 변경될 때 해당 팀의 현재 서브 플레이어를 기준으로 설정
        if (teamIndex == 0) {
          serverPlayerIndex = redTeamServerIndex;
        } else {
          serverPlayerIndex = blueTeamServerIndex;
        }
      }

      // 게임 액션 기록 (복식 게임 액션)
      gameActions.add(DoublesGameAction(
        teamIndex: teamIndex,
        isScoreAction: scoreAdded,
        redScore: redScore,
        blueScore: blueScore,
        redTeamServerIndex: redTeamServerIndex,
        blueTeamServerIndex: blueTeamServerIndex,
        serverTeamIndex: serverTeamIndex,
        serverPlayerIndex: serverPlayerIndex,
      ));
    });
  }

  // 마지막 액션 취소
  void _undoLastAction() {
    if (gameActions.isEmpty) return;

    setState(() {
      // 마지막 액션 제거
      DoublesGameAction lastAction = gameActions.removeLast();

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
        DoublesGameAction previousAction = gameActions.last;
        redScore = previousAction.redScore;
        blueScore = previousAction.blueScore;
        serverTeamIndex = previousAction.serverTeamIndex;
        serverPlayerIndex = previousAction.serverPlayerIndex;
        redTeamServerIndex = previousAction.redTeamServerIndex;
        blueTeamServerIndex = previousAction.blueTeamServerIndex;
      }
    });
  }

  void _checkRoundWin() {
    if (redScore >= widget.scorePerRound || blueScore >= widget.scorePerRound) {
      if ((redScore >= widget.scorePerRound && redScore - blueScore >= 2) ||
          (blueScore >= widget.scorePerRound && blueScore - redScore >= 2)) {
        // 라운드 승자 기록 처리
        bool isRedWinner = redScore > blueScore;
        _updateSetWins(isRedWinner);

        // 광고 표시 후 결과 다이얼로그 표시
        if (_isInterstitialAdReady) {
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // 다음 광고 로드
              _processRoundEnd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
              _processRoundEnd();
            },
          );
          _interstitialAd?.show();
        } else {
          _processRoundEnd();
        }
      }
    }
  }

  // 라운드가 끝난 후 게임 종료 여부를 체크하고 적절한 다이얼로그 표시
  void _processRoundEnd() {
    // 과반수 승리 체크
    int requiredWins = (widget.maxRound / 2).ceil();

    // 게임 종료 조건 확인
    bool isGameOver = redTeamSetWins >= requiredWins ||
        blueTeamSetWins >= requiredWins ||
        currentRound >= widget.maxRound;

    if (isGameOver) {
      // 게임 종료 조건 충족 시 바로 게임 종료 다이얼로그 표시
      _showRoundEndAndGameOverDialog();
    } else {
      // 게임이 끝나지 않았으면 일반 라운드 종료 다이얼로그 표시
      _showRoundEndDialog();
    }
  }

  // 이번 라운드의 승자에게 세트 승리 추가
  void _updateSetWins(bool isRedWinner) {
    if (isRedWinner) {
      redTeamSetWins++;
    } else {
      blueTeamSetWins++;
    }
  }

  // 라운드 종료와 동시에 게임 종료를 알리는 다이얼로그
  void _showRoundEndAndGameOverDialog() {
    String tableWinner =
        redScore > blueScore ? 'game.table.red'.tr() : 'game.table.blue'.tr();
    String finalWinner = redTeamSetWins > blueTeamSetWins
        ? 'game.table.red'.tr()
        : 'game.table.blue'.tr();
    int winnerSets = math.max(redTeamSetWins, blueTeamSetWins);
    int loserSets = math.min(redTeamSetWins, blueTeamSetWins);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('dialog.gameOver.title'.tr()),
        content: Text(
          'dialog.gameOver.content'.tr(args: [
            finalWinner,
            winnerSets.toString(),
            loserSets.toString(),
            currentRound.toString(),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
            child: Text('dialog.gameOver.confirm'.tr()),
          ),
        ],
      ),
    );
  }

  void _showRoundEndDialog() {
    String winner =
        redScore > blueScore ? 'game.table.red'.tr() : 'game.table.blue'.tr();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('dialog.roundEnd.title'.tr()),
        content: Text('dialog.roundEnd.content'
            .tr(args: [winner, currentRound.toString()])),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showTableChangeDialog();
            },
            child: Text('dialog.roundEnd.next'.tr()),
          ),
        ],
      ),
    );
  }

  void _showTableChangeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'dialog.tableChange.title'.tr(),
          style: TextStyle(
            color: AppColors.mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('dialog.tableChange.content'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNextRound(false);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
            ),
            child: Text(
              'dialog.tableChange.no'.tr(),
              style: TextStyle(color: AppColors.subMainColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNextRound(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              elevation: 0,
            ),
            child: Text(
              'dialog.tableChange.yes'.tr(),
              style: TextStyle(color: AppColors.mainTitleColor),
            ),
          ),
        ],
      ),
    );
  }

  void _startNextRound(bool switchTables) {
    setState(() {
      // 점수 초기화
      redScore = 0;
      blueScore = 0;
      serverTeamIndex = -1;
      serverPlayerIndex = 0;
      redTeamServerIndex = 0;
      blueTeamServerIndex = 0;
      gameActions.clear();

      // 라운드 증가
      currentRound++;
    });
  }
}

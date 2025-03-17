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

class GameScreen extends StatefulWidget {
  final Sport sport;
  final int maxRound;
  final int scorePerRound;

  const GameScreen({
    Key? key,
    required this.sport,
    required this.maxRound,
    required this.scorePerRound,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // 테이블 점수 상태
  int redScore = 0;
  int blueScore = 0;

  // 현재 서브권을 가진 테이블 (-1: 아직 없음, 0: 레드, 1: 블루)
  int serverIndex = -1;

  // 서브 카운트 (탁구에서 2번씩 서브를 번갈아 하기 위한 카운터)
  int serveCount = 0;

  // 게임 액션 기록
  List<GameAction> gameActions = [];

  // 현재 라운드
  int currentRound = 1;

  // 플레이어 정보 추가
  // player1은 처음에 레드 테이블에, player2는 블루 테이블에 배치
  int player1SetWins = 0; // 플레이어 1의 세트 승리 횟수
  int player2SetWins = 0; // 플레이어 2의 세트 승리 횟수

  // 플레이어 위치 추적 (0: 레드 테이블, 1: 블루 테이블)
  int player1TableIndex = 0; // 플레이어 1은 처음에 레드 테이블에 배치
  int player2TableIndex = 1; // 플레이어 2는 처음에 블루 테이블에 배치

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
        '${'game.title'.tr(args: [widget.sport.translatedName])}',
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
              '${'game.round'.tr()} $currentRound/${widget.maxRound}',
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
                  child: ScoreBox(
                    backgroundColor: Color(0xFFFFCDD2),
                    borderColor: Colors.red.shade300,
                    hasServe: serverIndex == 0,
                    score: redScore,
                    onTap: () => _handleTeamTap(0),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ScoreBox(
                    backgroundColor: Color(0xFFBBDEFB),
                    borderColor: Colors.blue.shade300,
                    hasServe: serverIndex == 1,
                    score: blueScore,
                    onTap: () => _handleTeamTap(1),
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
                player1TableIndex == 0
                    ? '${'game.player.one'.tr()} (${'game.player.wins'.tr(args: [
                            player1SetWins.toString()
                          ])})'
                    : '${'game.player.two'.tr()} (${'game.player.wins'.tr(args: [
                            player2SetWins.toString()
                          ])})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                player1TableIndex == 1
                    ? '${'game.player.one'.tr()} (${'game.player.wins'.tr(args: [
                            player1SetWins.toString()
                          ])})'
                    : '${'game.player.two'.tr()} (${'game.player.wins'.tr(args: [
                            player2SetWins.toString()
                          ])})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
    if (serverIndex == -1) {
      // 첫 탭은 서브권 설정
      setState(() {
        serverIndex = teamIndex;

        // 게임 액션 기록
        gameActions.add(GameAction(
          teamIndex: teamIndex,
          isScoreAction: false,
          redScore: redScore,
          blueScore: blueScore,
          serverIndex: serverIndex,
        ));
      });
      return;
    }

    // 서브권 설정 후, 스포츠별 규칙에 따라 처리
    switch (widget.sport.name) {
      case 'sports.badminton':
        _handleBadmintonRule(teamIndex);
        break;
      case 'sports.tableTennis':
        _handleTableTennisRule(teamIndex);
        break;
      case 'sports.pickleball':
        _handlePickleballRule(teamIndex);
        break;
      default:
        _handleDefaultRule(teamIndex);
    }

    // 라운드 승리 체크
    _checkRoundWin();
  }

  // 배드민턴 규칙: 이긴 사람이 서브권을 계속 가짐
  void _handleBadmintonRule(int teamIndex) {
    setState(() {
      // 이긴 팀의 점수 증가
      if (teamIndex == 0) {
        redScore++;
      } else {
        blueScore++;
      }

      // 서브권이 없는 팀이 점수를 얻으면 서브권이 변경됨
      if (serverIndex != teamIndex) {
        serverIndex = teamIndex;
      }

      // 게임 액션 기록
      gameActions.add(GameAction(
        teamIndex: teamIndex,
        isScoreAction: true,
        redScore: redScore,
        blueScore: blueScore,
        serverIndex: serverIndex,
      ));
    });
  }

  // 탁구 규칙: 2점마다 서브권이 변경됨
  void _handleTableTennisRule(int teamIndex) {
    setState(() {
      // 이긴 팀의 점수 증가
      if (teamIndex == 0) {
        redScore++;
      } else {
        blueScore++;
      }

      // 서브 카운트 증가 및 2점마다 서브권 변경
      serveCount++;
      if (serveCount == 2) {
        serverIndex = serverIndex == 0 ? 1 : 0;
        serveCount = 0;
      }

      // 게임 액션 기록
      gameActions.add(GameAction(
        teamIndex: teamIndex,
        isScoreAction: true,
        redScore: redScore,
        blueScore: blueScore,
        serverIndex: serverIndex,
      ));
    });
  }

  // 피클볼 규칙: 서브권을 가진 팀이 이길 때만 점수가 쌓임
  void _handlePickleballRule(int teamIndex) {
    setState(() {
      bool scoreAdded = false;

      // 서브권을 가진 팀이 이긴 경우에만 점수 추가
      if (serverIndex == teamIndex) {
        if (teamIndex == 0) {
          redScore++;
        } else {
          blueScore++;
        }
        scoreAdded = true;
      } else {
        // 서브권이 없는 팀이 이기면 서브권만 변경
        serverIndex = teamIndex;
      }

      // 게임 액션 기록
      gameActions.add(GameAction(
        teamIndex: teamIndex,
        isScoreAction: scoreAdded,
        redScore: redScore,
        blueScore: blueScore,
        serverIndex: serverIndex,
      ));
    });
  }

  // 기본 규칙: 이긴 팀의 점수만 증가
  void _handleDefaultRule(int teamIndex) {
    setState(() {
      // 이긴 팀의 점수 증가
      if (teamIndex == 0) {
        redScore++;
      } else {
        blueScore++;
      }

      // 게임 액션 기록
      gameActions.add(GameAction(
        teamIndex: teamIndex,
        isScoreAction: true,
        redScore: redScore,
        blueScore: blueScore,
        serverIndex: serverIndex,
      ));
    });
  }

  // 마지막 액션 취소
  void _undoLastAction() {
    if (gameActions.isEmpty) return;

    setState(() {
      // 마지막 액션 제거
      gameActions.removeLast();

      if (gameActions.isEmpty) {
        // 더 이상 액션이 없으면 초기 상태로
        redScore = 0;
        blueScore = 0;
        serverIndex = -1;
        serveCount = 0;
      } else {
        // 마지막 액션의 상태로 복원
        final lastAction = gameActions.last;
        redScore = lastAction.redScore;
        blueScore = lastAction.blueScore;
        serverIndex = lastAction.serverIndex;

        // 탁구인 경우 서브 카운트 조정 (구현이 복잡하므로 간단하게 처리)
        if (widget.sport.name == 'sports.tableTennis') {
          int totalScore = redScore + blueScore;
          serveCount = totalScore % 2;
        }
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
    bool isGameOver = player1SetWins >= requiredWins ||
        player2SetWins >= requiredWins ||
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
      // 레드 테이블에 있는 플레이어가 이김
      if (player1TableIndex == 0) {
        player1SetWins++;
      } else {
        player2SetWins++;
      }
    } else {
      // 블루 테이블에 있는 플레이어가 이김
      if (player1TableIndex == 1) {
        player1SetWins++;
      } else {
        player2SetWins++;
      }
    }
  }

  // 라운드 종료와 동시에 게임 종료를 알리는 다이얼로그
  void _showRoundEndAndGameOverDialog() {
    String tableWinner =
        redScore > blueScore ? 'game.table.red'.tr() : 'game.table.blue'.tr();
    String playerWinner = "";

    // 어떤 플레이어가 이겼는지 확인
    if (redScore > blueScore) {
      playerWinner = player1TableIndex == 0
          ? 'game.player.one'.tr()
          : 'game.player.two'.tr();
    } else {
      playerWinner = player1TableIndex == 1
          ? 'game.player.one'.tr()
          : 'game.player.two'.tr();
    }

    // 최종 승자
    String finalWinner = player1SetWins > player2SetWins
        ? 'game.player.one'.tr()
        : 'game.player.two'.tr();
    int winnerSets = math.max(player1SetWins, player2SetWins);
    int loserSets = math.min(player1SetWins, player2SetWins);

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
    String playerWinner = "";

    // 어떤 플레이어가 이겼는지 확인
    if (redScore > blueScore) {
      playerWinner = player1TableIndex == 0
          ? 'game.player.one'.tr()
          : 'game.player.two'.tr();
    } else {
      playerWinner = player1TableIndex == 1
          ? 'game.player.one'.tr()
          : 'game.player.two'.tr();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('dialog.roundEnd.title'.tr()),
        content: Text('dialog.roundEnd.content'
            .tr(args: [playerWinner, currentRound.toString()])),
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
      serveCount = 0;
      gameActions.clear();

      // 플레이어 위치 교체 (테이블 교체)
      if (switchTables) {
        // 플레이어 위치 교체
        player1TableIndex = player1TableIndex == 0 ? 1 : 0;
        player2TableIndex = player2TableIndex == 0 ? 1 : 0;

        // 서브권도 같이 이동
        if (serverIndex != -1) {
          // 서브권이 있었다면 서브권 유지하되 테이블은 변경
          serverIndex = serverIndex == 0 ? 1 : 0;
        }
      }

      // 라운드 증가
      currentRound++;
    });
  }
}

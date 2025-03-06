// 게임 내 액션을 기록하기 위한 모델 클래스
class GameAction {
  final int teamIndex; // 0: 왼쪽(레드), 1: 오른쪽(블루)
  final bool isScoreAction; // true: 점수 획득, false: 서브권 변경만
  final int redScore; // 액션 후 레드팀 점수
  final int blueScore; // 액션 후 블루팀 점수
  final int serverIndex; // 액션 후 서브권 보유 팀

  GameAction({
    required this.teamIndex,
    required this.isScoreAction,
    required this.redScore,
    required this.blueScore,
    required this.serverIndex,
  });
}

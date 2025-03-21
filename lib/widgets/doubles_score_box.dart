import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// 복식 게임을 위한 점수 박스 위젯
// 2명의 플레이어와 서브 상태를 표시할 수 있는 UI 구성
class DoublesScoreBox extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final bool hasServe;
  final int score;
  final VoidCallback onTap;
  final int serverPlayerIndex; // 0: 첫 번째 플레이어, 1: 두 번째 플레이어
  final bool isServingTeam; // 현재 서브권이 있는 팀인지 여부

  const DoublesScoreBox({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.hasServe,
    required this.score,
    required this.onTap,
    required this.serverPlayerIndex,
    required this.isServingTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasServe ? Colors.yellow : borderColor,
            width: hasServe ? 4.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라켓 아이콘 표시 (서브 표시)
            if (isServingTeam) _buildServeIndicator(),

            // 점수 표시
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // 팀 플레이어 표시
            _buildTeamPlayers(),
          ],
        ),
      ),
    );
  }

  // 서브권 표시 위젯
  Widget _buildServeIndicator() {
    // 첫 번째 서브 플레이어인 경우 라켓 하나, 두 번째 서브 플레이어인 경우 라켓 두 개 표시
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            color: Colors.white,
            size: 28,
          ),
          if (serverPlayerIndex == 1)
            Icon(
              Icons.sports_tennis,
              color: Colors.white,
              size: 28,
            ),
        ],
      ),
    );
  }

  // 팀 플레이어 정보 표시 위젯
  Widget _buildTeamPlayers() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                'game.player.short.p1'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isServingTeam && serverPlayerIndex == 0)
                Icon(
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
          Column(
            children: [
              Text(
                'game.player.short.p2'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isServingTeam && serverPlayerIndex == 1)
                Icon(
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

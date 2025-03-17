import 'package:easy_localization/easy_localization.dart';

class Sport {
  final int id;
  final String name;
  final String icon;
  int maxRound;
  int scorePerRound;

  Sport({
    required this.id,
    required this.name,
    required this.icon,
    required this.maxRound,
    required this.scorePerRound,
  });

  String get translatedName => name.tr();

  void updateRoundSettings({
    required int newMaxRound,
    required int newScorePerRound,
  }) {
    maxRound = newMaxRound;
    scorePerRound = newScorePerRound;
  }
}

class Sport {
  final String name;
  final String icon;
  final int id;
  int maxRound;
  int scorePerRound;

  Sport({
    required this.name,
    required this.icon,
    required this.id,
    required this.maxRound,
    required this.scorePerRound,
  });

  void updateRoundSettings({int? newMaxRound, int? newScorePerRound}) {
    if (newMaxRound != null) maxRound = newMaxRound;
    if (newScorePerRound != null) scorePerRound = newScorePerRound;
  }
}

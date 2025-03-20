import 'package:easy_localization/easy_localization.dart';

// 지원하는 스포츠 종목 enum
enum SportType {
  tableTennis('sports.tableTennis', '🏓'),
  pickleball('sports.pickleball', '🥒'),
  badminton('sports.badminton', '🏸');

  final String nameKey;
  final String icon;

  const SportType(this.nameKey, this.icon);
}

// 스포츠 설정 타입 enum
enum GameSettingType {
  official, // 공식 규칙
  single, // 단일 라운드
  custom // 커스텀 설정
}

// 스포츠 기본 설정을 담는 클래스
class SportSettings {
  final int maxRound;
  final int scorePerRound;

  const SportSettings({
    required this.maxRound,
    required this.scorePerRound,
  });
}

class Sport {
  final SportType type;
  int maxRound;
  int scorePerRound;

  // 종목별 기본 설정값 정의
  static const Map<SportType, Map<GameSettingType, SportSettings>>
      defaultSettings = {
    SportType.tableTennis: {
      GameSettingType.official: SportSettings(maxRound: 5, scorePerRound: 11),
      GameSettingType.single: SportSettings(maxRound: 1, scorePerRound: 11),
    },
    SportType.pickleball: {
      GameSettingType.official: SportSettings(maxRound: 3, scorePerRound: 11),
      GameSettingType.single: SportSettings(maxRound: 1, scorePerRound: 11),
    },
    SportType.badminton: {
      GameSettingType.official: SportSettings(maxRound: 3, scorePerRound: 21),
      GameSettingType.single: SportSettings(maxRound: 1, scorePerRound: 21),
    },
  };

  Sport({
    required this.type,
    required this.maxRound,
    required this.scorePerRound,
  });

  // 종목 이름 반환
  String get name => type.nameKey;

  // 종목 아이콘 반환
  String get icon => type.icon;

  // 번역된 이름 반환
  String get translatedName => name.tr();

  // 설정 타입에 따른 기본값 적용
  void applyDefaultSettings(GameSettingType settingType) {
    final settings = defaultSettings[type]?[settingType] ??
        const SportSettings(maxRound: 3, scorePerRound: 21);

    maxRound = settings.maxRound;
    scorePerRound = settings.scorePerRound;
  }

  void updateRoundSettings({
    required int newMaxRound,
    required int newScorePerRound,
  }) {
    maxRound = newMaxRound;
    scorePerRound = newScorePerRound;
  }

  // 공식 규칙으로 Sport 인스턴스를 생성하는 팩토리 생성자
  factory Sport.withOfficialSettings(SportType type) {
    final settings = defaultSettings[type]?[GameSettingType.official] ??
        const SportSettings(maxRound: 3, scorePerRound: 21);

    return Sport(
      type: type,
      maxRound: settings.maxRound,
      scorePerRound: settings.scorePerRound,
    );
  }

  // 복사본을 생성하는 메소드
  Sport copyWith({
    SportType? type,
    int? maxRound,
    int? scorePerRound,
  }) {
    return Sport(
      type: type ?? this.type,
      maxRound: maxRound ?? this.maxRound,
      scorePerRound: scorePerRound ?? this.scorePerRound,
    );
  }
}

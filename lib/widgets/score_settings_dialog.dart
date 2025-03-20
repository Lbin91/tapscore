import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/score_option.dart';
import '../models/sports.dart';
import '../theme/app_colors.dart';
import '../screens/game_screen.dart';
import '../screens/pickleball_doubles_screen.dart';

class ScoreSettingsDialog extends StatefulWidget {
  final Sport sport;
  final ScoreOption option;
  final Function(int maxRound, int scorePerRound, bool isDoubles)
      onSettingsChanged;
  final bool allowCustomSettings; // 설정 변경 가능 여부 (커스텀 옵션일 때만 true)

  const ScoreSettingsDialog({
    Key? key,
    required this.sport,
    required this.option,
    required this.onSettingsChanged,
    this.allowCustomSettings = false, // 기본값은 false로 설정
  }) : super(key: key);

  @override
  State<ScoreSettingsDialog> createState() => _ScoreSettingsDialogState();
}

class _ScoreSettingsDialogState extends State<ScoreSettingsDialog> {
  late int _maxRound;
  late int _scorePerRound;
  late TextEditingController _scoreController;
  final _formKey = GlobalKey<FormState>();
  bool _isCustomScore = false; // 커스텀 점수 입력 모드 여부
  bool _isDoubles = false; // 단식/복식 선택 상태 (false: 단식, true: 복식)

  @override
  void initState() {
    super.initState();
    // 옵션에 따라 초기값 설정
    switch (widget.option.id) {
      case 'official':
        // 공식 규칙: 종목별로 다른 설정
        if (widget.sport.name == 'sports.badminton') {
          _maxRound = 3; // 배드민턴 기본 3세트
          _scorePerRound = 21; // 21점
        } else if (widget.sport.name == 'sports.tableTennis') {
          _maxRound = 5; // 탁구 기본 5세트
          _scorePerRound = 11; // 11점
        } else if (widget.sport.name == 'sports.pickleball') {
          _maxRound = 3; // 피클볼 기본 3세트
          _scorePerRound = 11; // 11점
        } else {
          _maxRound = 3; // 기본값
          _scorePerRound = 21;
        }
        break;
      case 'single':
        _maxRound = 1; // 단일 라운드: 1세트 설정

        // 종목별 단일 라운드 점수 설정
        if (widget.sport.name == 'sports.badminton') {
          _scorePerRound = 21;
        } else if (widget.sport.name == 'sports.tableTennis' ||
            widget.sport.name == 'sports.pickleball') {
          _scorePerRound = 11;
        } else {
          _scorePerRound = 21;
        }
        break;
      case 'custom':
        // 커스텀: 현재 스포츠 설정값 사용
        _maxRound = widget.sport.maxRound;
        _scorePerRound = widget.sport.scorePerRound;
        break;
    }

    // 이미 설정된 값이 있으면 사용
    _isDoubles = widget.sport.isDoubles;

    _scoreController = TextEditingController(text: _scorePerRound.toString());
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  // 점수 입력값 검증
  String? _validateScore(String? value) {
    if (value == null || value.isEmpty) {
      return 'dialog.settings.error.required'.tr();
    }
    int? score = int.tryParse(value);
    if (score == null) {
      return 'dialog.settings.error.numberOnly'.tr();
    }
    if (score < 1) {
      return 'dialog.settings.error.minScore'.tr();
    }
    if (score > 99) {
      return 'dialog.settings.error.maxScore'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          widget.option.name.tr(),
          style: TextStyle(
            color: AppColors.mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.option.description.tr()),
            SizedBox(height: 16),
            // 피클볼 종목인 경우에만 단식/복식 선택 표시
            if (widget.sport.isPickleball) ...[
              _buildGameTypeSelector(),
              SizedBox(height: 16),
            ],
            widget.allowCustomSettings
                ? _buildCustomSettings()
                : _buildFixedSettingsSummary(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
            ),
            child: Text(
              'common.cancel'.tr(),
              style: TextStyle(color: AppColors.subMainColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.allowCustomSettings &&
                  _isCustomScore &&
                  !_formKey.currentState!.validate()) {
                return;
              }
              if (widget.allowCustomSettings && _isCustomScore) {
                _scorePerRound = int.parse(_scoreController.text);
              }

              Navigator.pop(context);
              widget.onSettingsChanged(_maxRound, _scorePerRound, _isDoubles);

              // 복사본 생성 (isDoubles 필드 업데이트)
              Sport updatedSport = widget.sport.copyWith(
                maxRound: _maxRound,
                scorePerRound: _scorePerRound,
                isDoubles: _isDoubles,
              );

              // 피클볼 복식인 경우 PickleballDoublesScreen으로 이동, 그 외에는 GameScreen으로 이동
              if (widget.sport.isPickleball && _isDoubles) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PickleballDoublesScreen(
                      sport: updatedSport,
                      maxRound: _maxRound,
                      scorePerRound: _scorePerRound,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      sport: updatedSport,
                      maxRound: _maxRound,
                      scorePerRound: _scorePerRound,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              elevation: 0,
            ),
            child: Text(
              'common.confirm'.tr(),
              style: TextStyle(color: AppColors.mainTitleColor),
            ),
          ),
        ],
      ),
    );
  }

  // 단식/복식 선택 위젯
  Widget _buildGameTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dialog.settings.gameType.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: _isDoubles,
                    onChanged: (value) {
                      setState(() {
                        _isDoubles = value!;
                      });
                    },
                    activeColor: AppColors.mainColor,
                  ),
                  Text('dialog.settings.gameType.singles'.tr()),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _isDoubles,
                    onChanged: (value) {
                      setState(() {
                        _isDoubles = value!;
                      });
                    },
                    activeColor: AppColors.mainColor,
                  ),
                  Text('dialog.settings.gameType.doubles'.tr()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 고정 설정일 경우 요약 정보 표시
  Widget _buildFixedSettingsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dialog.settings.summary.rounds'.tr(args: ['$_maxRound']),
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          'dialog.settings.summary.score'.tr(args: ['$_scorePerRound']),
          style: TextStyle(fontSize: 14),
        ),
        if (widget.sport.isPickleball) ...[
          SizedBox(height: 8),
          Text(
            _isDoubles
                ? 'gameType.doubles'.tr() +
                    ' (${'gameType.doubles_short'.tr()})'
                : 'gameType.singles'.tr() +
                    ' (${'gameType.singles_short'.tr()})',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ],
    );
  }

  // 커스텀 설정일 경우 컨트롤 표시
  Widget _buildCustomSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('dialog.settings.rounds'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildRoundSelector(),
        SizedBox(height: 16),
        Text('dialog.settings.scorePerRound'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildScoreSelector(),
        if (_isCustomScore) ...[
          SizedBox(height: 12),
          _buildScoreInput(),
        ],
      ],
    );
  }

  Widget _buildRoundSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 1; i <= 5; i++) _buildRoundButton(i),
      ],
    );
  }

  Widget _buildRoundButton(int round) {
    final bool isSelected = _maxRound == round;
    return GestureDetector(
      onTap: () {
        if (widget.allowCustomSettings) {
          setState(() {
            _maxRound = round;
          });
        }
      },
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$round',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSelector() {
    // 종목별 점수 옵션 생성
    List<int> scoreOptions = [];

    if (widget.sport.name == 'sports.badminton') {
      scoreOptions = [15, 21, 30];
    } else if (widget.sport.name == 'sports.tableTennis' ||
        widget.sport.name == 'sports.pickleball') {
      scoreOptions = [11, 15, 21];
    } else {
      scoreOptions = [11, 15, 21]; // 기본값
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int score in scoreOptions) _buildScoreButton(score),
          ],
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isCustomScore = !_isCustomScore;
              if (!_isCustomScore) {
                // 커스텀 입력 모드 종료 시 선택된 점수로 컨트롤러 업데이트
                _scoreController.text = _scorePerRound.toString();
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _isCustomScore
                  ? AppColors.mainColor.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: _isCustomScore
                  ? Border.all(color: AppColors.mainColor)
                  : null,
            ),
            child: Center(
              child: Text(
                'dialog.settings.customScore'.tr(),
                style: TextStyle(
                  color: _isCustomScore ? AppColors.mainColor : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreButton(int score) {
    final bool isSelected = _scorePerRound == score && !_isCustomScore;
    return GestureDetector(
      onTap: () {
        if (widget.allowCustomSettings) {
          setState(() {
            _scorePerRound = score;
            _isCustomScore = false;
            _scoreController.text = score.toString();
          });
        }
      },
      child: Container(
        width: 65,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'dialog.settings.scorePoints'.tr(args: ['$score']),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreInput() {
    return TextFormField(
      controller: _scoreController,
      keyboardType: TextInputType.number,
      validator: _validateScore,
      decoration: InputDecoration(
        hintText: 'dialog.settings.customScore.hint'.tr(),
        errorStyle: TextStyle(color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mainColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: TextStyle(fontSize: 16),
    );
  }
}

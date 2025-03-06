import 'package:flutter/material.dart';
import '../models/score_option.dart';
import '../models/sports.dart';
import '../theme/app_colors.dart';
import '../screens/game_screen.dart';

class ScoreSettingsDialog extends StatefulWidget {
  final Sport sport;
  final ScoreOption option;
  final Function(int maxRound, int scorePerRound) onSettingsChanged;
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

  @override
  void initState() {
    super.initState();
    // 옵션에 따라 초기값 설정
    switch (widget.option.id) {
      case 'official':
        // 공식 규칙: 종목별로 다른 설정
        if (widget.sport.name == '배드민턴') {
          _maxRound = 3; // 배드민턴 기본 3세트
          _scorePerRound = 21; // 21점
        } else if (widget.sport.name == '탁구') {
          _maxRound = 5; // 탁구 기본 5세트
          _scorePerRound = 11; // 11점
        } else if (widget.sport.name == '피클볼') {
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
        if (widget.sport.name == '배드민턴') {
          _scorePerRound = 21;
        } else if (widget.sport.name == '탁구' || widget.sport.name == '피클볼') {
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
      return '점수를 입력해주세요';
    }
    int? score = int.tryParse(value);
    if (score == null) {
      return '숫자만 입력해주세요';
    }
    if (score < 1) {
      return '1점 이상 입력해주세요';
    }
    if (score > 99) {
      return '99점 이하로 입력해주세요';
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
          '${widget.option.name} 설정',
          style: TextStyle(
            color: AppColors.mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.option.description),
            SizedBox(height: 16),
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
              '취소',
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
              widget.onSettingsChanged(_maxRound, _scorePerRound);
              // 게임 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    sport: widget.sport,
                    maxRound: _maxRound,
                    scorePerRound: _scorePerRound,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              elevation: 0,
            ),
            child: Text(
              '확인',
              style: TextStyle(color: AppColors.mainTitleColor),
            ),
          ),
        ],
      ),
    );
  }

  // 고정 설정일 경우 요약 정보 표시
  Widget _buildFixedSettingsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• 세트 수: $_maxRound'),
        SizedBox(height: 8),
        Text('• 세트당 점수: $_scorePerRound'),
      ],
    );
  }

  // 커스텀 설정일 경우 컨트롤 표시
  Widget _buildCustomSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('세트 수', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildRoundSelector(),
        SizedBox(height: 16),
        Text('세트당 점수', style: TextStyle(fontWeight: FontWeight.bold)),
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

    if (widget.sport.name == '배드민턴') {
      scoreOptions = [15, 21, 30];
    } else if (widget.sport.name == '탁구' || widget.sport.name == '피클볼') {
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
                '직접 입력',
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
            '$score점',
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
        hintText: '점수 직접 입력',
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

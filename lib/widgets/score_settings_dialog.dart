import 'package:flutter/material.dart';
import '../models/score_option.dart';
import '../models/sports.dart';
import '../theme/app_colors.dart';

class ScoreSettingsDialog extends StatelessWidget {
  final Sport sport;
  final ScoreOption option;
  final Function(int maxRound, int scorePerRound) onSettingsChanged;

  const ScoreSettingsDialog({
    Key? key,
    required this.sport,
    required this.option,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      title: _buildTitle(),
      content: _buildContent(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      actions: _buildActions(context),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // 다이얼로그의 제목을 구성하는 메소드
  // 옵션 이름과 스타일을 설정
  Widget _buildTitle() {
    return Text(
      '${option.name} 설정',
      style: TextStyle(
        color: AppColors.mainColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 다이얼로그의 본문 내용을 구성하는 메소드
  // 설명 텍스트와 설정 필드들을 포함
  Widget _buildContent(BuildContext context) {
    int tempMaxRound = sport.maxRound;
    int tempScorePerRound = sport.scorePerRound;

    if (option.id == 'single') {
      tempMaxRound = 1;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDescription(),
        SizedBox(height: 20),
        _buildRoundSettings(tempMaxRound, tempScorePerRound),
      ],
    );
  }

  // 설정 설명 텍스트를 구성하는 메소드
  // 옵션에 대한 설명을 표시
  Widget _buildDescription() {
    return Text(
      option.description,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.subMainColor,
      ),
    );
  }

  // 라운드 설정 필드들을 구성하는 메소드
  // 최대 라운드와 라운드당 점수 입력 필드를 포함
  Widget _buildRoundSettings(int tempMaxRound, int tempScorePerRound) {
    return Column(
      children: [
        _buildSettingField(
          '최대 라운드',
          tempMaxRound.toString(),
          (value) {
            if (value.isNotEmpty) {
              tempMaxRound = int.tryParse(value) ?? tempMaxRound;
            }
          },
          readOnly: option.id == 'single',
        ),
        SizedBox(height: 16),
        _buildSettingField(
          '라운드당 점수',
          tempScorePerRound.toString(),
          (value) {
            if (value.isNotEmpty) {
              tempScorePerRound = int.tryParse(value) ?? tempScorePerRound;
            }
          },
        ),
      ],
    );
  }

  // 다이얼로그의 하단 버튼들을 구성하는 메소드
  // 취소와 확인 버튼을 포함
  List<Widget> _buildActions(BuildContext context) {
    return [
      _buildCancelButton(context),
      SizedBox(width: 8),
      _buildConfirmButton(context),
    ];
  }

  // 취소 버튼을 구성하는 메소드
  // 회색 배경의 취소 버튼 스타일링
  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        '취소',
        style: TextStyle(color: AppColors.subMainColor),
      ),
    );
  }

  // 확인 버튼을 구성하는 메소드
  // 메인 색상의 확인 버튼 스타일링
  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onSettingsChanged(sport.maxRound, sport.scorePerRound);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 0,
      ),
      child: Text(
        '확인',
        style: TextStyle(color: AppColors.mainTitleColor),
      ),
    );
  }

  // 설정 입력 필드를 구성하는 메소드
  // 라벨과 입력 필드의 스타일 및 동작을 정의
  Widget _buildSettingField(
      String label, String initialValue, Function(String) onChanged,
      {bool readOnly = false}) {
    return TextField(
      decoration: _buildInputDecoration(label, readOnly),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? Colors.grey[700] : Colors.black,
      ),
      cursorColor: AppColors.mainColor,
    );
  }

  // 입력 필드의 장식을 구성하는 메소드
  // 테두리, 라벨, 색상 등의 스타일을 정의
  InputDecoration _buildInputDecoration(String label, bool readOnly) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.subMainColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppColors.mainColor, width: 2.0),
      ),
      filled: readOnly,
      fillColor: readOnly ? Color(0xFFF0F0F0) : null,
    );
  }
}

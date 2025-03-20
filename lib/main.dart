import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'models/app_version.dart';
import 'screens/main_screen.dart';
import 'theme/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';

// 앱의 진입점
// Firebase, 다국어 지원, 광고 등 필요한 서비스들을 초기화
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 앱 버전 정보와 원격 구성 가져오기
    final packageInfo = await PackageInfo.fromPlatform();
    final remoteVersion = await _initializeRemoteConfig();
    await MobileAds.instance.initialize();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MyApp(
          currentVersion: packageInfo.version,
          remoteVersion: remoteVersion,
        ),
      ),
    );
  } catch (e) {
    debugPrint('앱 초기화 오류: $e');
    SystemNavigator.pop(); // 오류 발생 시 앱 종료
  }
}

class MyApp extends StatelessWidget {
  final String currentVersion;
  final AppVersion remoteVersion;

  const MyApp({
    Key? key,
    required this.currentVersion,
    required this.remoteVersion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'app.name'.tr(),
      theme: ThemeData(
        primaryColor: AppColors.mainColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: Builder(
        builder: (context) {
          // 화면이 완전히 빌드된 후 버전 체크 실행
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkVersionAndShowDialog(context);
          });
          return MainScreen();
        },
      ),
    );
  }

  // 버전을 체크하고 필요한 경우 업데이트 팝업을 표시하는 메소드
  // showPopup 값과 버전 비교 결과에 따라 강제 업데이트 다이얼로그를 표시
  void _checkVersionAndShowDialog(BuildContext context) {
    final needsForceUpdate = _isNeedForceUpdate(
      currentVersion,
      remoteVersion.forceUpdateVersion,
    );

    // 강제 업데이트가 필요하고 팝업 표시가 활성화된 경우
    if (needsForceUpdate && remoteVersion.showPopup) {
      showDialog(
        context: context,
        barrierDismissible: false, // 백그라운드 터치로 닫기 방지
        builder: (context) => AlertDialog(
          title: Text('update.title'.tr()),
          content: Text('update.message'.tr()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // 앱 종료
              },
              child: Text('update.cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                // TODO: 플레이스토어로 이동 로직 구현 필요
                SystemNavigator.pop();
              },
              child: Text(
                'update.confirm'.tr(),
                style: TextStyle(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Firebase Remote Config에서 버전 정보를 가져오고 초기화하는 함수
// 오류 발생 시 기본 버전 정보를 반환
Future<AppVersion> _initializeRemoteConfig() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // 개발 환경을 위한 설정 (캐시 시간 0)
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: Duration.zero,
    ));

    // 기본 버전 정보 설정
    await remoteConfig.setDefaults(const {
      'version':
          '{"latest_version":"1.0.0","force_update_version":"1.0.0","show_popup":false}',
    });

    // 원격 구성 가져오기 및 활성화
    await remoteConfig.fetchAndActivate();

    // JSON 파싱 및 버전 정보 반환
    final versionJson = remoteConfig.getString('version');
    return AppVersion.fromJson(jsonDecode(versionJson));
  } catch (e) {
    debugPrint('Remote Config 초기화 오류: $e');
    return AppVersion.defaultVersion();
  }
}

// 현재 버전과 강제 업데이트 버전을 비교하여 업데이트 필요 여부를 반환하는 함수
bool _isNeedForceUpdate(String currentVersion, String forceUpdateVersion) {
  final current = currentVersion.split('.').map(int.parse).toList();
  final force = forceUpdateVersion.split('.').map(int.parse).toList();

  // 버전 번호를 순차적으로 비교
  for (var i = 0; i < 3; i++) {
    if (current[i] < force[i]) return true;
    if (current[i] > force[i]) return false;
  }
  return false;
}

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

// Remote Config 초기화 및 값 가져오기 함수
Future<AppVersion> _initializeRemoteConfig() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: Duration.zero,
    ));

    // 기본값 설정
    await remoteConfig.setDefaults(const {
      'version':
          '{"latest_version":"1.0.0","force_update_version":"1.0.0","show_popup":false}',
    });

    await remoteConfig.fetchAndActivate();

    final versionJson = remoteConfig.getString('version');
    return AppVersion.fromJson(jsonDecode(versionJson));
  } catch (e) {
    debugPrint('Remote Config 초기화 오류: $e');
    return AppVersion.defaultVersion();
  }
}

// 버전 비교 함수
bool _isNeedForceUpdate(String currentVersion, String forceUpdateVersion) {
  final current = currentVersion.split('.').map(int.parse).toList();
  final force = forceUpdateVersion.split('.').map(int.parse).toList();

  for (var i = 0; i < 3; i++) {
    if (current[i] < force[i]) return true;
    if (current[i] > force[i]) return false;
  }
  return false;
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

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
    SystemNavigator.pop(); // 앱 종료
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkVersionAndShowDialog(context);
          });
          return MainScreen();
        },
      ),
    );
  }

  void _checkVersionAndShowDialog(BuildContext context) {
    final needsForceUpdate = _isNeedForceUpdate(
      currentVersion,
      remoteVersion.forceUpdateVersion,
    );

    if (needsForceUpdate && remoteVersion.showPopup) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('업데이트 필요'),
          content: const Text(
            '새로운 버전이 출시되었습니다.\n원활한 서비스 이용을 위해\n업데이트가 필요합니다.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: 플레이스토어 URL 추가
                SystemNavigator.pop(); // 앱 종료
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // TODO: 플레이스토어로 이동
                // 임시로 앱 종료
                SystemNavigator.pop();
              },
              child: Text(
                '업데이트',
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

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'screens/main_screen.dart';
import 'theme/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await MobileAds.instance.initialize();

  // 앱 버전 정보 가져오기
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(version: packageInfo.version),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String version;

  const MyApp({
    Key? key,
    required this.version,
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
          // 앱이 시작되면 버전 정보 팝업 표시
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVersionDialog(context);
          });
          return MainScreen();
        },
      ),
    );
  }

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱 버전 정보'),
        content: Text('현재 버전: $version'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
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

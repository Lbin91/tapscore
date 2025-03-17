import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/main_screen.dart';
import 'theme/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await MobileAds.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'), // 영어
        Locale('ko'), // 한국어
      ],
      path: 'assets/translations', // 번역 파일 경로
      fallbackLocale: Locale('en'), // 기본 언어를 영어로 설정
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
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
      home: MainScreen(),
    );
  }
}

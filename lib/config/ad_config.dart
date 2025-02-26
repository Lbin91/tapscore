class AdConfig {
  // 릴리즈 광고 ID
  static const String releaseMainBannerAdUnitId = String.fromEnvironment(
    'MAIN_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );

  static const String releaseDetailBannerAdUnitId = String.fromEnvironment(
    'DETAIL_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );

  static const String releaseDetailInterstitialAdUnitId =
      String.fromEnvironment(
    'DETAIL_INTERSTITIAL_AD_UNIT_ID',
    defaultValue: '',
  );

  static const String releaseAdAppId = String.fromEnvironment(
    'AD_APP_ID',
    defaultValue: '',
  );

  // 테스트 광고 ID
  static const testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const testAdAppId = 'ca-app-pub-3940256099942544~3347511713';
}

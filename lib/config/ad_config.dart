class AdConfig {
  // 테스트 광고 ID
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testAdAppId = 'ca-app-pub-3940256099942544~3347511713';

  // 실제 광고 ID (환경변수에서 가져옴)
  static const String releaseBannerAdUnitId = String.fromEnvironment(
    'BANNER_AD_UNIT_ID',
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
}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../config/ad_config.dart';

enum BannerAdType {
  main,
  detail,
}

class BannerAdWidget extends StatefulWidget {
  final BannerAdType type;

  const BannerAdWidget({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  String get _adUnitId {
    if (kDebugMode) {
      return AdConfig.testBannerAdUnitId;
    }
    return widget.type == BannerAdType.main
        ? AdConfig.releaseBannerAdUnitId
        : AdConfig.releaseBannerAdUnitId;
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    // Debug 모드 확인을 위해 assert를 사용
    final isDebug = kDebugMode;

    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: isDebug ? _adUnitId : _adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('광고 로드 실패: ${error.message}');
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }
}

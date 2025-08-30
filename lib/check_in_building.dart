import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// MapTiler（ベクタースタイル）。あなたのキーに差し替え可
const styleUrl =
    'https://api.maptiler.com/maps/streets-v2/style.json?key=fdAxUaT0DqfPmcAahF3V';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _map;
  bool _styleReady = false;
  bool _busyUi = false; // 手動チェック時のUIローディング

  /// ログで判明したレイヤーIDに合わせて固定（必要に応じて調整）
  static const List<String> _buildingLayerIds = ['Building', 'Building 3D'];

  // 日の出/日の入り（ローカル時刻）
  DateTime? _sunriseLocal;
  DateTime? _sunsetLocal;
  LatLng? _sunCacheAt; // どの座標で取得したか（おおよその距離監視用）
  DateTime? _sunCacheDate; // どの日付のキャッシュか

  // 条件: 「建物の外」かつ「昼」
  bool? _isDay; // true=昼, false=夜, null=未取得
  bool? _onBuilding; // true=建物の上, false=建物以外, null=未取得

  // 計測（自動）
  Timer? _pollTimer;
  DateTime? _lastPollAt;
  Duration _activeDuration = Duration.zero; // 条件成立時間の累計
  bool _isMeasuring = false;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCondition = _isDay == true && _onBuilding == false;

    return Scaffold(
      appBar: AppBar(title: const Text('建物の外×昼 の計測')),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: styleUrl,
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.681236, 139.767125), // 東京駅
              zoom: 17,
            ),
            myLocationEnabled: true,
            myLocationRenderMode: MyLocationRenderMode.normal,
            onMapCreated: (c) => _map = c,
            onStyleLoadedCallback: () => setState(() => _styleReady = true),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoChip(
                    icon: Icons.wb_sunny_outlined,
                    label: _isDay == null
                        ? '昼夜: 未判定'
                        : _isDay!
                            ? '昼'
                            : '夜',
                    color: _isDay == true
                        ? Colors.orange
                        : _isDay == false
                            ? Colors.indigo
                            : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  _InfoChip(
                    icon: Icons.apartment_outlined,
                    label: _onBuilding == null
                        ? '建物: 未判定'
                        : _onBuilding!
                            ? '建物の上'
                            : '建物以外',
                    color: _onBuilding == false
                        ? Colors.green
                        : _onBuilding == true
                            ? Colors.red
                            : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('条件成立の累計時間',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(
                            _fmtDuration(_activeDuration),
                            style: const TextStyle(
                              fontSize: 36,
                              fontFeatures: [FontFeature.tabularFigures()],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sunriseLocal != null && _sunsetLocal != null
                                ? '今日の 日の出 ${_fmtTime(_sunriseLocal!)}, 日の入り ${_fmtTime(_sunsetLocal!)}'
                                : '日の出/日の入り 未取得',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _busyUi ? null : _manualCheckOnce,
                          child: Text(_busyUi ? '判定中…' : '1回だけ判定'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: !_styleReady
                              ? null
                              : (_isMeasuring
                                  ? _stopMeasurement
                                  : _startMeasurement),
                          child: Text(_isMeasuring ? '自動計測 停止' : '自動計測 開始'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetToday,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('今日の累計をリセット'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------------------
  ///  UI 操作
  /// ---------------------------
  Future<void> _manualCheckOnce() async {
    setState(() => _busyUi = true);
    try {
      await _pollOnce(animateCamera: true);
      if (!mounted) return;
      final msg =
          '【${_isDay == true ? '昼' : _isDay == false ? '夜' : '—'} × ${_onBuilding == false ? '建物の外' : _onBuilding == true ? '建物上' : '—'}】';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('現在の判定: $msg')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyUi = false);
    }
  }

  Future<void> _startMeasurement() async {
    await _ensureLocationPermission();
    await _loadTodayFromPrefs();
    _lastPollAt = null;
    _isMeasuring = true;
    setState(() {});

    // 初回実行してから周回
    unawaited(_pollOnce(animateCamera: false));
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(_pollOnce(animateCamera: false));
    });
  }

  void _stopMeasurement() {
    _pollTimer?.cancel();
    _isMeasuring = false;
    _lastPollAt = null;
    setState(() {});
  }

  Future<void> _resetToday() async {
    _activeDuration = Duration.zero;
    _lastPollAt = null;
    await _saveTodayToPrefs();
    if (mounted) setState(() {});
  }

  /// ---------------------------
  ///  中核ロジック
  /// ---------------------------
  Future<void> _pollOnce({required bool animateCamera}) async {
    if (_map == null || !_styleReady) return;
    await _ensureLocationPermission();

    // 現在地
    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);

    // カメラ位置（建物判定は画面座標を使うため、なるべく近辺を表示）
    if (animateCamera) {
      await _map!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
    } else {
      await _map!.moveCamera(CameraUpdate.newLatLngZoom(latLng, 17));
    }

    // 昼夜キャッシュの更新（距離>30km または 日付が変わったら再取得）
    final now = DateTime.now();
    final needSunFetch = _sunriseLocal == null ||
        _sunsetLocal == null ||
        _sunCacheDate == null ||
        !_isSameYmd(_sunCacheDate!, now) ||
        (_sunCacheAt == null ? true : _distanceKm(_sunCacheAt!, latLng) > 30.0);
    if (needSunFetch) {
      await _fetchSunTimes(latLng.latitude, latLng.longitude);
      _sunCacheAt = latLng;
      _sunCacheDate = DateTime(now.year, now.month, now.day);
    } else {
      _updateIsDay();
    }

    // 建物判定
    _onBuilding = await _isOnBuildingRobust(latLng);

    // 条件成立時間を加算
    final prevPoll = _lastPollAt ?? now;
    final delta = now.difference(prevPoll);
    _lastPollAt = now;

    final condition = (_isDay == true && _onBuilding == false);
    if (condition) {
      _activeDuration += delta;
      await _saveTodayToPrefs();
    }

    if (mounted) setState(() {});
  }

  /// 中心＋十字の5点・多数決（3/5以上）で建物判定
  Future<bool> _isOnBuildingRobust(LatLng latLng) async {
    if (_map == null) return false;

    final pt = await _map!.toScreenLocation(latLng);

    // 十字に5点（px単位オフセット）
    const offsetPx = 24.0; // 16〜32 で調整可
    final centers = <Offset>[
      Offset(pt.x.toDouble(), pt.y.toDouble()),
      Offset(pt.x.toDouble() + offsetPx, pt.y.toDouble()),
      Offset(pt.x.toDouble() - offsetPx, pt.y.toDouble()),
      Offset(pt.x.toDouble(), pt.y.toDouble() + offsetPx),
      Offset(pt.x.toDouble(), pt.y.toDouble() - offsetPx),
    ];

    // 誤差吸収のためのバッファ（矩形半径、px）
    const radiusPx = 48.0; // 32〜64 で調整

    int hits = 0;
    for (final c in centers) {
      final rect = Rect.fromCenter(
        center: c,
        width: radiusPx * 2,
        height: radiusPx * 2,
      );

      final features = await _map!.queryRenderedFeaturesInRect(
        rect,
        _buildingLayerIds,
        null,
      );

      if (features.isNotEmpty) hits++;
    }

    return hits >= 3; // 3/5以上で建物とみなす
  }

  /// 日の出/日の入りを Sunrise-Sunset API から取得（UTC → ローカルに変換）
  Future<void> _fetchSunTimes(double lat, double lng) async {
    final local = DateTime.now();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d'; // 端末ローカル日付で問い合わせ

    final uri = Uri.parse(
      'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&date=$dateStr&formatted=0',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      _sunriseLocal = null;
      _sunsetLocal = null;
      _isDay = null;
      return;
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    final results = data['results'] as Map<String, dynamic>;
    final sunriseUtc = DateTime.parse(results['sunrise']);
    final sunsetUtc = DateTime.parse(results['sunset']);

    _sunriseLocal = sunriseUtc.toLocal();
    _sunsetLocal = sunsetUtc.toLocal();

    _updateIsDay();
  }

  void _updateIsDay() {
    final now = DateTime.now(); // 端末ローカル
    if (_sunriseLocal != null && _sunsetLocal != null) {
      _isDay = (_sunriseLocal!.isBefore(now) && _sunsetLocal!.isAfter(now));
    } else {
      _isDay = null;
    }
  }

  /// ---------------------------
  ///  永続化（当日分のみ）
  /// ---------------------------
  static const _prefsKeyMillis = 'outdoor_day_millis';
  static const _prefsKeyDate = 'outdoor_day_ymd';

  Future<void> _loadTodayFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ymd = _todayYmd();
    final savedYmd = prefs.getString(_prefsKeyDate);
    if (savedYmd == ymd) {
      final ms = prefs.getInt(_prefsKeyMillis) ?? 0;
      _activeDuration = Duration(milliseconds: ms);
    } else {
      _activeDuration = Duration.zero; // 日付が変わっていればクリア
      await prefs.setString(_prefsKeyDate, ymd);
      await prefs.setInt(_prefsKeyMillis, 0);
    }
  }

  Future<void> _saveTodayToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyDate, _todayYmd());
    await prefs.setInt(_prefsKeyMillis, _activeDuration.inMilliseconds);
  }

  String _todayYmd() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// ---------------------------
  ///  ユーティリティ
  /// ---------------------------
  String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _fmtDuration(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60);
    final ss = d.inSeconds.remainder(60);
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  Future<void> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw '位置サービスが無効です（端末の位置情報をオンにしてください）';
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever ||
        p == LocationPermission.denied) {
      throw '位置権限がありません';
    }
  }

  bool _isSameYmd(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double _distanceKm(LatLng a, LatLng b) {
    // 簡易ハーサイン
    const R = 6371.0; // 地球半径(km)
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude);
    final la2 = _deg2rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  double _deg2rad(double d) => d * math.pi / 180.0;
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

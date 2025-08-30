import 'dart:convert';
import 'dart:ui' show Rect, Offset;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;

// MapTiler（ベクタースタイル）。あなたのキーに差し替え可
const STYLE_URL =
    'https://api.maptiler.com/maps/streets-v2/style.json?key=fdAxUaT0DqfPmcAahF3V';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _map;
  String _status = '—';
  bool _busy = false;
  bool _styleReady = false;

  /// ログで判明したレイヤーIDに合わせて固定
  static const List<String> _buildingLayerIds = ['Building', 'Building 3D'];

  // 日の出/日の入り（ローカル時刻）
  DateTime? _sunriseLocal;
  DateTime? _sunsetLocal;
  bool? _isDay; // true=昼, false=夜, null=未取得

  @override
  Widget build(BuildContext context) {
    final buttonsDisabled = _busy || !_styleReady;

    return Scaffold(
      appBar: AppBar(title: const Text('建物＋昼夜 判定')),
      body: MapLibreMap(
        styleString: STYLE_URL,
        initialCameraPosition: const CameraPosition(
          target: LatLng(35.681236, 139.767125), // 東京駅
          zoom: 17,
        ),
        myLocationEnabled: true,
        myLocationRenderMode: MyLocationRenderMode.normal,
        onMapCreated: (c) => _map = c,
        onStyleLoadedCallback: () => setState(() => _styleReady = true),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: buttonsDisabled ? null : _handleCheck,
        label: Text(_busy ? '判定中…' : (_status == '—' ? '判定する' : _status)),
      ),
    );
  }

  /// ボタン押下時：現在地で「建物か」「昼/夜か」を判定
  Future<void> _handleCheck() async {
    if (_map == null) return;
    setState(() => _busy = true);
    try {
      await _ensureLocationPermission();
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);

      // カメラを寄せる（ズーム17）
      await _map!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));

      // 昼/夜を取得＆判定
      await _fetchSunTimes(latLng.latitude, latLng.longitude);
      final onBuilding = await _isOnBuildingRobust(latLng);

      final hiruYoru = _isDay == null ? '—' : (_isDay! ? '昼' : '夜');
      setState(() {
        _status = '${onBuilding ? '建物の上 ✅' : '建物以外 ❌'} ・ $hiruYoru';
      });

      // 取得した日の出/日の入りをスナックバーで表示
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _sunriseLocal != null && _sunsetLocal != null
                ? '日の出: ${_fmt(_sunriseLocal!)} / 日の入り: ${_fmt(_sunsetLocal!)}（端末のローカル時刻）'
                : '日の出/日の入りを取得できませんでした',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() => _status = 'エラー: $e');
    } finally {
      setState(() => _busy = false);
    }
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
    final uri = Uri.parse(
      'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&date=today&formatted=0',
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
    final sunriseUtc =
        DateTime.parse(results['sunrise']); // 例: 2025-08-31T20:24:13+00:00
    final sunsetUtc = DateTime.parse(results['sunset']);

    _sunriseLocal = sunriseUtc.toLocal();
    _sunsetLocal = sunsetUtc.toLocal();

    final now = DateTime.now(); // 端末ローカル
    _isDay = (_sunriseLocal!.isBefore(now) && _sunsetLocal!.isAfter(now));
  }

  String _fmt(DateTime dt) {
    // hh:mm 表示（必要なら intl パッケージでローカライズ）
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
    // 秒まで見たい場合: '${dt.hour}:${dt.minute}:${dt.second}'
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
}

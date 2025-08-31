import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final imagePathsProvider = Provider<List<String>>((ref) => const [
      'assets/image/img0.png',
      'assets/image/img1.png',
      'assets/image/img2.png',
      'assets/image/img3.png',
      'assets/image/img4.png',
    ]);

/// 当日ランク管理用
class ImageRankNotifier extends StateNotifier<int> {
  ImageRankNotifier() : super(3); // 当日の初期ランク=3

  static const _prefsKeyRank = 'today_image_rank';
  static const _prefsKeyYmd = 'today_rank_ymd';

  /// 当日の初期化（別日なら 3 に戻す）
  Future<void> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final ymd = _todayYmd();
    final savedYmd = prefs.getString(_prefsKeyYmd);
    if (savedYmd == ymd) {
      state = prefs.getInt(_prefsKeyRank) ?? 3;
    } else {
      state = 3;
      await prefs.setString(_prefsKeyYmd, ymd);
      await prefs.setInt(_prefsKeyRank, 3);
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyYmd, _todayYmd());
    await prefs.setInt(_prefsKeyRank, state);
  }

  /// 指定ランクへ丸め（範囲 0..4）
  Future<void> setToAtMost(int target) async {
    final next = target.clamp(0, 4);
    if (next < state) {
      state = next;
      await save();
    }
  }

  /// +1（上限 4）
  Future<void> bumpUpOnce() async {
    final next = (state + 1).clamp(0, 4);
    if (next != state) {
      state = next;
      await save();
    }
  }

  static String _todayYmd() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final imageRankProvider =
    StateNotifierProvider<ImageRankNotifier, int>((ref) => ImageRankNotifier());

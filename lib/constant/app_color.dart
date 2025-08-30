// 以下はebidenceのカラー例

import 'dart:ui';

class AppColor {
  // ignore: library_private_types_in_public_api
  static final _Brand brand = _Brand();
  // ignore: library_private_types_in_public_api
  static final _Text text = _Text();
  // ignore: library_private_types_in_public_api
  static final _Ui ui = _Ui();
}

class _Brand {
  final Color primary = const Color(0xFFF5F5F5);
  final Color secondary = const Color(0xFFFF9D68);
  final Color secondaryLight = const Color(0xFFFFC966);
  final Color logo = const Color(0xFFFF9857);
  final Color tertiary = const Color(0xFF9ACCE2);
}

class _Text {
  final Color primary = const Color(0xFF333333);

  final Color appBarTitle = const Color(0xFF373737);
  final Color gray = const Color(0xFF808080);
  final Color blackMid = const Color(0x61000000);
  final Color white = const Color(0xFFFFFFFF);
  final Color link = const Color(0xFF6699ff);
  final Color darkgray = const Color(0xFF404040);
  final Color black = const Color(0xFF000000);
}

class _Ui {
  final Color logo = const Color(0xFFFF9857);

  final Color white = const Color(0xFFFFFFFF);
  final Color black = const Color(0xFF000000);
  final Color shadow = const Color(0xFF000000).withOpacity(0.4);
  final Color saturday = const Color(0xFF8EAFED);
  final Color sunday = const Color(0xFFED8EAF);
  final Color unsupported = const Color(0xFFD3D3D3);
  final Color shimmerBase = const Color(0xFFE0E0E0);
  final Color shimmerHighlight = const Color(0xFFFFFFFF);
  final Color background = const Color(0xFFf2f2f2);

  final Color engineer = const Color(0xFF0D8BD9);
  final Color designer = const Color(0xFF7638FA);
  final Color pm = const Color(0xFFF47A44);
  final Color beginner = const Color(0xFF65AE5E);
}

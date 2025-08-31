import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solme/beforecamera.dart';
import 'package:solme/bunsin.dart';
import 'package:solme/camera.dart';
import 'package:solme/check_in_building.dart';
import 'package:solme/concept.dart';
import 'package:solme/home.dart';

final goRouter = GoRouter(
  // アプリが起動した時
  initialLocation: '/',
  // パスと画面の組み合わせ
  routes: [
    GoRoute(
      path: '/',
      name: 'initial',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: BeforeCameraPage(),
          //child: const BeforeCameraPage(),
        );
      },
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const PhotoPage(),
        );
      },
    ),
    GoRoute(
      path: '/concept',
      name: 'concept',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const ConceptPage(),
        );
      },
    ),
    GoRoute(
      path: '/bunsin',
      name: 'bunsin',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const BunsinPage(),
        );
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const HomePage(),
        );
      },
    ),
  ],
  // 遷移ページがないなどのエラーが発生した時に、このページに行く
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text(state.error.toString()),
      ),
    ),
  ),
);

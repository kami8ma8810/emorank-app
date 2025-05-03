import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/pages/auth/login_page.dart';
import 'package:emorank_app/presentation/pages/auth/signup_page.dart';
import 'package:emorank_app/presentation/pages/game/game_play_page.dart';
import 'package:emorank_app/presentation/pages/game/game_result_page.dart';
import 'package:emorank_app/presentation/pages/home/home_page.dart';
import 'package:emorank_app/presentation/pages/room/create_room_page.dart';
import 'package:emorank_app/presentation/pages/room/join_room_page.dart';
import 'package:emorank_app/presentation/pages/room/room_detail_page.dart';
import 'package:emorank_app/presentation/pages/room/room_list_page.dart';
import 'package:emorank_app/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// アプリケーションのルーティング設定
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // 現在のルート
      final currentPath = state.uri.path;
      
      // 認証不要のルート
      final isAuthExempt = [
        '/',
        '/login',
        '/signup',
      ].contains(currentPath);
      
      // 認証状態に基づいてリダイレクト
      if (authState.status == AuthStatus.authenticated) {
        // ログイン済みの場合、認証ページにアクセスしようとするとホームにリダイレクト
        if (currentPath == '/login' || currentPath == '/signup') {
          return '/home';
        }
        // それ以外はそのままアクセス許可
        return null;
      } else if (authState.status == AuthStatus.unauthenticated) {
        // 未認証の場合、認証不要のページ以外はログインページにリダイレクト
        if (!isAuthExempt) {
          return '/login';
        }
        // 認証不要のページはそのままアクセス許可
        return null;
      }
      
      // 認証状態の初期化・読み込み中の場合はスプラッシュ画面を表示
      if (currentPath != '/') {
        return '/';
      }
      
      return null;
    },
    routes: [
      // スプラッシュ画面
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      
      // ログイン画面
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // サインアップ画面
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      
      // ホーム画面
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      
      // ルーム一覧画面
      GoRoute(
        path: '/rooms',
        builder: (context, state) => const RoomListPage(),
      ),
      
      // ルーム作成画面
      GoRoute(
        path: '/rooms/create',
        builder: (context, state) => const CreateRoomPage(),
      ),
      
      // ルーム参加画面
      GoRoute(
        path: '/rooms/join',
        builder: (context, state) => const JoinRoomPage(),
      ),
      
      // ルーム詳細画面
      GoRoute(
        path: '/rooms/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return RoomDetailPage(roomId: roomId);
        },
      ),
      
      // ゲームプレイ画面
      GoRoute(
        path: '/game/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return GamePlayPage(roomId: roomId);
        },
      ),
      
      // ゲーム結果画面
      GoRoute(
        path: '/game/:roomId/result',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return GameResultPage(roomId: roomId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('エラー'),
      ),
      body: Center(
        child: Text('ページが見つかりません: ${state.uri.path}'),
      ),
    ),
  );
});

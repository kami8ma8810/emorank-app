import 'package:emorank_app/domain/entities/user.dart' as entity;
import 'package:emorank_app/domain/usecases/auth_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 認証状態を表す列挙型
enum AuthStatus {
  initial,     // 初期状態
  loading,     // 読み込み中
  authenticated,  // 認証済み
  unauthenticated, // 未認証
  error,       // エラー
}

/// 認証状態を表すクラス
class AuthState {
  final AuthStatus status;
  final entity.User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// 初期状態を作成
  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  /// 読み込み中状態を作成
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  /// 認証済み状態を作成
  factory AuthState.authenticated(entity.User user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

  /// 未認証状態を作成
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  /// エラー状態を作成
  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );

  /// 新しい状態を作成
  AuthState copyWith({
    AuthStatus? status,
    entity.User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, errorMessage: $errorMessage)';
  }
}

/// 認証コントローラー
class AuthController extends StateNotifier<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInAnonymouslyUseCase _signInAnonymouslyUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthController({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignInAnonymouslyUseCase signInAnonymouslyUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithAppleUseCase = signInWithAppleUseCase,
        _signInAnonymouslyUseCase = signInAnonymouslyUseCase,
        _signOutUseCase = signOutUseCase,
        super(AuthState.initial());

  /// 現在のユーザー状態を確認
  Future<void> checkCurrentUser() async {
    try {
      state = AuthState.loading();
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Eメールとパスワードでサインイン
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = AuthState.loading();
      final user = await _signInWithEmailUseCase(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error('ログインに失敗しました: ${e.toString()}');
    }
  }

  /// Eメールとパスワードで新規登録
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = AuthState.loading();
      final user = await _signUpWithEmailUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error('アカウント作成に失敗しました: ${e.toString()}');
    }
  }

  /// Googleアカウントでサインイン
  Future<void> signInWithGoogle() async {
    try {
      state = AuthState.loading();
      final user = await _signInWithGoogleUseCase();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error('Googleログインに失敗しました: ${e.toString()}');
    }
  }

  /// Appleアカウントでサインイン
  Future<void> signInWithApple() async {
    try {
      state = AuthState.loading();
      final user = await _signInWithAppleUseCase();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error('Appleログインに失敗しました: ${e.toString()}');
    }
  }

  /// 匿名でサインイン
  Future<void> signInAnonymously() async {
    try {
      state = AuthState.loading();
      final user = await _signInAnonymouslyUseCase();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error('ゲストログインに失敗しました: ${e.toString()}');
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      state = AuthState.loading();
      await _signOutUseCase();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('ログアウトに失敗しました: ${e.toString()}');
    }
  }
}

/// 認証コントローラープロバイダー
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    signInWithEmailUseCase: ref.read(signInWithEmailUseCaseProvider),
    signUpWithEmailUseCase: ref.read(signUpWithEmailUseCaseProvider),
    signInWithGoogleUseCase: ref.read(signInWithGoogleUseCaseProvider),
    signInWithAppleUseCase: ref.read(signInWithAppleUseCaseProvider),
    signInAnonymouslyUseCase: ref.read(signInAnonymouslyUseCaseProvider),
    signOutUseCase: ref.read(signOutUseCaseProvider),
  );
});

/// 認証ユーザープロバイダー
final authUserProvider = Provider<entity.User?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// 認証状態プロバイダー
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authControllerProvider).status;
});

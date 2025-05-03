import 'package:emorank_app/domain/entities/user.dart';
import 'package:emorank_app/domain/repositories/user_repository.dart';

/// Eメールとパスワードでサインインするユースケース
class SignInWithEmailUseCase {
  final UserRepository _userRepository;

  SignInWithEmailUseCase(this._userRepository);

  /// ユースケースを実行し、ユーザー情報を返す
  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await _userRepository.signInWithEmailAndPassword(
      email,
      password,
    );
  }
}

/// Eメールとパスワードで新規登録するユースケース
class SignUpWithEmailUseCase {
  final UserRepository _userRepository;

  SignUpWithEmailUseCase(this._userRepository);

  /// ユースケースを実行し、新規ユーザー情報を返す
  Future<User> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _userRepository.registerWithEmailAndPassword(
      email,
      password,
      displayName,
    );
  }
}

/// Googleアカウントでサインインするユースケース
class SignInWithGoogleUseCase {
  final UserRepository _userRepository;

  SignInWithGoogleUseCase(this._userRepository);

  /// ユースケースを実行し、ユーザー情報を返す
  Future<User> call() async {
    return await _userRepository.signInWithGoogle();
  }
}

/// Appleアカウントでサインインするユースケース
class SignInWithAppleUseCase {
  final UserRepository _userRepository;

  SignInWithAppleUseCase(this._userRepository);

  /// ユースケースを実行し、ユーザー情報を返す
  Future<User> call() async {
    return await _userRepository.signInWithApple();
  }
}

/// 匿名でサインインするユースケース
class SignInAnonymouslyUseCase {
  final UserRepository _userRepository;

  SignInAnonymouslyUseCase(this._userRepository);

  /// ユースケースを実行し、匿名ユーザー情報を返す
  Future<User> call() async {
    return await _userRepository.signInAnonymously();
  }
}

/// サインアウトするユースケース
class SignOutUseCase {
  final UserRepository _userRepository;

  SignOutUseCase(this._userRepository);

  /// ユースケースを実行
  Future<void> call() async {
    await _userRepository.signOut();
  }
}

/// 現在ログイン中のユーザー情報を取得するユースケース
class GetCurrentUserUseCase {
  final UserRepository _userRepository;

  GetCurrentUserUseCase(this._userRepository);

  /// ユースケースを実行し、現在のユーザー情報を返す（未ログインの場合はnull）
  Future<User?> call() async {
    return await _userRepository.getCurrentUser();
  }
}

/// ユーザー情報をストリームとして監視するユースケース
class UserStreamUseCase {
  final UserRepository _userRepository;

  UserStreamUseCase(this._userRepository);

  /// ユースケースを実行し、ユーザー情報のストリームを返す
  Stream<User?> call(String userId) {
    return _userRepository.userStream(userId);
  }
}

import 'package:emorank_app/domain/entities/user.dart';

/// ユーザーデータ操作のためのリポジトリインターフェース
abstract class UserRepository {
  /// ログインしているユーザーの情報を取得
  Future<User?> getCurrentUser();
  
  /// ユーザーIDからユーザー情報を取得
  Future<User?> getUserById(String userId);
  
  /// Eメールとパスワードでユーザー登録
  Future<User> registerWithEmailAndPassword(String email, String password, String displayName);
  
  /// Eメールとパスワードでログイン
  Future<User> signInWithEmailAndPassword(String email, String password);
  
  /// Googleアカウントでログイン
  Future<User> signInWithGoogle();
  
  /// Appleアカウントでログイン
  Future<User> signInWithApple();
  
  /// 匿名ログイン
  Future<User> signInAnonymously();
  
  /// ログアウト
  Future<void> signOut();
  
  /// ユーザー情報を更新
  Future<User> updateUserInfo(User user);
  
  /// ユーザーのフレンドリストを取得
  Future<List<User>> getFriends(String userId);
  
  /// フレンドを追加
  Future<void> addFriend(String userId, String friendId);
  
  /// フレンドを削除
  Future<void> removeFriend(String userId, String friendId);
  
  /// ユーザー情報の変更をリアルタイムで監視
  Stream<User?> userStream(String userId);
}

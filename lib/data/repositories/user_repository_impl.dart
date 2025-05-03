import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/core/firebase/firebase_provider.dart';
import 'package:emorank_app/data/models/user_model.dart';
import 'package:emorank_app/domain/entities/user.dart';
import 'package:emorank_app/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// UserRepositoryの実装クラス
class UserRepositoryImpl implements UserRepository {
  final FirebaseProvider _firebaseProvider;
  final GoogleSignIn _googleSignIn;

  /// コレクション名
  static const String _collection = 'users';

  UserRepositoryImpl({
    required FirebaseProvider firebaseProvider,
    GoogleSignIn? googleSignIn,
  })  : _firebaseProvider = firebaseProvider,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// ユーザーコレクションの参照を取得
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firebaseProvider.collection(_collection);

  /// 現在ログイン中のユーザー情報を取得
  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseProvider.auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    
    try {
      final userDoc = await _firebaseProvider
          .document('$_collection/${firebaseUser.uid}')
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Firebase Authにはあるが、Firestoreにデータがない場合は作成
        final userData = UserModel.fromRegistration(
          id: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'ユーザー',
          photoUrl: firebaseUser.photoURL,
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());
        return userData;
      }
    } catch (e) {
      // エラーが発生した場合、データベースから取得できないのでFirebaseAuthの情報から
      // 最小限のユーザー情報を生成して返す
      final now = DateTime.now();
      return User(
        id: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'ユーザー',
        photoUrl: firebaseUser.photoURL,
        createdAt: now,
        lastActiveAt: now,
      );
    }
  }

  /// ユーザーIDからユーザー情報を取得
  @override
  Future<User?> getUserById(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      return userDoc.exists ? UserModel.fromFirestore(userDoc) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Eメールとパスワードでユーザー登録
  @override
  Future<User> registerWithEmailAndPassword(
    String email, 
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _firebaseProvider.auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final firebaseUser = credential.user!;
      
      // プロフィール名を更新
      await firebaseUser.updateDisplayName(displayName);
      
      // Firestoreにユーザーデータを保存
      final userData = UserModel.fromRegistration(
        id: firebaseUser.uid,
        displayName: displayName,
        photoUrl: firebaseUser.photoURL,
      );
      
      await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());
      
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  /// Eメールとパスワードでログイン
  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseProvider.auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final firebaseUser = credential.user!;
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        final userData = UserModel.fromFirestore(userDoc);
        
        // 最終アクティブ時間を更新
        final updatedData = userData.updateLastActive();
        await _usersCollection.doc(firebaseUser.uid).update({
          'lastActiveAt': Timestamp.fromDate(updatedData.lastActiveAt),
        });
        
        return updatedData;
      } else {
        // Firestoreにデータがない場合は作成
        final userData = UserModel.fromRegistration(
          id: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'ユーザー',
          photoUrl: firebaseUser.photoURL,
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());
        return userData;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Googleアカウントでログイン
  @override
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Googleログインがキャンセルされました');
      }
      
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _firebaseProvider.auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        final userData = UserModel.fromFirestore(userDoc);
        
        // 最終アクティブ時間を更新
        final updatedData = userData.updateLastActive();
        await _usersCollection.doc(firebaseUser.uid).update({
          'lastActiveAt': Timestamp.fromDate(updatedData.lastActiveAt),
        });
        
        return updatedData;
      } else {
        // Firestoreにデータがない場合は作成
        final userData = UserModel.fromRegistration(
          id: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? googleUser.displayName ?? 'ユーザー',
          photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());
        return userData;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Appleアカウントでログイン
  @override
  Future<User> signInWithApple() async {
    try {
      // Apple認証のプロバイダを作成
      final provider = firebase_auth.AppleAuthProvider();
      
      // 追加のスコープをリクエスト
      provider.addScope('email');
      provider.addScope('name');
      
      // Appleでサインイン
      final credential = await _firebaseProvider.auth.signInWithProvider(provider);
      final firebaseUser = credential.user!;
      
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        final userData = UserModel.fromFirestore(userDoc);
        
        // 最終アクティブ時間を更新
        final updatedData = userData.updateLastActive();
        await _usersCollection.doc(firebaseUser.uid).update({
          'lastActiveAt': Timestamp.fromDate(updatedData.lastActiveAt),
        });
        
        return updatedData;
      } else {
        // Appleログインだと初回はdisplayNameが取得できるが、2回目以降は取得できない
        // そのため、初回ログイン時にはFirestoreに保存しておく必要がある
        final userData = UserModel.fromRegistration(
          id: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'Appleユーザー',
          photoUrl: firebaseUser.photoURL,
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());
        return userData;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 匿名ログイン
  @override
  Future<User> signInAnonymously() async {
    try {
      final credential = await _firebaseProvider.auth.signInAnonymously();
      final firebaseUser = credential.user!;
      
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final userData = UserModel.fromRegistration(
          id: firebaseUser.uid,
          displayName: 'ゲスト',
          photoUrl: null,
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(userData.toFirestore());
        return userData;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ログアウト
  @override
  Future<void> signOut() async {
    try {
      final currentUser = _firebaseProvider.auth.currentUser;
      if (currentUser != null) {
        // 最終アクティブ時間を更新
        await _usersCollection.doc(currentUser.uid).update({
          'lastActiveAt': Timestamp.now(),
        });
      }
      
      await Future.wait([
        _firebaseProvider.auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザー情報を更新
  @override
  Future<User> updateUserInfo(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _usersCollection.doc(user.id).update(userModel.toFirestore());
      
      // Firebase Authのプロフィール情報も更新
      final currentUser = _firebaseProvider.auth.currentUser;
      if (currentUser != null && currentUser.uid == user.id) {
        await currentUser.updateDisplayName(user.displayName);
        if (user.photoUrl != null) {
          await currentUser.updatePhotoURL(user.photoUrl);
        }
      }
      
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザーのフレンドリストを取得
  @override
  Future<List<User>> getFriends(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return [];
      }
      
      final userData = UserModel.fromFirestore(userDoc);
      if (userData.friends.isEmpty) {
        return [];
      }
      
      final friendDocs = await Future.wait(
        userData.friends.map((friendId) => _usersCollection.doc(friendId).get())
      );
      
      return friendDocs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// フレンドを追加
  @override
  Future<void> addFriend(String userId, String friendId) async {
    try {
      // ユーザー自身や存在しないユーザーを追加しようとしている場合はエラー
      if (userId == friendId) {
        throw Exception('自分自身をフレンドに追加することはできません');
      }
      
      final friendDoc = await _usersCollection.doc(friendId).get();
      if (!friendDoc.exists) {
        throw Exception('指定されたユーザーは存在しません');
      }
      
      // トランザクションを使用して整合性を確保
      await _firebaseProvider.runTransaction((transaction) async {
        final userDoc = await transaction.get(_usersCollection.doc(userId));
        if (!userDoc.exists) {
          throw Exception('ユーザーが存在しません');
        }
        
        final userData = UserModel.fromFirestore(userDoc);
        
        // すでにフレンドに追加されている場合は何もしない
        if (userData.friends.contains(friendId)) {
          return;
        }
        
        // フレンドリストを更新
        final updatedFriends = List<String>.from(userData.friends)..add(friendId);
        
        transaction.update(_usersCollection.doc(userId), {
          'friends': updatedFriends,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  /// フレンドを削除
  @override
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await _firebaseProvider.runTransaction((transaction) async {
        final userDoc = await transaction.get(_usersCollection.doc(userId));
        if (!userDoc.exists) {
          throw Exception('ユーザーが存在しません');
        }
        
        final userData = UserModel.fromFirestore(userDoc);
        
        // フレンドに追加されていない場合は何もしない
        if (!userData.friends.contains(friendId)) {
          return;
        }
        
        // フレンドリストを更新
        final updatedFriends = List<String>.from(userData.friends)..remove(friendId);
        
        transaction.update(_usersCollection.doc(userId), {
          'friends': updatedFriends,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザー情報の変更をリアルタイムで監視
  @override
  Stream<User?> userStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      return snapshot.exists ? UserModel.fromFirestore(snapshot) : null;
    });
  }
}

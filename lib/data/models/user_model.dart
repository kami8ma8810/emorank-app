import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/domain/entities/user.dart';

/// Firestore用のユーザーモデルクラス
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.displayName,
    super.photoUrl,
    super.friends,
    super.stats,
    required super.createdAt,
    required super.lastActiveAt,
  });

  /// Firestoreのドキュメントからインスタンスを作成
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      friends: List<String>.from(data['friends'] ?? []),
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp).toDate(),
    );
  }

  /// FirestoreやFirebase Authからの登録用インスタンスを作成
  factory UserModel.fromRegistration({
    required String id,
    required String displayName,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      displayName: displayName,
      photoUrl: photoUrl,
      friends: const [],
      stats: const {},
      createdAt: now,
      lastActiveAt: now,
    );
  }

  /// ドメインエンティティからモデルを作成
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      friends: user.friends,
      stats: user.stats,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
    );
  }

  /// Firestoreに保存するためのマップを取得
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'friends': friends,
      'stats': stats,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
    };
  }

  /// ユーザーモデルの更新
  UserModel copyWithModel({
    String? id,
    String? displayName,
    String? photoUrl,
    List<String>? friends,
    Map<String, dynamic>? stats,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      friends: friends ?? this.friends,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// 最終アクティブ時間を現在に更新
  UserModel updateLastActive() {
    return copyWithModel(lastActiveAt: DateTime.now());
  }
}

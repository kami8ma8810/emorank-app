import 'package:equatable/equatable.dart';

/// ユーザーを表すエンティティクラス
class User extends Equatable {
  final String id;
  final String displayName;
  final String? photoUrl;
  final List<String> friends;
  final Map<String, dynamic> stats;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const User({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.friends = const [],
    this.stats = const {},
    required this.createdAt,
    required this.lastActiveAt,
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        photoUrl,
        friends,
        stats,
        createdAt,
        lastActiveAt,
      ];

  /// 匿名ユーザーを作成するファクトリメソッド
  factory User.anonymous() {
    final now = DateTime.now();
    return User(
      id: 'anonymous',
      displayName: 'ゲスト',
      createdAt: now,
      lastActiveAt: now,
    );
  }

  /// ユーザー情報をコピーして新しいインスタンスを作成
  User copyWith({
    String? id,
    String? displayName,
    String? photoUrl,
    List<String>? friends,
    Map<String, dynamic>? stats,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      friends: friends ?? this.friends,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

import 'package:equatable/equatable.dart';

/// ゲームの状態を表す列挙型
enum GameState {
  waiting, // プレイヤー待機中
  selecting, // カード選択中
  writing, // 回答記入中
  ranking, // 親プレイヤーによるランキング中
  results, // 結果発表中
  finished, // ゲーム終了
}

/// ゲームルームを表すエンティティクラス
class Room extends Equatable {
  final String id;
  final String hostId;
  final List<String> playerIds;
  final GameState gameState;
  final int currentRound;
  final String? situationCardId;
  final String? emotionCardId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int> scores;

  const Room({
    required this.id,
    required this.hostId,
    required this.playerIds,
    this.gameState = GameState.waiting,
    this.currentRound = 0,
    this.situationCardId,
    this.emotionCardId,
    required this.createdAt,
    required this.updatedAt,
    this.scores = const {},
  });

  @override
  List<Object?> get props => [
        id,
        hostId,
        playerIds,
        gameState,
        currentRound,
        situationCardId,
        emotionCardId,
        createdAt,
        updatedAt,
        scores,
      ];

  /// ルーム情報をコピーして新しいインスタンスを作成
  Room copyWith({
    String? id,
    String? hostId,
    List<String>? playerIds,
    GameState? gameState,
    int? currentRound,
    String? situationCardId,
    String? emotionCardId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? scores,
  }) {
    return Room(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      playerIds: playerIds ?? this.playerIds,
      gameState: gameState ?? this.gameState,
      currentRound: currentRound ?? this.currentRound,
      situationCardId: situationCardId ?? this.situationCardId,
      emotionCardId: emotionCardId ?? this.emotionCardId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scores: scores ?? this.scores,
    );
  }

  /// ルームがプレイ可能な状態かどうかを確認
  bool get isPlayable => playerIds.length >= 3 && playerIds.length <= 6;

  /// 次のラウンドが可能かどうかを確認
  bool get canMoveToNextRound => currentRound < playerIds.length;

  /// 特定のプレイヤーが親プレイヤーかどうかを確認
  bool isParentPlayer(String playerId) => 
      playerIds.isNotEmpty && 
      playerIds[currentRound % playerIds.length] == playerId;
}

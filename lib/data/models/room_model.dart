import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/domain/entities/room.dart';

/// Firestore用のルームモデルクラス
class RoomModel extends Room {
  const RoomModel({
    required super.id,
    required super.hostId,
    required super.playerIds,
    super.gameState = GameState.waiting,
    super.currentRound = 0,
    super.situationCardId,
    super.emotionCardId,
    required super.createdAt,
    required super.updatedAt,
    super.scores = const {},
  });

  /// Firestoreのドキュメントからインスタンスを作成
  factory RoomModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return RoomModel(
      id: document.id,
      hostId: data['hostId'] ?? '',
      playerIds: List<String>.from(data['playerIds'] ?? []),
      gameState: GameState.values.firstWhere(
        (e) => e.toString() == 'GameState.${data['gameState']}',
        orElse: () => GameState.waiting,
      ),
      currentRound: data['currentRound'] ?? 0,
      situationCardId: data['situationCardId'],
      emotionCardId: data['emotionCardId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      scores: Map<String, int>.from(data['scores'] ?? {}),
    );
  }

  /// ドメインエンティティからモデルを作成
  factory RoomModel.fromEntity(Room room) {
    return RoomModel(
      id: room.id,
      hostId: room.hostId,
      playerIds: room.playerIds,
      gameState: room.gameState,
      currentRound: room.currentRound,
      situationCardId: room.situationCardId,
      emotionCardId: room.emotionCardId,
      createdAt: room.createdAt,
      updatedAt: room.updatedAt,
      scores: room.scores,
    );
  }

  /// 新しいルームを作成
  factory RoomModel.create({
    required String id,
    required String hostId,
  }) {
    final now = DateTime.now();
    return RoomModel(
      id: id,
      hostId: hostId,
      playerIds: [hostId],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Firestoreに保存するためのマップを取得
  Map<String, dynamic> toFirestore() {
    return {
      'hostId': hostId,
      'playerIds': playerIds,
      'gameState': gameState.toString().split('.').last,
      'currentRound': currentRound,
      'situationCardId': situationCardId,
      'emotionCardId': emotionCardId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'scores': scores,
    };
  }

  /// ルームモデルの更新
  RoomModel copyWithModel({
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
    return RoomModel(
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

  /// 更新時間を現在に更新
  RoomModel withUpdatedTimestamp() {
    return copyWithModel(updatedAt: DateTime.now());
  }

  /// プレイヤーをルームに追加
  RoomModel addPlayer(String playerId) {
    if (playerIds.contains(playerId)) {
      return this;
    }
    final newPlayerIds = List<String>.from(playerIds)..add(playerId);
    return copyWithModel(
      playerIds: newPlayerIds,
      updatedAt: DateTime.now(),
    );
  }

  /// プレイヤーをルームから削除
  RoomModel removePlayer(String playerId) {
    if (!playerIds.contains(playerId)) {
      return this;
    }
    final newPlayerIds = List<String>.from(playerIds)..remove(playerId);
    return copyWithModel(
      playerIds: newPlayerIds,
      updatedAt: DateTime.now(),
    );
  }

  /// ゲーム状態を更新
  RoomModel updateGameState(GameState newState) {
    return copyWithModel(
      gameState: newState,
      updatedAt: DateTime.now(),
    );
  }

  /// カード情報を更新
  RoomModel updateCards({
    String? situationCardId,
    String? emotionCardId,
  }) {
    return copyWithModel(
      situationCardId: situationCardId,
      emotionCardId: emotionCardId,
      updatedAt: DateTime.now(),
    );
  }

  /// 現在のラウンドを更新
  RoomModel updateRound(int roundNumber) {
    return copyWithModel(
      currentRound: roundNumber,
      updatedAt: DateTime.now(),
    );
  }

  /// スコアを更新
  RoomModel updateScores(Map<String, int> newScores) {
    final updatedScores = Map<String, int>.from(scores);
    newScores.forEach((key, value) {
      updatedScores[key] = (updatedScores[key] ?? 0) + value;
    });
    return copyWithModel(
      scores: updatedScores,
      updatedAt: DateTime.now(),
    );
  }
}

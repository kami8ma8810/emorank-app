import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/domain/entities/round.dart';

/// Firestore用のラウンドモデルクラス
class RoundModel extends Round {
  const RoundModel({
    required super.id,
    required super.roomId,
    required super.parentPlayerId,
    required super.situationCardId,
    required super.emotionCardId,
    super.status = RoundStatus.preparing,
    super.playerRanks = const {},
    super.responses = const {},
    super.parentRanking = const [],
    super.scores = const {},
    required super.createdAt,
    required super.updatedAt,
  });

  /// Firestoreのドキュメントからインスタンスを作成
  factory RoundModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return RoundModel(
      id: document.id,
      roomId: data['roomId'] ?? '',
      parentPlayerId: data['parentPlayerId'] ?? '',
      situationCardId: data['situationCardId'] ?? '',
      emotionCardId: data['emotionCardId'] ?? '',
      status: RoundStatus.values.firstWhere(
        (e) => e.toString() == 'RoundStatus.${data['status']}',
        orElse: () => RoundStatus.preparing,
      ),
      playerRanks: Map<String, int>.from(data['playerRanks'] ?? {}),
      responses: Map<String, String>.from(data['responses'] ?? {}),
      parentRanking: List<String>.from(data['parentRanking'] ?? []),
      scores: Map<String, int>.from(data['scores'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// ドメインエンティティからモデルを作成
  factory RoundModel.fromEntity(Round round) {
    return RoundModel(
      id: round.id,
      roomId: round.roomId,
      parentPlayerId: round.parentPlayerId,
      situationCardId: round.situationCardId,
      emotionCardId: round.emotionCardId,
      status: round.status,
      playerRanks: round.playerRanks,
      responses: round.responses,
      parentRanking: round.parentRanking,
      scores: round.scores,
      createdAt: round.createdAt,
      updatedAt: round.updatedAt,
    );
  }

  /// 新しいラウンドを作成
  factory RoundModel.create({
    required String id,
    required String roomId,
    required String parentPlayerId,
    required String situationCardId,
    required String emotionCardId,
  }) {
    final now = DateTime.now();
    return RoundModel(
      id: id,
      roomId: roomId,
      parentPlayerId: parentPlayerId,
      situationCardId: situationCardId,
      emotionCardId: emotionCardId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Firestoreに保存するためのマップを取得
  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'parentPlayerId': parentPlayerId,
      'situationCardId': situationCardId,
      'emotionCardId': emotionCardId,
      'status': status.toString().split('.').last,
      'playerRanks': playerRanks,
      'responses': responses,
      'parentRanking': parentRanking,
      'scores': scores,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// ラウンドモデルの更新
  RoundModel copyWithModel({
    String? id,
    String? roomId,
    String? parentPlayerId,
    String? situationCardId,
    String? emotionCardId,
    RoundStatus? status,
    Map<String, int>? playerRanks,
    Map<String, String>? responses,
    List<String>? parentRanking,
    Map<String, int>? scores,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoundModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      parentPlayerId: parentPlayerId ?? this.parentPlayerId,
      situationCardId: situationCardId ?? this.situationCardId,
      emotionCardId: emotionCardId ?? this.emotionCardId,
      status: status ?? this.status,
      playerRanks: playerRanks ?? this.playerRanks,
      responses: responses ?? this.responses,
      parentRanking: parentRanking ?? this.parentRanking,
      scores: scores ?? this.scores,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 更新時間を現在に更新
  RoundModel withUpdatedTimestamp() {
    return copyWithModel(updatedAt: DateTime.now());
  }

  /// ステータスを更新
  RoundModel updateStatus(RoundStatus newStatus) {
    return copyWithModel(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  /// プレイヤーに順位を割り当て
  RoundModel assignPlayerRank(String playerId, int rank) {
    final updatedRanks = Map<String, int>.from(playerRanks);
    updatedRanks[playerId] = rank;
    return copyWithModel(
      playerRanks: updatedRanks,
      updatedAt: DateTime.now(),
    );
  }

  /// プレイヤーの回答を記録
  RoundModel submitPlayerResponse(String playerId, String response) {
    final updatedResponses = Map<String, String>.from(responses);
    updatedResponses[playerId] = response;
    return copyWithModel(
      responses: updatedResponses,
      updatedAt: DateTime.now(),
    );
  }

  /// 親プレイヤーのランキングを記録
  RoundModel submitRanking(List<String> ranking) {
    return copyWithModel(
      parentRanking: ranking,
      updatedAt: DateTime.now(),
    );
  }

  /// スコアを更新
  RoundModel updateScores(Map<String, int> newScores) {
    return copyWithModel(
      scores: newScores,
      updatedAt: DateTime.now(),
    );
  }
}

import 'package:equatable/equatable.dart';

/// ラウンドのステータスを表す列挙型
enum RoundStatus {
  preparing, // 準備中
  writing,   // 回答記入中
  ranking,   // ランキング中
  finished,  // 完了
}

/// ゲームの各ラウンドを表すエンティティクラス
class Round extends Equatable {
  final String id;
  final String roomId;
  final String parentPlayerId;
  final String situationCardId;
  final String emotionCardId;
  final RoundStatus status;
  
  /// プレイヤーIDと割り当てられたランク（順位）のマッピング
  final Map<String, int> playerRanks;
  
  /// プレイヤーIDと回答のマッピング
  final Map<String, String> responses;
  
  /// 親プレイヤーによる順位付け（プレイヤーIDのリスト、順位順）
  final List<String> parentRanking;
  
  /// このラウンドでの各プレイヤーのスコア
  final Map<String, int> scores;
  
  /// ラウンドの作成・更新時刻
  final DateTime createdAt;
  final DateTime updatedAt;

  const Round({
    required this.id,
    required this.roomId,
    required this.parentPlayerId,
    required this.situationCardId,
    required this.emotionCardId,
    this.status = RoundStatus.preparing,
    this.playerRanks = const {},
    this.responses = const {},
    this.parentRanking = const [],
    this.scores = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        parentPlayerId,
        situationCardId,
        emotionCardId,
        status,
        playerRanks,
        responses,
        parentRanking,
        scores,
        createdAt,
        updatedAt,
      ];

  /// ラウンド情報をコピーして新しいインスタンスを作成
  Round copyWith({
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
    return Round(
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

  /// すべてのプレイヤーが回答を提出したかどうか
  bool allResponsesSubmitted(List<String> playerIds) {
    // 親プレイヤーを除く全員が回答を提出しているか確認
    final nonParentPlayers = playerIds.where((id) => id != parentPlayerId).toList();
    
    // 親プレイヤーの回答があり、すべての非親プレイヤーが回答を提出しているか
    return responses.containsKey(parentPlayerId) && 
           nonParentPlayers.every((id) => responses.containsKey(id));
  }

  /// 親プレイヤーがランキングを完了したかどうか
  bool get isRankingComplete {
    // 回答があるプレイヤー数と親プレイヤーのランキング数が一致するか
    return parentRanking.length == responses.length && parentRanking.isNotEmpty;
  }

  /// ラウンドのスコアを計算
  Map<String, int> calculateScores(List<String> playerIds) {
    if (!isRankingComplete) return {};
    
    final calculatedScores = <String, int>{};
    
    // 親プレイヤー以外のスコア計算
    for (final playerId in playerIds.where((id) => id != parentPlayerId)) {
      // プレイヤーが回答を提出していなければスコアなし
      if (!responses.containsKey(playerId)) continue;
      
      // プレイヤーに割り当てられた順位
      final targetRank = playerRanks[playerId];
      
      // 親プレイヤーによるランキングでの位置
      final actualRankIndex = parentRanking.indexOf(playerId);
      
      // 親プレイヤーのランキングに含まれていなければスコアなし
      if (actualRankIndex == -1 || targetRank == null) continue;
      
      // 目標順位と実際の順位が一致すれば10点
      calculatedScores[playerId] = (actualRankIndex + 1 == targetRank) ? 10 : 0;
    }
    
    // 親プレイヤーのスコア計算
    // 全ての順位を正しく当てられたら、プレイヤー数×10点
    final allCorrect = playerIds.where((id) => id != parentPlayerId).every((id) {
      final targetRank = playerRanks[id];
      final actualRankIndex = parentRanking.indexOf(id);
      return targetRank != null && actualRankIndex != -1 && (actualRankIndex + 1 == targetRank);
    });
    
    calculatedScores[parentPlayerId] = allCorrect ? playerIds.length * 10 : 0;
    
    return calculatedScores;
  }
}

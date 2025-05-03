import 'package:emorank_app/domain/entities/round.dart';

/// ゲームラウンドデータ操作のためのリポジトリインターフェース
abstract class RoundRepository {
  /// 新しいラウンドを作成
  Future<Round> createRound({
    required String roomId,
    required String parentPlayerId,
    required String situationCardId,
    required String emotionCardId,
  });
  
  /// ラウンドIDからラウンド情報を取得
  Future<Round?> getRoundById(String roundId);
  
  /// ルームIDに関連するすべてのラウンドを取得
  Future<List<Round>> getRoundsByRoomId(String roomId);
  
  /// ラウンドのステータスを更新
  Future<void> updateRoundStatus(String roundId, RoundStatus status);
  
  /// プレイヤーの回答を記録
  Future<void> submitResponse(String roundId, String playerId, String response);
  
  /// プレイヤーに割り当てられたランク（順位）を設定
  Future<void> assignRank(String roundId, String playerId, int rank);
  
  /// 親プレイヤーのランキングを記録
  Future<void> submitParentRanking(String roundId, List<String> ranking);
  
  /// ラウンドのスコアを更新
  Future<void> updateScores(String roundId, Map<String, int> scores);
  
  /// ラウンドを削除
  Future<void> deleteRound(String roundId);
  
  /// 特定のラウンドの情報をリアルタイムで監視
  Stream<Round?> roundStream(String roundId);
  
  /// ルームに関連するすべてのラウンドの情報をリアルタイムで監視
  Stream<List<Round>> roomRoundsStream(String roomId);
  
  /// 現在のラウンドを取得（現在進行中のラウンド）
  Future<Round?> getCurrentRound(String roomId);
}

import 'package:emorank_app/domain/entities/room.dart';

/// ゲームルームデータ操作のためのリポジトリインターフェース
abstract class RoomRepository {
  /// 新しいゲームルームを作成
  Future<Room> createRoom(String hostId);
  
  /// ルームIDからルーム情報を取得
  Future<Room?> getRoomById(String roomId);
  
  /// ユーザーが参加しているルームを取得
  Future<List<Room>> getRoomsByUserId(String userId);
  
  /// ユーザーがホストのルームを取得
  Future<List<Room>> getRoomsByHostId(String hostId);
  
  /// ルームにプレイヤーを追加
  Future<void> addPlayerToRoom(String roomId, String playerId);
  
  /// ルームからプレイヤーを削除
  Future<void> removePlayerFromRoom(String roomId, String playerId);
  
  /// ルームの状態を更新
  Future<void> updateRoomState(String roomId, GameState newState);
  
  /// ルームのカード情報を更新
  Future<void> updateRoomCards(String roomId, String? situationCardId, String? emotionCardId);
  
  /// ルームの現在のラウンドを更新
  Future<void> updateCurrentRound(String roomId, int roundNumber);
  
  /// ルームのスコアを更新
  Future<void> updateRoomScores(String roomId, Map<String, int> scores);
  
  /// ルームを削除
  Future<void> deleteRoom(String roomId);
  
  /// アクティブなルーム（参加可能なルーム）を取得
  Future<List<Room>> getActiveRooms();
  
  /// ルーム情報の変更をリアルタイムで監視
  Stream<Room?> roomStream(String roomId);
  
  /// ユーザーが参加しているルームの変更をリアルタイムで監視
  Stream<List<Room>> userRoomsStream(String userId);
}

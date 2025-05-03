import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/core/firebase/firebase_provider.dart';
import 'package:emorank_app/data/models/room_model.dart';
import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/domain/repositories/room_repository.dart';
import 'package:uuid/uuid.dart';

/// RoomRepositoryの実装クラス
class RoomRepositoryImpl implements RoomRepository {
  final FirebaseProvider _firebaseProvider;
  final Uuid _uuid;

  /// コレクション名
  static const String _collection = 'rooms';

  RoomRepositoryImpl({
    required FirebaseProvider firebaseProvider,
    Uuid? uuid,
  })  : _firebaseProvider = firebaseProvider,
        _uuid = uuid ?? const Uuid();

  /// ルームコレクションの参照を取得
  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firebaseProvider.collection(_collection);

  /// 新しいゲームルームを作成
  @override
  Future<Room> createRoom(String hostId) async {
    try {
      final roomId = _uuid.v4();
      final roomModel = RoomModel.create(
        id: roomId,
        hostId: hostId,
      );

      await _roomsCollection.doc(roomId).set(roomModel.toFirestore());
      return roomModel;
    } catch (e) {
      rethrow;
    }
  }

  /// ルームIDからルーム情報を取得
  @override
  Future<Room?> getRoomById(String roomId) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      return roomDoc.exists ? RoomModel.fromFirestore(roomDoc) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザーが参加しているルームを取得
  @override
  Future<List<Room>> getRoomsByUserId(String userId) async {
    try {
      final querySnapshot = await _roomsCollection
          .where('playerIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザーがホストのルームを取得
  @override
  Future<List<Room>> getRoomsByHostId(String hostId) async {
    try {
      final querySnapshot = await _roomsCollection
          .where('hostId', isEqualTo: hostId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// ルームにプレイヤーを追加
  @override
  Future<void> addPlayerToRoom(String roomId, String playerId) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('指定されたルームは存在しません');
      }

      final roomModel = RoomModel.fromFirestore(roomDoc);
      
      // 参加制限チェック（最大6人）
      if (roomModel.playerIds.length >= 6) {
        throw Exception('ルームが満員です（最大6人）');
      }
      
      // 既に参加している場合は何もしない
      if (roomModel.playerIds.contains(playerId)) {
        return;
      }
      
      // 進行中のゲームには参加できない
      if (roomModel.gameState != GameState.waiting) {
        throw Exception('ゲームが既に開始されています');
      }

      final updatedRoom = roomModel.addPlayer(playerId);
      await _roomsCollection.doc(roomId).update(updatedRoom.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ルームからプレイヤーを削除
  @override
  Future<void> removePlayerFromRoom(String roomId, String playerId) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('指定されたルームは存在しません');
      }

      final roomModel = RoomModel.fromFirestore(roomDoc);
      
      // 参加していない場合は何もしない
      if (!roomModel.playerIds.contains(playerId)) {
        return;
      }
      
      // ホストは退出できない（ホストが退出する場合はルームを削除する必要がある）
      if (playerId == roomModel.hostId) {
        throw Exception('ホストはルームから退出できません');
      }
      
      // 進行中のゲームからは退出できない
      if (roomModel.gameState != GameState.waiting && 
          roomModel.gameState != GameState.finished) {
        throw Exception('ゲーム進行中は退出できません');
      }

      final updatedRoom = roomModel.removePlayer(playerId);
      await _roomsCollection.doc(roomId).update(updatedRoom.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ルームの状態を更新
  @override
  Future<void> updateRoomState(String roomId, GameState newState) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('指定されたルームは存在しません');
      }

      final roomModel = RoomModel.fromFirestore(roomDoc);
      final updatedRoom = roomModel.updateGameState(newState);
      await _roomsCollection.doc(roomId).update(updatedRoom.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ルームのカード情報を更新
  @override
  Future<void> updateRoomCards(String roomId, String? situationCardId, String? emotionCardId) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('指定されたルームは存在しません');
      }

      final roomModel = RoomModel.fromFirestore(roomDoc);
      final updatedRoom = roomModel.updateCards(
        situationCardId: situationCardId,
        emotionCardId: emotionCardId,
      );
      await _roomsCollection.doc(roomId).update(updatedRoom.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ルームの現在のラウンドを更新
  @override
  Future<void> updateCurrentRound(String roomId, int roundNumber) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('指定されたルームは存在しません');
      }

      final roomModel = RoomModel.fromFirestore(roomDoc);
      final updatedRoom = roomModel.updateRound(roundNumber);
      await _roomsCollection.doc(roomId).update(updatedRoom.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ルームのスコアを更新
  @override
  Future<void> updateRoomScores(String roomId, Map<String, int> scores) async {
    try {
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('指定されたルームは存在しません');
      }

      final roomModel = RoomModel.fromFirestore(roomDoc);
      final updatedRoom = roomModel.updateScores(scores);
      await _roomsCollection.doc(roomId).update(updatedRoom.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ルームを削除
  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      await _roomsCollection.doc(roomId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// アクティブなルーム（参加可能なルーム）を取得
  @override
  Future<List<Room>> getActiveRooms() async {
    try {
      final querySnapshot = await _roomsCollection
          .where('gameState', isEqualTo: 'waiting')
          .orderBy('updatedAt', descending: true)
          .limit(20) // 取得する上限を設定
          .get();

      return querySnapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc))
          // プレイヤー数が6人未満のルームのみを返す
          .where((room) => room.playerIds.length < 6)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// ルーム情報の変更をリアルタイムで監視
  @override
  Stream<Room?> roomStream(String roomId) {
    return _roomsCollection.doc(roomId).snapshots().map((snapshot) {
      return snapshot.exists ? RoomModel.fromFirestore(snapshot) : null;
    });
  }

  /// ユーザーが参加しているルームの変更をリアルタイムで監視
  @override
  Stream<List<Room>> userRoomsStream(String userId) {
    return _roomsCollection
        .where('playerIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList();
    });
  }
}

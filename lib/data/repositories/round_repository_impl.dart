import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/core/firebase/firebase_provider.dart';
import 'package:emorank_app/data/models/round_model.dart';
import 'package:emorank_app/domain/entities/round.dart';
import 'package:emorank_app/domain/repositories/round_repository.dart';
import 'package:uuid/uuid.dart';

/// RoundRepositoryの実装クラス
class RoundRepositoryImpl implements RoundRepository {
  final FirebaseProvider _firebaseProvider;
  final Uuid _uuid;

  /// コレクション名
  static const String _collection = 'rounds';

  RoundRepositoryImpl({
    required FirebaseProvider firebaseProvider,
    Uuid? uuid,
  })  : _firebaseProvider = firebaseProvider,
        _uuid = uuid ?? const Uuid();

  /// ラウンドコレクションの参照を取得
  CollectionReference<Map<String, dynamic>> get _roundsCollection =>
      _firebaseProvider.collection(_collection);

  /// 新しいラウンドを作成
  @override
  Future<Round> createRound({
    required String roomId,
    required String parentPlayerId,
    required String situationCardId,
    required String emotionCardId,
  }) async {
    try {
      final roundId = _uuid.v4();
      final roundModel = RoundModel.create(
        id: roundId,
        roomId: roomId,
        parentPlayerId: parentPlayerId,
        situationCardId: situationCardId,
        emotionCardId: emotionCardId,
      );

      await _roundsCollection.doc(roundId).set(roundModel.toFirestore());
      return roundModel;
    } catch (e) {
      rethrow;
    }
  }

  /// ラウンドIDからラウンド情報を取得
  @override
  Future<Round?> getRoundById(String roundId) async {
    try {
      final roundDoc = await _roundsCollection.doc(roundId).get();
      return roundDoc.exists ? RoundModel.fromFirestore(roundDoc) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// ルームIDに関連するすべてのラウンドを取得
  @override
  Future<List<Round>> getRoundsByRoomId(String roomId) async {
    try {
      final querySnapshot = await _roundsCollection
          .where('roomId', isEqualTo: roomId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => RoundModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// ラウンドのステータスを更新
  @override
  Future<void> updateRoundStatus(String roundId, RoundStatus status) async {
    try {
      final roundDoc = await _roundsCollection.doc(roundId).get();
      if (!roundDoc.exists) {
        throw Exception('指定されたラウンドは存在しません');
      }

      final roundModel = RoundModel.fromFirestore(roundDoc);
      final updatedRound = roundModel.updateStatus(status);
      await _roundsCollection.doc(roundId).update(updatedRound.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// プレイヤーの回答を記録
  @override
  Future<void> submitResponse(String roundId, String playerId, String response) async {
    try {
      final roundDoc = await _roundsCollection.doc(roundId).get();
      if (!roundDoc.exists) {
        throw Exception('指定されたラウンドは存在しません');
      }

      final roundModel = RoundModel.fromFirestore(roundDoc);
      
      // ラウンドの状態チェック
      if (roundModel.status != RoundStatus.writing) {
        throw Exception('回答を提出できる状態ではありません');
      }

      final updatedRound = roundModel.submitPlayerResponse(playerId, response);
      await _roundsCollection.doc(roundId).update(updatedRound.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// プレイヤーに割り当てられたランク（順位）を設定
  @override
  Future<void> assignRank(String roundId, String playerId, int rank) async {
    try {
      final roundDoc = await _roundsCollection.doc(roundId).get();
      if (!roundDoc.exists) {
        throw Exception('指定されたラウンドは存在しません');
      }

      final roundModel = RoundModel.fromFirestore(roundDoc);
      
      // ラウンドの状態チェック
      if (roundModel.status != RoundStatus.preparing) {
        throw Exception('ランクを割り当てできる状態ではありません');
      }
      
      // 順位の範囲チェック（1〜6）
      if (rank < 1 || rank > 6) {
        throw Exception('順位は1～6の範囲で指定してください');
      }

      final updatedRound = roundModel.assignPlayerRank(playerId, rank);
      await _roundsCollection.doc(roundId).update(updatedRound.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// 親プレイヤーのランキングを記録
  @override
  Future<void> submitParentRanking(String roundId, List<String> ranking) async {
    try {
      final roundDoc = await _roundsCollection.doc(roundId).get();
      if (!roundDoc.exists) {
        throw Exception('指定されたラウンドは存在しません');
      }

      final roundModel = RoundModel.fromFirestore(roundDoc);
      
      // ラウンドの状態チェック
      if (roundModel.status != RoundStatus.ranking) {
        throw Exception('ランキングを提出できる状態ではありません');
      }
      
      // 全プレイヤーの回答が含まれているかチェック
      final respondedPlayerIds = roundModel.responses.keys.toSet();
      final rankedPlayerIds = ranking.toSet();
      
      if (respondedPlayerIds != rankedPlayerIds) {
        throw Exception('回答者全員のランキングを提供してください');
      }

      final updatedRound = roundModel.submitRanking(ranking);
      await _roundsCollection.doc(roundId).update(updatedRound.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ラウンドのスコアを更新
  @override
  Future<void> updateScores(String roundId, Map<String, int> scores) async {
    try {
      final roundDoc = await _roundsCollection.doc(roundId).get();
      if (!roundDoc.exists) {
        throw Exception('指定されたラウンドは存在しません');
      }

      final roundModel = RoundModel.fromFirestore(roundDoc);
      final updatedRound = roundModel.updateScores(scores);
      await _roundsCollection.doc(roundId).update(updatedRound.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// ラウンドを削除
  @override
  Future<void> deleteRound(String roundId) async {
    try {
      await _roundsCollection.doc(roundId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// 特定のラウンドの情報をリアルタイムで監視
  @override
  Stream<Round?> roundStream(String roundId) {
    return _roundsCollection.doc(roundId).snapshots().map((snapshot) {
      return snapshot.exists ? RoundModel.fromFirestore(snapshot) : null;
    });
  }

  /// ルームに関連するすべてのラウンドの情報をリアルタイムで監視
  @override
  Stream<List<Round>> roomRoundsStream(String roomId) {
    return _roundsCollection
        .where('roomId', isEqualTo: roomId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RoundModel.fromFirestore(doc)).toList();
    });
  }

  /// 現在のラウンドを取得（現在進行中のラウンド）
  @override
  Future<Round?> getCurrentRound(String roomId) async {
    try {
      final querySnapshot = await _roundsCollection
          .where('roomId', isEqualTo: roomId)
          .where('status', whereIn: [
            RoundStatus.preparing.toString().split('.').last,
            RoundStatus.writing.toString().split('.').last,
            RoundStatus.ranking.toString().split('.').last
          ])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return RoundModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }
}

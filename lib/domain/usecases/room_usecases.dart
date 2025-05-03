import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/domain/repositories/room_repository.dart';

/// 新しいゲームルームを作成するユースケース
class CreateRoomUseCase {
  final RoomRepository _roomRepository;

  CreateRoomUseCase(this._roomRepository);

  /// ユースケースを実行し、新しいルーム情報を返す
  Future<Room> call({required String hostId}) async {
    return await _roomRepository.createRoom(hostId);
  }
}

/// ルームにプレイヤーを参加させるユースケース
class JoinRoomUseCase {
  final RoomRepository _roomRepository;

  JoinRoomUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({required String roomId, required String playerId}) async {
    await _roomRepository.addPlayerToRoom(roomId, playerId);
  }
}

/// ルームからプレイヤーを退出させるユースケース
class LeaveRoomUseCase {
  final RoomRepository _roomRepository;

  LeaveRoomUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({required String roomId, required String playerId}) async {
    await _roomRepository.removePlayerFromRoom(roomId, playerId);
  }
}

/// ルーム情報を取得するユースケース
class GetRoomByIdUseCase {
  final RoomRepository _roomRepository;

  GetRoomByIdUseCase(this._roomRepository);

  /// ユースケースを実行し、ルーム情報を返す
  Future<Room?> call({required String roomId}) async {
    return await _roomRepository.getRoomById(roomId);
  }
}

/// ユーザーが参加しているルーム一覧を取得するユースケース
class GetUserRoomsUseCase {
  final RoomRepository _roomRepository;

  GetUserRoomsUseCase(this._roomRepository);

  /// ユースケースを実行し、ルーム一覧を返す
  Future<List<Room>> call({required String userId}) async {
    return await _roomRepository.getRoomsByUserId(userId);
  }
}

/// アクティブなルーム一覧を取得するユースケース
class GetActiveRoomsUseCase {
  final RoomRepository _roomRepository;

  GetActiveRoomsUseCase(this._roomRepository);

  /// ユースケースを実行し、アクティブなルーム一覧を返す
  Future<List<Room>> call() async {
    return await _roomRepository.getActiveRooms();
  }
}

/// ルームの状態を更新するユースケース
class UpdateRoomStateUseCase {
  final RoomRepository _roomRepository;

  UpdateRoomStateUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({required String roomId, required GameState newState}) async {
    await _roomRepository.updateRoomState(roomId, newState);
  }
}

/// ルームのカード情報を更新するユースケース
class UpdateRoomCardsUseCase {
  final RoomRepository _roomRepository;

  UpdateRoomCardsUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({
    required String roomId,
    String? situationCardId,
    String? emotionCardId,
  }) async {
    await _roomRepository.updateRoomCards(roomId, situationCardId, emotionCardId);
  }
}

/// ルームの現在のラウンドを更新するユースケース
class UpdateCurrentRoundUseCase {
  final RoomRepository _roomRepository;

  UpdateCurrentRoundUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({required String roomId, required int roundNumber}) async {
    await _roomRepository.updateCurrentRound(roomId, roundNumber);
  }
}

/// ルームのスコアを更新するユースケース
class UpdateRoomScoresUseCase {
  final RoomRepository _roomRepository;

  UpdateRoomScoresUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({required String roomId, required Map<String, int> scores}) async {
    await _roomRepository.updateRoomScores(roomId, scores);
  }
}

/// ルームを削除するユースケース
class DeleteRoomUseCase {
  final RoomRepository _roomRepository;

  DeleteRoomUseCase(this._roomRepository);

  /// ユースケースを実行
  Future<void> call({required String roomId}) async {
    await _roomRepository.deleteRoom(roomId);
  }
}

/// ルーム情報をストリームとして監視するユースケース
class RoomStreamUseCase {
  final RoomRepository _roomRepository;

  RoomStreamUseCase(this._roomRepository);

  /// ユースケースを実行し、ルーム情報のストリームを返す
  Stream<Room?> call({required String roomId}) {
    return _roomRepository.roomStream(roomId);
  }
}

/// ユーザーが参加しているルーム一覧をストリームとして監視するユースケース
class UserRoomsStreamUseCase {
  final RoomRepository _roomRepository;

  UserRoomsStreamUseCase(this._roomRepository);

  /// ユースケースを実行し、ルーム一覧のストリームを返す
  Stream<List<Room>> call({required String userId}) {
    return _roomRepository.userRoomsStream(userId);
  }
}

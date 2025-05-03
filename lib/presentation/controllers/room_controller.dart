import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/domain/usecases/room_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ルーム操作の状態を表す列挙型
enum RoomActionStatus {
  initial,  // 初期状態
  loading,  // 処理中
  success,  // 成功
  error,    // エラー
}

/// ルーム操作の状態クラス
class RoomActionState {
  final RoomActionStatus status;
  final Room? room;
  final String? errorMessage;

  const RoomActionState({
    this.status = RoomActionStatus.initial,
    this.room,
    this.errorMessage,
  });

  /// 初期状態
  factory RoomActionState.initial() => const RoomActionState();

  /// 読み込み中状態
  factory RoomActionState.loading() => const RoomActionState(
        status: RoomActionStatus.loading,
      );

  /// 成功状態
  factory RoomActionState.success(Room room) => RoomActionState(
        status: RoomActionStatus.success,
        room: room,
      );

  /// エラー状態
  factory RoomActionState.error(String message) => RoomActionState(
        status: RoomActionStatus.error,
        errorMessage: message,
      );

  /// 状態をコピーして新しいインスタンスを作成
  RoomActionState copyWith({
    RoomActionStatus? status,
    Room? room,
    String? errorMessage,
  }) {
    return RoomActionState(
      status: status ?? this.status,
      room: room ?? this.room,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ルーム作成コントローラー
class CreateRoomController extends StateNotifier<RoomActionState> {
  final CreateRoomUseCase _createRoomUseCase;

  CreateRoomController({
    required CreateRoomUseCase createRoomUseCase,
  })  : _createRoomUseCase = createRoomUseCase,
        super(RoomActionState.initial());

  /// ルームを作成
  Future<void> createRoom(String hostId) async {
    try {
      state = RoomActionState.loading();
      final room = await _createRoomUseCase(hostId: hostId);
      state = RoomActionState.success(room);
    } catch (e) {
      state = RoomActionState.error(e.toString());
    }
  }

  /// 状態をリセット
  void reset() {
    state = RoomActionState.initial();
  }
}

/// ルーム参加コントローラー
class JoinRoomController extends StateNotifier<RoomActionState> {
  final JoinRoomUseCase _joinRoomUseCase;
  final GetRoomByIdUseCase _getRoomByIdUseCase;

  JoinRoomController({
    required JoinRoomUseCase joinRoomUseCase,
    required GetRoomByIdUseCase getRoomByIdUseCase,
  })  : _joinRoomUseCase = joinRoomUseCase,
        _getRoomByIdUseCase = getRoomByIdUseCase,
        super(RoomActionState.initial());

  /// ルームに参加
  Future<void> joinRoom(String roomId, String playerId) async {
    try {
      state = RoomActionState.loading();
      
      // ルームが存在するか確認
      final room = await _getRoomByIdUseCase(roomId: roomId);
      if (room == null) {
        state = RoomActionState.error('指定されたルームが見つかりません');
        return;
      }
      
      // ルームが満員でないか確認
      if (room.playerIds.length >= 6) {
        state = RoomActionState.error('ルームが満員です（最大6人）');
        return;
      }
      
      // 既に進行中のゲームでないか確認
      if (room.gameState != GameState.waiting) {
        state = RoomActionState.error('ゲームがすでに開始されています');
        return;
      }
      
      // ルームに参加
      await _joinRoomUseCase(roomId: roomId, playerId: playerId);
      
      // 更新後のルーム情報を取得
      final updatedRoom = await _getRoomByIdUseCase(roomId: roomId);
      if (updatedRoom == null) {
        state = RoomActionState.error('ルームの情報取得に失敗しました');
        return;
      }
      
      state = RoomActionState.success(updatedRoom);
    } catch (e) {
      state = RoomActionState.error(e.toString());
    }
  }

  /// 状態をリセット
  void reset() {
    state = RoomActionState.initial();
  }
}

/// ルーム取得コントローラー
class GetRoomController extends StateNotifier<RoomActionState> {
  final GetRoomByIdUseCase _getRoomByIdUseCase;

  GetRoomController({
    required GetRoomByIdUseCase getRoomByIdUseCase,
  })  : _getRoomByIdUseCase = getRoomByIdUseCase,
        super(RoomActionState.initial());

  /// ルーム情報を取得
  Future<void> getRoom(String roomId) async {
    try {
      state = RoomActionState.loading();
      
      final room = await _getRoomByIdUseCase(roomId: roomId);
      if (room == null) {
        state = RoomActionState.error('指定されたルームが見つかりません');
        return;
      }
      
      state = RoomActionState.success(room);
    } catch (e) {
      state = RoomActionState.error(e.toString());
    }
  }

  /// 状態をリセット
  void reset() {
    state = RoomActionState.initial();
  }
}

/// ルーム作成コントローラープロバイダー
final createRoomControllerProvider =
    StateNotifierProvider<CreateRoomController, RoomActionState>((ref) {
  return CreateRoomController(
    createRoomUseCase: ref.read(createRoomUseCaseProvider),
  );
});

/// ルーム参加コントローラープロバイダー
final joinRoomControllerProvider =
    StateNotifierProvider<JoinRoomController, RoomActionState>((ref) {
  return JoinRoomController(
    joinRoomUseCase: ref.read(joinRoomUseCaseProvider),
    getRoomByIdUseCase: ref.read(getRoomByIdUseCaseProvider),
  );
});

/// ルーム取得コントローラープロバイダー
final getRoomControllerProvider =
    StateNotifierProvider<GetRoomController, RoomActionState>((ref) {
  return GetRoomController(
    getRoomByIdUseCase: ref.read(getRoomByIdUseCaseProvider),
  );
});

/// アクティブなルーム一覧プロバイダー
final activeRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final getActiveRoomsUseCase = ref.read(getActiveRoomsUseCaseProvider);
  return await getActiveRoomsUseCase();
});

/// ユーザー参加ルーム一覧プロバイダー
final userRoomsProvider = FutureProvider.family<List<Room>, String>((ref, userId) async {
  final getUserRoomsUseCase = ref.read(getUserRoomsUseCaseProvider);
  return await getUserRoomsUseCase(userId: userId);
});

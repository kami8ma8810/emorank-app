import 'package:emorank_app/domain/entities/card.dart';
import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/domain/entities/round.dart';
import 'package:emorank_app/domain/usecases/room_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ゲーム操作の状態を表す列挙型
enum GameActionStatus {
  initial,   // 初期状態
  loading,   // 処理中
  success,   // 成功
  error,     // エラー
}

/// ゲーム操作の状態クラス
class GameState {
  final GameActionStatus status;
  final String? errorMessage;
  final Room? room;
  final Round? currentRound;
  final Card? situationCard;
  final Card? emotionCard;
  final List<Card>? situationCards;
  final List<Card>? emotionCards;
  final String? response;
  final int? assignedRank;

  const GameState({
    this.status = GameActionStatus.initial,
    this.errorMessage,
    this.room,
    this.currentRound,
    this.situationCard,
    this.emotionCard,
    this.situationCards,
    this.emotionCards,
    this.response,
    this.assignedRank,
  });

  /// 初期状態
  factory GameState.initial() => const GameState();

  /// 読み込み中状態
  factory GameState.loading() => const GameState(
    status: GameActionStatus.loading,
  );

  /// 成功状態
  factory GameState.success({
    Room? room,
    Round? currentRound,
    Card? situationCard,
    Card? emotionCard,
    List<Card>? situationCards,
    List<Card>? emotionCards,
    String? response,
    int? assignedRank,
  }) => GameState(
    status: GameActionStatus.success,
    room: room,
    currentRound: currentRound,
    situationCard: situationCard,
    emotionCard: emotionCard,
    situationCards: situationCards,
    emotionCards: emotionCards,
    response: response,
    assignedRank: assignedRank,
  );

  /// エラー状態
  factory GameState.error(String message) => GameState(
    status: GameActionStatus.error,
    errorMessage: message,
  );

  /// 状態をコピーして新しいインスタンスを作成
  GameState copyWith({
    GameActionStatus? status,
    String? errorMessage,
    Room? room,
    Round? currentRound,
    Card? situationCard,
    Card? emotionCard,
    List<Card>? situationCards,
    List<Card>? emotionCards,
    String? response,
    int? assignedRank,
  }) {
    return GameState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      room: room ?? this.room,
      currentRound: currentRound ?? this.currentRound,
      situationCard: situationCard ?? this.situationCard,
      emotionCard: emotionCard ?? this.emotionCard,
      situationCards: situationCards ?? this.situationCards,
      emotionCards: emotionCards ?? this.emotionCards,
      response: response ?? this.response,
      assignedRank: assignedRank ?? this.assignedRank,
    );
  }
}

/// ゲームコントローラー
class GameController extends StateNotifier<GameState> {
  final RoomStreamUseCase _roomStreamUseCase;
  final UpdateRoomStateUseCase _updateRoomStateUseCase;
  final UpdateRoomCardsUseCase _updateRoomCardsUseCase;

  GameController({
    required RoomStreamUseCase roomStreamUseCase,
    required UpdateRoomStateUseCase updateRoomStateUseCase,
    required UpdateRoomCardsUseCase updateRoomCardsUseCase,
  })  : _roomStreamUseCase = roomStreamUseCase,
        _updateRoomStateUseCase = updateRoomStateUseCase,
        _updateRoomCardsUseCase = updateRoomCardsUseCase,
        super(GameState.initial());

  /// ルーム情報のストリームを監視
  Stream<Room?> watchRoom(String roomId) {
    return _roomStreamUseCase(roomId: roomId);
  }

  /// ゲーム状態を更新
  Future<void> updateGameState(String roomId, GameState newState) async {
    try {
      state = GameState.loading();
      await _updateRoomStateUseCase(roomId: roomId, newState: newState);
      state = GameState.success(room: state.room);
    } catch (e) {
      state = GameState.error(e.toString());
    }
  }

  /// カード情報を更新
  Future<void> updateCards(String roomId, {String? situationCardId, String? emotionCardId}) async {
    try {
      state = GameState.loading();
      await _updateRoomCardsUseCase(
        roomId: roomId,
        situationCardId: situationCardId,
        emotionCardId: emotionCardId,
      );
      state = GameState.success(room: state.room);
    } catch (e) {
      state = GameState.error(e.toString());
    }
  }

  /// 回答を提出
  void setResponse(String response) {
    state = state.copyWith(
      response: response,
    );
  }

  /// 順位を設定
  void setAssignedRank(int rank) {
    state = state.copyWith(
      assignedRank: rank,
    );
  }

  /// ゲーム状態を更新（ルーム情報）
  void updateRoomInfo(Room room) {
    state = state.copyWith(
      room: room,
    );
  }

  /// ゲーム状態を更新（カード情報）
  void updateCardInfo({Card? situationCard, Card? emotionCard}) {
    state = state.copyWith(
      situationCard: situationCard,
      emotionCard: emotionCard,
    );
  }

  /// 状態をリセット
  void reset() {
    state = GameState.initial();
  }
}

/// ゲームコントローラープロバイダー
final gameControllerProvider = StateNotifierProvider<GameController, GameState>((ref) {
  return GameController(
    roomStreamUseCase: ref.read(roomStreamUseCaseProvider),
    updateRoomStateUseCase: ref.read(updateRoomStateUseCaseProvider),
    updateRoomCardsUseCase: ref.read(updateRoomCardsUseCaseProvider),
  );
});

/// ルームストリームプロバイダー
final roomStreamProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  final gameController = ref.read(gameControllerProvider.notifier);
  return gameController.watchRoom(roomId);
});

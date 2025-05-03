import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/domain/repositories/room_repository.dart';
import 'package:emorank_app/domain/usecases/room_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  late MockRoomRepository mockRoomRepository;
  late CreateRoomUseCase createRoomUseCase;
  late JoinRoomUseCase joinRoomUseCase;
  late LeaveRoomUseCase leaveRoomUseCase;
  late GetRoomByIdUseCase getRoomByIdUseCase;
  late RoomStreamUseCase roomStreamUseCase;

  setUp(() {
    mockRoomRepository = MockRoomRepository();
    createRoomUseCase = CreateRoomUseCase(mockRoomRepository);
    joinRoomUseCase = JoinRoomUseCase(mockRoomRepository);
    leaveRoomUseCase = LeaveRoomUseCase(mockRoomRepository);
    getRoomByIdUseCase = GetRoomByIdUseCase(mockRoomRepository);
    roomStreamUseCase = RoomStreamUseCase(mockRoomRepository);
  });

  group('CreateRoomUseCase', () {
    const String testHostId = 'host123';
    final DateTime now = DateTime.now();
    final testRoom = Room(
      id: 'room123',
      hostId: testHostId,
      playerIds: [testHostId],
      createdAt: now,
      updatedAt: now,
    );

    test('新しいルームを作成できること', () async {
      // Arrange
      when(() => mockRoomRepository.createRoom(testHostId))
          .thenAnswer((_) async => testRoom);

      // Act
      final result = await createRoomUseCase(hostId: testHostId);

      // Assert
      expect(result, equals(testRoom));
      verify(() => mockRoomRepository.createRoom(testHostId)).called(1);
    });
  });

  group('JoinRoomUseCase', () {
    const String testRoomId = 'room123';
    const String testPlayerId = 'player456';

    test('プレイヤーがルームに参加できること', () async {
      // Arrange
      when(() => mockRoomRepository.addPlayerToRoom(testRoomId, testPlayerId))
          .thenAnswer((_) async {});

      // Act
      await joinRoomUseCase(roomId: testRoomId, playerId: testPlayerId);

      // Assert
      verify(() => mockRoomRepository.addPlayerToRoom(testRoomId, testPlayerId)).called(1);
    });

    test('例外が発生した場合に例外を再スローすること', () async {
      // Arrange
      when(() => mockRoomRepository.addPlayerToRoom(testRoomId, testPlayerId))
          .thenThrow(Exception('ルームが満員です'));

      // Act & Assert
      expect(
        () => joinRoomUseCase(roomId: testRoomId, playerId: testPlayerId),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRoomRepository.addPlayerToRoom(testRoomId, testPlayerId)).called(1);
    });
  });

  group('LeaveRoomUseCase', () {
    const String testRoomId = 'room123';
    const String testPlayerId = 'player456';

    test('プレイヤーがルームから退出できること', () async {
      // Arrange
      when(() => mockRoomRepository.removePlayerFromRoom(testRoomId, testPlayerId))
          .thenAnswer((_) async {});

      // Act
      await leaveRoomUseCase(roomId: testRoomId, playerId: testPlayerId);

      // Assert
      verify(() => mockRoomRepository.removePlayerFromRoom(testRoomId, testPlayerId)).called(1);
    });
  });

  group('GetRoomByIdUseCase', () {
    const String testRoomId = 'room123';
    final DateTime now = DateTime.now();
    final testRoom = Room(
      id: testRoomId,
      hostId: 'host123',
      playerIds: ['host123', 'player456'],
      createdAt: now,
      updatedAt: now,
    );

    test('有効なIDでルーム情報を取得できること', () async {
      // Arrange
      when(() => mockRoomRepository.getRoomById(testRoomId))
          .thenAnswer((_) async => testRoom);

      // Act
      final result = await getRoomByIdUseCase(roomId: testRoomId);

      // Assert
      expect(result, equals(testRoom));
      verify(() => mockRoomRepository.getRoomById(testRoomId)).called(1);
    });

    test('存在しないIDの場合nullを返すこと', () async {
      // Arrange
      const invalidRoomId = 'invalid123';
      when(() => mockRoomRepository.getRoomById(invalidRoomId))
          .thenAnswer((_) async => null);

      // Act
      final result = await getRoomByIdUseCase(roomId: invalidRoomId);

      // Assert
      expect(result, isNull);
      verify(() => mockRoomRepository.getRoomById(invalidRoomId)).called(1);
    });
  });

  group('RoomStreamUseCase', () {
    const String testRoomId = 'room123';
    final DateTime now = DateTime.now();
    final testRoom = Room(
      id: testRoomId,
      hostId: 'host123',
      playerIds: ['host123', 'player456'],
      createdAt: now,
      updatedAt: now,
    );
    
    final testRoomStream = Stream.fromIterable([testRoom]);

    test('ルーム情報のストリームを取得できること', () {
      // Arrange
      when(() => mockRoomRepository.roomStream(testRoomId))
          .thenAnswer((_) => testRoomStream);

      // Act
      final result = roomStreamUseCase(roomId: testRoomId);

      // Assert
      expect(result, emits(testRoom));
      verify(() => mockRoomRepository.roomStream(testRoomId)).called(1);
    });
  });
}

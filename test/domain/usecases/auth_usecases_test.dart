import 'package:emorank_app/domain/entities/user.dart';
import 'package:emorank_app/domain/repositories/user_repository.dart';
import 'package:emorank_app/domain/usecases/auth_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late SignInWithEmailUseCase signInWithEmailUseCase;
  late SignUpWithEmailUseCase signUpWithEmailUseCase;
  late SignInAnonymouslyUseCase signInAnonymouslyUseCase;
  late SignOutUseCase signOutUseCase;

  setUp(() {
    mockUserRepository = MockUserRepository();
    signInWithEmailUseCase = SignInWithEmailUseCase(mockUserRepository);
    signUpWithEmailUseCase = SignUpWithEmailUseCase(mockUserRepository);
    signInAnonymouslyUseCase = SignInAnonymouslyUseCase(mockUserRepository);
    signOutUseCase = SignOutUseCase(mockUserRepository);
  });

  group('SignInWithEmailUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = User(
      id: 'user1',
      displayName: 'テストユーザー',
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    test('サインイン成功時にユーザーを返すこと', () async {
      // Arrange
      when(() => mockUserRepository.signInWithEmailAndPassword(
            testEmail,
            testPassword,
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await signInWithEmailUseCase(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockUserRepository.signInWithEmailAndPassword(
            testEmail,
            testPassword,
          )).called(1);
    });

    test('例外が発生した場合に例外を再スローすること', () async {
      // Arrange
      when(() => mockUserRepository.signInWithEmailAndPassword(
            testEmail,
            testPassword,
          )).thenThrow(Exception('認証に失敗しました'));

      // Act & Assert
      expect(
        () => signInWithEmailUseCase(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<Exception>()),
      );
      verify(() => mockUserRepository.signInWithEmailAndPassword(
            testEmail,
            testPassword,
          )).called(1);
    });
  });

  group('SignUpWithEmailUseCase', () {
    const testEmail = 'newuser@example.com';
    const testPassword = 'newpassword123';
    const testDisplayName = '新規ユーザー';
    final testUser = User(
      id: 'newuser1',
      displayName: testDisplayName,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    test('サインアップ成功時に新規ユーザーを返すこと', () async {
      // Arrange
      when(() => mockUserRepository.registerWithEmailAndPassword(
            testEmail,
            testPassword,
            testDisplayName,
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await signUpWithEmailUseCase(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockUserRepository.registerWithEmailAndPassword(
            testEmail,
            testPassword,
            testDisplayName,
          )).called(1);
    });
  });

  group('SignInAnonymouslyUseCase', () {
    final testAnonymousUser = User(
      id: 'anonymous123',
      displayName: 'ゲスト',
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    test('匿名サインイン成功時にユーザーを返すこと', () async {
      // Arrange
      when(() => mockUserRepository.signInAnonymously())
          .thenAnswer((_) async => testAnonymousUser);

      // Act
      final result = await signInAnonymouslyUseCase();

      // Assert
      expect(result, equals(testAnonymousUser));
      verify(() => mockUserRepository.signInAnonymously()).called(1);
    });
  });

  group('SignOutUseCase', () {
    test('サインアウトが成功すること', () async {
      // Arrange
      when(() => mockUserRepository.signOut()).thenAnswer((_) async {});

      // Act
      await signOutUseCase();

      // Assert
      verify(() => mockUserRepository.signOut()).called(1);
    });

    test('例外が発生した場合に例外を再スローすること', () async {
      // Arrange
      when(() => mockUserRepository.signOut())
          .thenThrow(Exception('サインアウトに失敗しました'));

      // Act & Assert
      expect(
        () => signOutUseCase(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockUserRepository.signOut()).called(1);
    });
  });
}

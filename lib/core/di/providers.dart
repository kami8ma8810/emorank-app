import 'package:emorank_app/core/firebase/firebase_provider.dart';
import 'package:emorank_app/data/repositories/card_repository_impl.dart';
import 'package:emorank_app/data/repositories/room_repository_impl.dart';
import 'package:emorank_app/data/repositories/round_repository_impl.dart';
import 'package:emorank_app/data/repositories/user_repository_impl.dart';
import 'package:emorank_app/domain/repositories/card_repository.dart';
import 'package:emorank_app/domain/repositories/room_repository.dart';
import 'package:emorank_app/domain/repositories/round_repository.dart';
import 'package:emorank_app/domain/repositories/user_repository.dart';
import 'package:emorank_app/domain/usecases/auth_usecases.dart';
import 'package:emorank_app/domain/usecases/room_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

// ユーティリティプロバイダー
final uuidProvider = Provider<Uuid>((ref) => const Uuid());
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

// Firebase
final firebaseProvider = Provider<FirebaseProvider>((ref) {
  return FirebaseProvider();
});

// リポジトリプロバイダー
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    firebaseProvider: ref.read(firebaseProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(
    firebaseProvider: ref.read(firebaseProvider),
  );
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(
    firebaseProvider: ref.read(firebaseProvider),
    uuid: ref.read(uuidProvider),
  );
});

final roundRepositoryProvider = Provider<RoundRepository>((ref) {
  return RoundRepositoryImpl(
    firebaseProvider: ref.read(firebaseProvider),
    uuid: ref.read(uuidProvider),
  );
});

// 認証関連のユースケースプロバイダー
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.read(userRepositoryProvider));
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return SignUpWithEmailUseCase(ref.read(userRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.read(userRepositoryProvider));
});

final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return SignInWithAppleUseCase(ref.read(userRepositoryProvider));
});

final signInAnonymouslyUseCaseProvider = Provider<SignInAnonymouslyUseCase>((ref) {
  return SignInAnonymouslyUseCase(ref.read(userRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(userRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(userRepositoryProvider));
});

final userStreamUseCaseProvider = Provider<UserStreamUseCase>((ref) {
  return UserStreamUseCase(ref.read(userRepositoryProvider));
});

// ルーム関連のユースケースプロバイダー
final createRoomUseCaseProvider = Provider<CreateRoomUseCase>((ref) {
  return CreateRoomUseCase(ref.read(roomRepositoryProvider));
});

final joinRoomUseCaseProvider = Provider<JoinRoomUseCase>((ref) {
  return JoinRoomUseCase(ref.read(roomRepositoryProvider));
});

final leaveRoomUseCaseProvider = Provider<LeaveRoomUseCase>((ref) {
  return LeaveRoomUseCase(ref.read(roomRepositoryProvider));
});

final getRoomByIdUseCaseProvider = Provider<GetRoomByIdUseCase>((ref) {
  return GetRoomByIdUseCase(ref.read(roomRepositoryProvider));
});

final getUserRoomsUseCaseProvider = Provider<GetUserRoomsUseCase>((ref) {
  return GetUserRoomsUseCase(ref.read(roomRepositoryProvider));
});

final getActiveRoomsUseCaseProvider = Provider<GetActiveRoomsUseCase>((ref) {
  return GetActiveRoomsUseCase(ref.read(roomRepositoryProvider));
});

final updateRoomStateUseCaseProvider = Provider<UpdateRoomStateUseCase>((ref) {
  return UpdateRoomStateUseCase(ref.read(roomRepositoryProvider));
});

final roomStreamUseCaseProvider = Provider<RoomStreamUseCase>((ref) {
  return RoomStreamUseCase(ref.read(roomRepositoryProvider));
});

// カード関連のユースケースプロバイダー
final getRandomCardsUseCaseProvider = Provider((ref) {
  final cardRepository = ref.read(cardRepositoryProvider);
  return ({
    Future<dynamic> getRandomSituationCard() => cardRepository.getRandomSituationCard(),
    Future<dynamic> getRandomEmotionCard() => cardRepository.getRandomEmotionCard(),
  });
});

// その他必要なユースケースプロバイダーは必要に応じて追加

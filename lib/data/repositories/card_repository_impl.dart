import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/core/firebase/firebase_provider.dart';
import 'package:emorank_app/data/models/card_model.dart';
import 'package:emorank_app/domain/entities/card.dart';
import 'package:emorank_app/domain/repositories/card_repository.dart';

/// CardRepositoryの実装クラス
class CardRepositoryImpl implements CardRepository {
  final FirebaseProvider _firebaseProvider;

  /// コレクション名
  static const String _collection = 'cards';

  CardRepositoryImpl({
    required FirebaseProvider firebaseProvider,
  }) : _firebaseProvider = firebaseProvider;

  /// カードコレクションの参照を取得
  CollectionReference<Map<String, dynamic>> get _cardsCollection =>
      _firebaseProvider.collection(_collection);

  /// すべてのシチュエーションカードを取得
  @override
  Future<List<SituationCard>> getAllSituationCards() async {
    try {
      final querySnapshot = await _cardsCollection
          .where('type', isEqualTo: 'situation')
          .get();

      return querySnapshot.docs
          .map((doc) => SituationCardModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// すべての感情カードを取得
  @override
  Future<List<EmotionCard>> getAllEmotionCards() async {
    try {
      final querySnapshot = await _cardsCollection
          .where('type', isEqualTo: 'emotion')
          .get();

      return querySnapshot.docs
          .map((doc) => EmotionCardModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// IDからカードを取得
  @override
  Future<Card?> getCardById(String cardId) async {
    try {
      final cardDoc = await _cardsCollection.doc(cardId).get();
      if (!cardDoc.exists) {
        return null;
      }

      final data = cardDoc.data()!;
      final type = data['type'] as String;
      
      if (type == 'situation') {
        return SituationCardModel.fromFirestore(cardDoc);
      } else if (type == 'emotion') {
        return EmotionCardModel.fromFirestore(cardDoc);
      }
      
      return CardModel.fromFirestore(cardDoc);
    } catch (e) {
      rethrow;
    }
  }

  /// カードをカテゴリで絞り込み
  @override
  Future<List<Card>> getCardsByCategory(String category) async {
    try {
      final querySnapshot = await _cardsCollection
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final type = data['type'] as String;
        
        if (type == 'situation') {
          return SituationCardModel.fromFirestore(doc);
        } else if (type == 'emotion') {
          return EmotionCardModel.fromFirestore(doc);
        }
        
        return CardModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// ランダムなシチュエーションカードを取得
  @override
  Future<SituationCard> getRandomSituationCard() async {
    try {
      final situationCards = await getAllSituationCards();
      if (situationCards.isEmpty) {
        throw Exception('シチュエーションカードが登録されていません');
      }
      
      final random = Random();
      return situationCards[random.nextInt(situationCards.length)];
    } catch (e) {
      rethrow;
    }
  }

  /// ランダムな感情カードを取得
  @override
  Future<EmotionCard> getRandomEmotionCard() async {
    try {
      final emotionCards = await getAllEmotionCards();
      if (emotionCards.isEmpty) {
        throw Exception('感情カードが登録されていません');
      }
      
      final random = Random();
      return emotionCards[random.nextInt(emotionCards.length)];
    } catch (e) {
      rethrow;
    }
  }

  /// 新しいカードを追加
  @override
  Future<void> addCard(Card card) async {
    try {
      if (card is SituationCard) {
        final model = SituationCardModel.fromEntity(card);
        await _cardsCollection.doc(card.id).set(model.toFirestore());
      } else if (card is EmotionCard) {
        final model = EmotionCardModel.fromEntity(card);
        await _cardsCollection.doc(card.id).set(model.toFirestore());
      } else {
        final model = CardModel.fromEntity(card);
        await _cardsCollection.doc(card.id).set(model.toFirestore());
      }
    } catch (e) {
      rethrow;
    }
  }

  /// カード情報を更新
  @override
  Future<void> updateCard(Card card) async {
    try {
      if (card is SituationCard) {
        final model = SituationCardModel.fromEntity(card);
        await _cardsCollection.doc(card.id).update(model.toFirestore());
      } else if (card is EmotionCard) {
        final model = EmotionCardModel.fromEntity(card);
        await _cardsCollection.doc(card.id).update(model.toFirestore());
      } else {
        final model = CardModel.fromEntity(card);
        await _cardsCollection.doc(card.id).update(model.toFirestore());
      }
    } catch (e) {
      rethrow;
    }
  }

  /// カードを削除
  @override
  Future<void> deleteCard(String cardId) async {
    try {
      await _cardsCollection.doc(cardId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// カード情報の変更をリアルタイムで監視
  @override
  Stream<List<Card>> cardsStream({CardType? type, String? category}) {
    Query<Map<String, dynamic>> query = _cardsCollection;
    
    if (type != null) {
      final typeString = type.toString().split('.').last;
      query = query.where('type', isEqualTo: typeString);
    }
    
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final docType = data['type'] as String;
        
        if (docType == 'situation') {
          return SituationCardModel.fromFirestore(doc);
        } else if (docType == 'emotion') {
          return EmotionCardModel.fromFirestore(doc);
        }
        
        return CardModel.fromFirestore(doc);
      }).toList();
    });
  }
}

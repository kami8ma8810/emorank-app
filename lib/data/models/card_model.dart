import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emorank_app/domain/entities/card.dart';

/// Firestore用のカードモデルクラス
class CardModel extends Card {
  const CardModel({
    required super.id,
    required super.type,
    required super.text,
    super.category,
  });

  /// Firestoreのドキュメントからインスタンスを作成
  factory CardModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return CardModel(
      id: document.id,
      type: CardType.values.firstWhere(
        (e) => e.toString() == 'CardType.${data['type']}',
        orElse: () => CardType.situation,
      ),
      text: data['text'] ?? '',
      category: data['category'],
    );
  }

  /// ドメインエンティティからモデルを作成
  factory CardModel.fromEntity(Card card) {
    return CardModel(
      id: card.id,
      type: card.type,
      text: card.text,
      category: card.category,
    );
  }

  /// Firestoreに保存するためのマップを取得
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'text': text,
      'category': category,
    };
  }

  /// シチュエーションカードのモデルを作成
  factory CardModel.situation({
    required String id,
    required String text,
    String? category,
  }) {
    return CardModel(
      id: id,
      type: CardType.situation,
      text: text,
      category: category,
    );
  }

  /// 感情カードのモデルを作成
  factory CardModel.emotion({
    required String id,
    required String text,
    String? category,
  }) {
    return CardModel(
      id: id,
      type: CardType.emotion,
      text: text,
      category: category,
    );
  }

  /// カードモデルの更新
  CardModel copyWithModel({
    String? id,
    CardType? type,
    String? text,
    String? category,
  }) {
    return CardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      category: category ?? this.category,
    );
  }
}

/// シチュエーションカードのモデルクラス
class SituationCardModel extends SituationCard {
  const SituationCardModel({
    required super.id,
    required super.text,
    super.category,
  });

  /// Firestoreのドキュメントからインスタンスを作成
  factory SituationCardModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return SituationCardModel(
      id: document.id,
      text: data['text'] ?? '',
      category: data['category'],
    );
  }

  /// ドメインエンティティからモデルを作成
  factory SituationCardModel.fromEntity(SituationCard card) {
    return SituationCardModel(
      id: card.id,
      text: card.text,
      category: card.category,
    );
  }

  /// Firestoreに保存するためのマップを取得
  Map<String, dynamic> toFirestore() {
    return {
      'type': 'situation',
      'text': text,
      'category': category,
    };
  }
}

/// 感情カードのモデルクラス
class EmotionCardModel extends EmotionCard {
  const EmotionCardModel({
    required super.id,
    required super.text,
    super.category,
  });

  /// Firestoreのドキュメントからインスタンスを作成
  factory EmotionCardModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return EmotionCardModel(
      id: document.id,
      text: data['text'] ?? '',
      category: data['category'],
    );
  }

  /// ドメインエンティティからモデルを作成
  factory EmotionCardModel.fromEntity(EmotionCard card) {
    return EmotionCardModel(
      id: card.id,
      text: card.text,
      category: card.category,
    );
  }

  /// Firestoreに保存するためのマップを取得
  Map<String, dynamic> toFirestore() {
    return {
      'type': 'emotion',
      'text': text,
      'category': category,
    };
  }
}

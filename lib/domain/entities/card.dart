import 'package:equatable/equatable.dart';

/// カードの種類を表す列挙型
enum CardType {
  situation, // シチュエーションカード
  emotion, // 感情カード
}

/// カードを表すエンティティクラス
class Card extends Equatable {
  final String id;
  final CardType type;
  final String text;
  final String? category;

  const Card({
    required this.id,
    required this.type,
    required this.text,
    this.category,
  });

  @override
  List<Object?> get props => [id, type, text, category];

  /// カード情報をコピーして新しいインスタンスを作成
  Card copyWith({
    String? id,
    CardType? type,
    String? text,
    String? category,
  }) {
    return Card(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      category: category ?? this.category,
    );
  }
}

/// シチュエーションカードのファクトリクラス
class SituationCard extends Card {
  const SituationCard({
    required super.id,
    required super.text,
    super.category,
  }) : super(type: CardType.situation);

  @override
  SituationCard copyWith({
    String? id,
    String? text,
    String? category,
  }) {
    return SituationCard(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
    );
  }
}

/// 感情カードのファクトリクラス
class EmotionCard extends Card {
  const EmotionCard({
    required super.id,
    required super.text,
    super.category,
  }) : super(type: CardType.emotion);

  @override
  EmotionCard copyWith({
    String? id,
    String? text,
    String? category,
  }) {
    return EmotionCard(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
    );
  }
}

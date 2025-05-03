import 'package:emorank_app/domain/entities/card.dart';

/// カードデータ操作のためのリポジトリインターフェース
abstract class CardRepository {
  /// すべてのシチュエーションカードを取得
  Future<List<SituationCard>> getAllSituationCards();
  
  /// すべての感情カードを取得
  Future<List<EmotionCard>> getAllEmotionCards();
  
  /// IDからカードを取得
  Future<Card?> getCardById(String cardId);
  
  /// カードをカテゴリで絞り込み
  Future<List<Card>> getCardsByCategory(String category);
  
  /// ランダムなシチュエーションカードを取得
  Future<SituationCard> getRandomSituationCard();
  
  /// ランダムな感情カードを取得
  Future<EmotionCard> getRandomEmotionCard();
  
  /// 新しいカードを追加
  Future<void> addCard(Card card);
  
  /// カード情報を更新
  Future<void> updateCard(Card card);
  
  /// カードを削除
  Future<void> deleteCard(String cardId);
  
  /// カード情報の変更をリアルタイムで監視
  Stream<List<Card>> cardsStream({CardType? type, String? category});
}

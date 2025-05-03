import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/domain/entities/card.dart' as card_entity;
import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/controllers/game_controller.dart';
import 'package:emorank_app/presentation/controllers/room_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ゲームプレイ画面
class GamePlayPage extends ConsumerStatefulWidget {
  final String roomId;

  const GamePlayPage({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends ConsumerState<GamePlayPage> {
  // 回答入力コントローラー
  final _responseController = TextEditingController();
  
  // 親プレイヤーの回答
  String _parentResponse = '';
  
  // 選択された順位
  int? _selectedRank;
  
  // ゲームの現在のフェーズを表すローカル状態
  // カード選択中、回答入力中、ランキング中、結果表示中など
  String _gamePhase = 'loading';
  
  // シミュレーション用の仮データ
  final _sampleSituationCards = [
    _MockCard(id: '1', text: '運動会で', type: card_entity.CardType.situation),
    _MockCard(id: '2', text: '会社の飲み会で', type: card_entity.CardType.situation),
    _MockCard(id: '3', text: '初デートで', type: card_entity.CardType.situation),
  ];
  
  final _sampleEmotionCards = [
    _MockCard(id: '1', text: 'はずかしいこと', type: card_entity.CardType.emotion),
    _MockCard(id: '2', text: 'うれしいこと', type: card_entity.CardType.emotion),
    _MockCard(id: '3', text: '悲しいこと', type: card_entity.CardType.emotion),
  ];
  
  card_entity.Card? _selectedSituationCard;
  card_entity.Card? _selectedEmotionCard;
  
  // 参加者の回答一覧
  final Map<String, String> _playerResponses = {};
  
  // 親の並べ替え結果
  final List<String> _parentRanking = [];
  
  @override
  void initState() {
    super.initState();
    // ルーム情報のストリームを購読
    _initGameState();
  }
  
  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
  
  /// ゲーム状態の初期化
  Future<void> _initGameState() async {
    // 実際のアプリではサーバーからカード情報やゲーム状態を取得する
    // ここではシミュレーションのため3秒後にカード選択フェーズに遷移
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _gamePhase = 'selecting_cards';
      });
    });
  }
  
  /// カードを選択
  void _selectCards(card_entity.Card situationCard, card_entity.Card emotionCard) {
    setState(() {
      _selectedSituationCard = situationCard;
      _selectedEmotionCard = emotionCard;
      _gamePhase = 'writing_responses';
      
      // シミュレーション：親プレイヤーの回答を設定
      _parentResponse = '親プレイヤーの回答例：通り過ぎる人に声をかけられないで固まってしまった';
      
      // シミュレーション：各プレイヤーの順位をランダムに割り当て
      final ranks = [1, 2, 3, 4, 5];
      ranks.shuffle();
      _selectedRank = ranks[0];
    });
  }
  
  /// 回答を提出
  void _submitResponse() {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('回答を入力してください'),
        ),
      );
      return;
    }
    
    setState(() {
      // シミュレーション：本来はサーバーに回答を送信する
      _playerResponses['player_1'] = _responseController.text;
      _playerResponses['player_2'] = '友達が転んで笑ってしまった';
      _playerResponses['player_3'] = '応援している友達がゴールしたとき';
      _playerResponses['player_4'] = '徒競走でビリになってしまった';
      
      _gamePhase = 'all_responses';
    });
  }
  
  /// 親プレイヤーがランキングを提出
  void _submitRanking() {
    setState(() {
      // シミュレーション：本来はサーバーにランキングを送信する
      _parentRanking.addAll(_playerResponses.keys.toList());
      _gamePhase = 'results';
    });
  }
  
  /// ゲームを終了して結果画面に遷移
  void _finishGame() {
    // 実際のアプリではゲーム状態を更新して結果画面に遷移
    context.go('/game/${widget.roomId}/result');
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('エモラン'),
        actions: [
          IconButton(
            onPressed: () {
              // ゲームを途中で終了する確認ダイアログ
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ゲームを終了しますか？'),
                  content: const Text('ゲームを途中で終了すると、現在の進行状況は保存されません。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/rooms/${widget.roomId}');
                      },
                      child: const Text('終了する'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'ゲームを終了',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildGameContent(context, colorScheme, textTheme),
      ),
    );
  }
  
  /// ゲームフェーズに応じたコンテンツを構築
  Widget _buildGameContent(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    switch (_gamePhase) {
      case 'loading':
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('ゲームを準備中...'),
            ],
          ),
        );
        
      case 'selecting_cards':
        return _buildCardSelectionPhase(context, colorScheme, textTheme);
        
      case 'writing_responses':
        return _buildResponseInputPhase(context, colorScheme, textTheme);
        
      case 'all_responses':
        return _buildAllResponsesPhase(context, colorScheme, textTheme);
        
      case 'results':
        return _buildResultsPhase(context, colorScheme, textTheme);
        
      default:
        return const Center(child: Text('不明なゲームフェーズです'));
    }
  }
  
  /// カード選択フェーズのUI
  Widget _buildCardSelectionPhase(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'カードを選択',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'お題となるシチュエーションカードと感情カードを選びましょう',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // シチュエーションカード選択
          Text(
            'シチュエーションカード',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _sampleSituationCards.length,
              itemBuilder: (context, index) {
                final card = _sampleSituationCards[index];
                final isSelected = _selectedSituationCard?.id == card.id;
                
                return _CardItem(
                  card: card,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedSituationCard = card;
                    });
                  },
                  color: colorScheme.primary,
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 感情カード選択
          Text(
            '感情カード',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _sampleEmotionCards.length,
              itemBuilder: (context, index) {
                final card = _sampleEmotionCards[index];
                final isSelected = _selectedEmotionCard?.id == card.id;
                
                return _CardItem(
                  card: card,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedEmotionCard = card;
                    });
                  },
                  color: colorScheme.secondary,
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 決定ボタン
          ElevatedButton(
            onPressed: _selectedSituationCard != null && _selectedEmotionCard != null
                ? () => _selectCards(_selectedSituationCard!, _selectedEmotionCard!)
                : null,
            child: const Text('カードを確定する'),
          ),
        ],
      ),
    );
  }
  
  /// 回答入力フェーズのUI
  Widget _buildResponseInputPhase(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final situationText = _selectedSituationCard?.text ?? '';
    final emotionText = _selectedEmotionCard?.text ?? '';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // お題表示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'お題',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: situationText,
                        style: TextStyle(
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' の '),
                      TextSpan(
                        text: emotionText,
                        style: TextStyle(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 親プレイヤーの回答（基準）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '親プレイヤーの回答（基準）',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _parentResponse,
                  style: textTheme.titleSmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 割り当てられた順位
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'あなたの順位',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_selectedRank位',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'この順位に合致すると思う回答を考えてください',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 回答入力
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あなたの回答',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _responseController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: '$_selectedRank位になると思う回答を入力してください',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 提出ボタン
          ElevatedButton(
            onPressed: _submitResponse,
            child: const Text('回答を提出する'),
          ),
        ],
      ),
    );
  }
  
  /// 全員の回答表示フェーズのUI
  Widget _buildAllResponsesPhase(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final situationText = _selectedSituationCard?.text ?? '';
    final emotionText = _selectedEmotionCard?.text ?? '';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // お題表示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'お題',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: situationText,
                        style: TextStyle(
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' の '),
                      TextSpan(
                        text: emotionText,
                        style: TextStyle(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 全員の回答
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '全員の回答',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _playerResponses.length,
                    itemBuilder: (context, index) {
                      final playerId = _playerResponses.keys.elementAt(index);
                      final response = _playerResponses[playerId]!;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            response,
                            style: textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            'プレイヤー ${index + 1}',
                            style: textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 親プレイヤーの場合はランキングボタン、それ以外は待機メッセージ
          _buildActionButton(colorScheme, textTheme),
        ],
      ),
    );
  }
  
  /// 結果表示フェーズのUI
  Widget _buildResultsPhase(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '結果発表',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // 実際は正解情報と得点を表示
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ゲーム終了！',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '得点は10点です',
                    style: textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 結果画面へボタン
          ElevatedButton(
            onPressed: _finishGame,
            child: const Text('詳細結果を確認する'),
          ),
        ],
      ),
    );
  }
  
  /// フェーズに応じたアクションボタンを構築
  Widget _buildActionButton(ColorScheme colorScheme, TextTheme textTheme) {
    // 通常はユーザーが親プレイヤーか判定し、適切なボタンを表示
    // シミュレーションでは常に親プレイヤーとして扱う
    const isParentPlayer = true;
    
    if (isParentPlayer) {
      return ElevatedButton(
        onPressed: _submitRanking,
        child: const Text('ランキングを決定する'),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '親プレイヤーがランキングを決定するのを待っています...',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
  }
}

/// カードアイテムウィジェット
class _CardItem extends StatelessWidget {
  final _MockCard card;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _CardItem({
    required this.card,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.2) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              card.text,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// シミュレーション用のモックカードクラス
class _MockCard implements card_entity.Card {
  @override
  final String id;
  
  @override
  final String text;
  
  @override
  final card_entity.CardType type;
  
  @override
  final String? category;
  
  const _MockCard({
    required this.id,
    required this.text,
    required this.type,
    this.category,
  });
}

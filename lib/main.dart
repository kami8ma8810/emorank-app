import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリケーションのエントリーポイント
void main() {
  // Flutter初期化を待機
  WidgetsFlutterBinding.ensureInitialized();
  
  // アプリケーション起動
  runApp(
    const ProviderScope(
      child: EmoRankApp(),
    ),
  );
}

/// エモランアプリケーションクラス
class EmoRankApp extends StatelessWidget {
  const EmoRankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'エモラン',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D28D9), // 紫色をベースカラーに
          secondary: const Color(0xFFEF4444), // アクセントカラーに赤色
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

/// デモ用のホーム画面
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('エモラン'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴ代わりに表示
            Icon(
              Icons.emoji_events,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'エモラン',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'あなたならどんな順位にする？感情ランキングゲーム',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            // ゲームの説明
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'ゲームの遊び方',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '「運動会で」「はずかしいこと」などのテーマに沿った答えを全員が書き、親プレイヤーはそれぞれの回答を感情の度合いで順位づけしていきます。はたして狙い通りの順位に選ばれることができるでしょうか？',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // ボタン
            ElevatedButton(
              onPressed: () {
                // ゲームプレイ画面に遷移
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DemoGamePlayPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('ゲームを始める'),
            ),
          ],
        ),
      ),
    );
  }
}

/// デモ用のゲームプレイ画面
class DemoGamePlayPage extends StatefulWidget {
  const DemoGamePlayPage({super.key});

  @override
  State<DemoGamePlayPage> createState() => _DemoGamePlayPageState();
}

class _DemoGamePlayPageState extends State<DemoGamePlayPage> {
  // 回答入力コントローラー
  final _responseController = TextEditingController();
  
  // 選択されたカードの状態
  String _selectedSituation = '';
  String _selectedEmotion = '';
  
  // 現在のゲームフェーズ
  String _gamePhase = 'selecting_cards';
  
  // 選択された順位
  int? _selectedRank;
  
  // 参加者の回答一覧
  final Map<String, String> _playerResponses = {};
  
  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('エモラン'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: _buildGameContent(context, colorScheme, textTheme),
      ),
    );
  }
  
  /// ゲームフェーズに応じたコンテンツを構築
  Widget _buildGameContent(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    switch (_gamePhase) {
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
    // サンプルカード
    final situations = ['運動会で', '会社の飲み会で', '初デートで'];
    final emotions = ['はずかしいこと', 'うれしいこと', '悲しいこと'];
    
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
              itemCount: situations.length,
              itemBuilder: (context, index) {
                final card = situations[index];
                final isSelected = _selectedSituation == card;
                
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? colorScheme.primary.withOpacity(0.2) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: colorScheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSituation = card;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          card,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected ? colorScheme.primary : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
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
              itemCount: emotions.length,
              itemBuilder: (context, index) {
                final card = emotions[index];
                final isSelected = _selectedEmotion == card;
                
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? colorScheme.secondary.withOpacity(0.2) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: colorScheme.secondary, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedEmotion = card;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          card,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected ? colorScheme.secondary : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 決定ボタン
          ElevatedButton(
            onPressed: _selectedSituation.isNotEmpty && _selectedEmotion.isNotEmpty
                ? () {
                    setState(() {
                      _gamePhase = 'writing_responses';
                      
                      // ランダムな順位を割り当て
                      final ranks = [1, 2, 3, 4, 5];
                      ranks.shuffle();
                      _selectedRank = ranks[0];
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('カードを確定する'),
          ),
        ],
      ),
    );
  }
  
  /// 回答入力フェーズのUI
  Widget _buildResponseInputPhase(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    // 親プレイヤーの回答例
    const parentResponse = '通り過ぎる人に声をかけられないで固まってしまった';
    
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
                        text: _selectedSituation,
                        style: TextStyle(
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' の '),
                      TextSpan(
                        text: _selectedEmotion,
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
                  parentResponse,
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
            onPressed: () {
              if (_responseController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('回答を入力してください'),
                  ),
                );
                return;
              }
              
              setState(() {
                // シミュレーション用にランダムな回答を生成
                _playerResponses['player_1'] = _responseController.text;
                _playerResponses['player_2'] = '友達が転んで笑ってしまった';
                _playerResponses['player_3'] = '応援している友達がゴールしたとき';
                _playerResponses['player_4'] = '徒競走でビリになってしまった';
                
                _gamePhase = 'all_responses';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('回答を提出する'),
          ),
        ],
      ),
    );
  }
  
  /// 全員の回答表示フェーズのUI
  Widget _buildAllResponsesPhase(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
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
                        text: _selectedSituation,
                        style: TextStyle(
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' の '),
                      TextSpan(
                        text: _selectedEmotion,
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
          
          // ランキングボタン
          ElevatedButton(
            onPressed: () {
              setState(() {
                _gamePhase = 'results';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ランキングを決定する'),
          ),
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
          
          // ホームに戻るボタン
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    );
  }
}

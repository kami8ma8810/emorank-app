import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/controllers/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ゲーム結果画面
class GameResultPage extends ConsumerStatefulWidget {
  final String roomId;

  const GameResultPage({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<GameResultPage> createState() => _GameResultPageState();
}

class _GameResultPageState extends ConsumerState<GameResultPage> {
  // シミュレーション用のサンプルデータ
  final Map<String, int> _playerScores = {
    'player_1': 30,
    'player_2': 20,
    'player_3': 10,
    'player_4': 40,
    'player_5': 0,
  };

  final Map<String, String> _playerNames = {
    'player_1': 'あなた',
    'player_2': 'プレイヤー2',
    'player_3': 'プレイヤー3',
    'player_4': 'プレイヤー4',
    'player_5': 'プレイヤー5',
  };

  // 表示するラウンド番号（全ラウンド結果を表示する場合は-1）
  int _displayRound = -1;

  @override
  void initState() {
    super.initState();
    // 実際のアプリでは、ゲーム結果をサーバーから取得する
  }

  /// ルームに戻る
  void _backToRoom() {
    context.go('/rooms/${widget.roomId}');
  }

  /// 別のゲームを始める
  void _startNewGame() {
    // ホーム画面に戻る
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム結果'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 結果ヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.secondary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'ゲーム終了！',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '最終スコア',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ラウンド選択タブ
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _RoundTab(
                      label: '全ラウンド',
                      isSelected: _displayRound == -1,
                      onTap: () => setState(() => _displayRound = -1),
                    ),
                  ),
                  Expanded(
                    child: _RoundTab(
                      label: 'ラウンド1',
                      isSelected: _displayRound == 0,
                      onTap: () => setState(() => _displayRound = 0),
                    ),
                  ),
                  Expanded(
                    child: _RoundTab(
                      label: 'ラウンド2',
                      isSelected: _displayRound == 1,
                      onTap: () => setState(() => _displayRound = 1),
                    ),
                  ),
                  Expanded(
                    child: _RoundTab(
                      label: 'ラウンド3',
                      isSelected: _displayRound == 2,
                      onTap: () => setState(() => _displayRound = 2),
                    ),
                  ),
                ],
              ),
            ),

            // 順位リスト
            Expanded(
              child: _displayRound == -1
                  ? _buildTotalScoreList(colorScheme, textTheme)
                  : _buildRoundResultList(colorScheme, textTheme),
            ),

            // アクションボタン
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _backToRoom,
                      child: const Text('ルームに戻る'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startNewGame,
                      child: const Text('新しいゲームへ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 総合スコアリストを構築
  Widget _buildTotalScoreList(ColorScheme colorScheme, TextTheme textTheme) {
    // スコアでソート
    final sortedPlayers = _playerScores.keys.toList()
      ..sort((a, b) => _playerScores[b]!.compareTo(_playerScores[a]!));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedPlayers.length,
      itemBuilder: (context, index) {
        final playerId = sortedPlayers[index];
        final score = _playerScores[playerId]!;
        final playerName = _playerNames[playerId] ?? 'プレイヤー';
        final rank = index + 1;

        // 1位から3位は特別な表示
        final bool isTopRank = rank <= 3;
        final List<Color> rankColors = [
          Colors.amber, // 金
          Colors.grey.shade300, // 銀
          Colors.brown.shade300, // 銅
        ];

        return Card(
          elevation: isTopRank ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isTopRank
                ? BorderSide(
                    color: rankColors[rank - 1],
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTopRank
                    ? rankColors[rank - 1]
                    : Colors.grey.shade100,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTopRank ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            title: Text(
              playerName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$score点',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 各ラウンドの結果リストを構築
  Widget _buildRoundResultList(ColorScheme colorScheme, TextTheme textTheme) {
    // シミュレーション用のラウンドデータ
    final roundResults = [
      {
        'player_1': {'rank': 2, 'matched': true, 'score': 10},
        'player_2': {'rank': 3, 'matched': false, 'score': 0},
        'player_3': {'rank': 1, 'matched': true, 'score': 10},
        'player_4': {'rank': 5, 'matched': false, 'score': 0},
        'player_5': {'rank': 4, 'matched': false, 'score': 0},
      },
      {
        'player_1': {'rank': 4, 'matched': false, 'score': 0},
        'player_2': {'rank': 1, 'matched': true, 'score': 10},
        'player_3': {'rank': 5, 'matched': false, 'score': 0},
        'player_4': {'rank': 2, 'matched': true, 'score': 10},
        'player_5': {'rank': 3, 'matched': false, 'score': 0},
      },
      {
        'player_1': {'rank': 3, 'matched': true, 'score': 10},
        'player_2': {'rank': 5, 'matched': true, 'score': 10},
        'player_3': {'rank': 2, 'matched': false, 'score': 0},
        'player_4': {'rank': 1, 'matched': true, 'score': 30},
        'player_5': {'rank': 4, 'matched': false, 'score': 0},
      },
    ];

    if (_displayRound >= roundResults.length) {
      return const Center(child: Text('このラウンドのデータはありません'));
    }

    final roundResult = roundResults[_displayRound];

    // 順位でソート
    final sortedPlayers = roundResult.keys.toList()
      ..sort((a, b) => (roundResult[a]!['rank'] as int)
          .compareTo(roundResult[b]!['rank'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ラウンド${_displayRound + 1}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'お題：運動会で はずかしいこと',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '親プレイヤー: ${_playerNames['player_${_displayRound + 1}'] ?? 'プレイヤー'}',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              final playerId = sortedPlayers[index];
              final result = roundResult[playerId]!;
              final rank = result['rank'] as int;
              final matched = result['matched'] as bool;
              final score = result['score'] as int;
              final playerName = _playerNames[playerId] ?? 'プレイヤー';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: matched
                      ? BorderSide(
                          color: Colors.green,
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    playerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '回答: 徒競走で転んでしまった', // サンプル回答
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (matched)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: matched
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$score点',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: matched ? Colors.green : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ラウンドタブウィジェット
class _RoundTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoundTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

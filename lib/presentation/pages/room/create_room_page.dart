import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/controllers/room_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ルーム作成画面
class CreateRoomPage extends ConsumerStatefulWidget {
  const CreateRoomPage({super.key});

  @override
  ConsumerState<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends ConsumerState<CreateRoomPage> {
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // コントローラーの状態をリセット
    ref.read(createRoomControllerProvider.notifier).reset();
  }

  /// ルームを作成
  Future<void> _createRoom() async {
    final user = ref.read(authUserProvider);
    if (user == null) {
      _showErrorSnackBar('ユーザー情報の取得に失敗しました');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await ref.read(createRoomControllerProvider.notifier).createRoom(user.id);
    } catch (e) {
      _showErrorSnackBar('ルーム作成に失敗しました: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  /// エラーメッセージを表示
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // ルーム作成状態を監視
    final createRoomState = ref.watch(createRoomControllerProvider);
    
    // 成功したらルーム詳細画面に遷移
    if (createRoomState.status == RoomActionStatus.success && createRoomState.room != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/rooms/${createRoomState.room!.id}');
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム作成'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // エラーメッセージ
              if (createRoomState.status == RoomActionStatus.error)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    createRoomState.errorMessage ?? 'エラーが発生しました',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // ルーム作成の説明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ルーム作成について',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ルームを作成すると、あなたがホストとなります。友達を招待して一緒にエモランを楽しみましょう！',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // ルールの説明
              Text(
                'エモランのルール',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RuleItem(
                        number: 1,
                        title: 'カードを選択',
                        description: 'シチュエーションカードと感情カードから1枚ずつ選び、お題を決めます。',
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      _RuleItem(
                        number: 2,
                        title: '順位タイル配布',
                        description: '親プレイヤーは基準となる回答を書き、他のプレイヤーは順位タイルをもらいます。',
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      _RuleItem(
                        number: 3,
                        title: '回答を記入',
                        description: '順位に合わせた回答を考えて書きましょう。親プレイヤーは自分の順位を知りません。',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _RuleItem(
                        number: 4,
                        title: 'ランキング付け',
                        description: '親プレイヤーが全員の回答を基準に並べ替えます。',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _RuleItem(
                        number: 5,
                        title: '得点計算',
                        description: '正しい順位になった人は10点、親プレイヤーが全て当てると人数×10点獲得できます。',
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      _RuleItem(
                        number: 6,
                        title: 'ゲーム終了',
                        description: '全員が親プレイヤーを1回ずつ務めたらゲーム終了です。最も得点が高い人の勝利！',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ルーム作成ボタン
              ElevatedButton(
                onPressed: _isCreating ||
                        createRoomState.status == RoomActionStatus.loading
                    ? null
                    : _createRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCreating || createRoomState.status == RoomActionStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('ルームを作成する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ルールの項目ウィジェット
class _RuleItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final Color color;

  const _RuleItem({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

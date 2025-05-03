import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/controllers/room_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ルーム参加画面
class JoinRoomPage extends ConsumerStatefulWidget {
  const JoinRoomPage({super.key});

  @override
  ConsumerState<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends ConsumerState<JoinRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    // コントローラーの状態をリセット
    ref.read(joinRoomControllerProvider.notifier).reset();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  /// ルームに参加
  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(authUserProvider);
    if (user == null) {
      _showErrorSnackBar('ユーザー情報の取得に失敗しました');
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      await ref.read(joinRoomControllerProvider.notifier).joinRoom(
            _roomIdController.text.trim(),
            user.id,
          );
    } catch (e) {
      _showErrorSnackBar('ルーム参加に失敗しました: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
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
    
    // ルーム参加状態を監視
    final joinRoomState = ref.watch(joinRoomControllerProvider);
    
    // 成功したらルーム詳細画面に遷移
    if (joinRoomState.status == RoomActionStatus.success && joinRoomState.room != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/rooms/${joinRoomState.room!.id}');
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルームに参加'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // エラーメッセージ
              if (joinRoomState.status == RoomActionStatus.error)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    joinRoomState.errorMessage ?? 'エラーが発生しました',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // 参加方法の説明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ルーム参加について',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ホストから共有されたルームIDを入力して、ゲームに参加しましょう！',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // IDフォーム
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ルームID',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _roomIdController,
                      decoration: InputDecoration(
                        hintText: '例: abc123-xyz789',
                        prefixIcon: const Icon(Icons.meeting_room_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste),
                          onPressed: () async {
                            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                            if (clipboardData?.text != null) {
                              _roomIdController.text = clipboardData!.text!.trim();
                            }
                          },
                          tooltip: 'クリップボードから貼り付け',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ルームIDを入力してください';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 参加方法の注意事項
              Card(
                elevation: 0,
                color: Colors.grey.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _JoinInfoItem(
                        icon: Icons.people_alt_outlined,
                        title: '参加人数',
                        description: 'ルームの最大参加人数は6人です。すでに満員の場合は参加できません。',
                      ),
                      const SizedBox(height: 12),
                      _JoinInfoItem(
                        icon: Icons.timer_outlined,
                        title: 'ゲーム開始前',
                        description: 'すでにゲームが開始されているルームには参加できません。',
                      ),
                      const SizedBox(height: 12),
                      _JoinInfoItem(
                        icon: Icons.signal_wifi_statusbar_connected,
                        title: 'インターネット接続',
                        description: '安定したインターネット接続が必要です。ゲーム中は接続を維持してください。',
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // ルーム参加ボタン
              ElevatedButton(
                onPressed: _isJoining ||
                        joinRoomState.status == RoomActionStatus.loading
                    ? null
                    : _joinRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isJoining || joinRoomState.status == RoomActionStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('ルームに参加する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 参加情報項目ウィジェット
class _JoinInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _JoinInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

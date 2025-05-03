import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/controllers/room_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ルーム詳細画面
class RoomDetailPage extends ConsumerStatefulWidget {
  final String roomId;

  const RoomDetailPage({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends ConsumerState<RoomDetailPage> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCopied = false;
  bool _isLeaving = false;
  bool _isStartingGame = false;

  @override
  void initState() {
    super.initState();
    // ルーム情報を取得
    _fetchRoomData();
  }

  /// ルーム情報を取得
  Future<void> _fetchRoomData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getRoomController = ref.read(getRoomControllerProvider.notifier);
      await getRoomController.getRoom(widget.roomId);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ルームIDをクリップボードにコピー
  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.roomId)).then((_) {
      setState(() {
        _isCopied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ルームIDをクリップボードにコピーしました'),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
        }
      });
    });
  }

  /// ルームから退出
  Future<void> _leaveRoom() async {
    final user = ref.read(authUserProvider);
    if (user == null) {
      _showErrorSnackBar('ユーザー情報の取得に失敗しました');
      return;
    }

    setState(() {
      _isLeaving = true;
    });

    try {
      final leaveRoomUseCase = ref.read(leaveRoomUseCaseProvider);
      await leaveRoomUseCase(roomId: widget.roomId, playerId: user.id);
      
      if (!mounted) return;
      
      // ホーム画面に戻る
      context.go('/home');
    } catch (e) {
      _showErrorSnackBar('ルームから退出できませんでした: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLeaving = false;
        });
      }
    }
  }

  /// ゲーム開始
  Future<void> _startGame() async {
    final user = ref.read(authUserProvider);
    if (user == null) {
      _showErrorSnackBar('ユーザー情報の取得に失敗しました');
      return;
    }

    // ルームの情報を確認
    final roomState = ref.read(getRoomControllerProvider);
    if (roomState.room == null) {
      _showErrorSnackBar('ルーム情報の取得に失敗しました');
      return;
    }

    // ルームのホストかどうか確認
    if (roomState.room!.hostId != user.id) {
      _showErrorSnackBar('ゲームを開始できるのはホストのみです');
      return;
    }

    // プレイヤー数が十分かどうか確認
    if (roomState.room!.playerIds.length < 3) {
      _showErrorSnackBar('ゲームを開始するには最低3人のプレイヤーが必要です');
      return;
    }

    setState(() {
      _isStartingGame = true;
    });

    try {
      // ゲーム状態を更新
      final updateRoomStateUseCase = ref.read(updateRoomStateUseCaseProvider);
      await updateRoomStateUseCase(
        roomId: widget.roomId,
        newState: GameState.selecting,
      );
      
      if (!mounted) return;
      
      // ゲーム画面に遷移
      context.go('/game/${widget.roomId}');
    } catch (e) {
      _showErrorSnackBar('ゲームを開始できませんでした: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isStartingGame = false;
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
    final user = ref.watch(authUserProvider);
    
    // ルーム情報取得状態を監視
    final roomState = ref.watch(getRoomControllerProvider);
    final room = roomState.room;

    // ゲーム進行中の場合はゲーム画面に遷移
    if (room != null && room.gameState != GameState.waiting && room.gameState != GameState.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/game/${widget.roomId}');
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム詳細'),
        actions: [
          // ルームから退出するボタン
          IconButton(
            onPressed: _isLeaving ? null : () {
              // ホストの場合は退出できない（ルームを削除する必要がある）
              if (room != null && user != null && room.hostId == user.id) {
                _showErrorSnackBar('ホストはルームから退出できません。ゲーム終了後にルームを削除してください。');
                return;
              }
              
              // 退出確認ダイアログ
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ルームから退出'),
                  content: const Text('このルームから退出しますか？'),
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
                        _leaveRoom();
                      },
                      child: const Text('退出する'),
                    ),
                  ],
                ),
              );
            },
            icon: _isLeaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.exit_to_app),
            tooltip: 'ルームから退出',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'エラーが発生しました',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchRoomData,
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : room == null
                  ? const Center(child: Text('ルーム情報が見つかりません'))
                  : SafeArea(
                      child: Column(
                        children: [
                          // ルーム情報ヘッダー
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.meeting_room,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'ルームID: ${room.id}',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _copyRoomId,
                                      icon: Icon(
                                        _isCopied ? Icons.check : Icons.copy,
                                        color: _isCopied
                                            ? Colors.green
                                            : colorScheme.primary,
                                      ),
                                      tooltip: 'IDをコピー',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ホスト: ${user != null && room.hostId == user.id ? 'あなた' : 'ほかのプレイヤー'}',
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '参加人数: ${room.playerIds.length}人 (必要: 3〜6人)',
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '状態: ${room.gameState == GameState.waiting ? '待機中' : 'ゲーム進行中'}',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          
                          // ホストの場合はゲーム開始ボタンを表示
                          if (user != null && room.hostId == user.id && room.gameState == GameState.waiting)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: _isStartingGame || room.playerIds.length < 3
                                    ? null
                                    : _startGame,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isStartingGame
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(),
                                      )
                                    : const Text('ゲームを開始'),
                              ),
                            ),
                          
                          // 参加者一覧
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  '参加者一覧',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${room.playerIds.length}/6',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 参加者リスト（仮の表示、実際にはユーザー情報を取得して表示する）
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: room.playerIds.length,
                              itemBuilder: (context, index) {
                                final playerId = room.playerIds[index];
                                final isHost = playerId == room.hostId;
                                final isCurrentUser = user != null && playerId == user.id;
                                
                                return Card(
                                  elevation: 0,
                                  color: isCurrentUser
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? colorScheme.primary
                                              : null,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      isCurrentUser ? 'あなた' : 'プレイヤー${index + 1}',
                                      style: TextStyle(
                                        fontWeight: isCurrentUser
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      playerId.substring(0, 8),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: isHost
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'ホスト',
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // 友達を招待するセクション
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '友達を招待',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ルームIDを共有して友達を招待しましょう！',
                                  style: textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _copyRoomId,
                                  icon: Icon(
                                    _isCopied ? Icons.check : Icons.share,
                                  ),
                                  label: Text(_isCopied ? 'コピーしました' : 'ルームIDをコピー'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

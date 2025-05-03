import 'package:emorank_app/domain/entities/room.dart';
import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/controllers/room_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ルーム一覧画面
class RoomListPage extends ConsumerWidget {
  const RoomListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authUserProvider);
    
    // アクティブなルーム一覧を取得
    final activeRoomsAsync = ref.watch(activeRoomsProvider);
    
    // 自分が参加しているルーム一覧を取得
    final userRoomsAsync = user != null
        ? ref.watch(userRoomsProvider(user.id))
        : const AsyncValue<List<Room>>.loading();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム一覧'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeRoomsProvider);
          if (user != null) {
            ref.invalidate(userRoomsProvider(user.id));
          }
        },
        child: CustomScrollView(
          slivers: [
            // 参加中のルーム
            if (user != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    '参加中のルーム',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              userRoomsAsync.when(
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: _EmptyRoomList(
                          message: '参加中のルームはありません',
                          buttonText: 'ルームを作成',
                          onButtonPressed: () => context.push('/rooms/create'),
                        ),
                      ),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final room = rooms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RoomCard(
                              room: room,
                              onTap: () => context.push('/rooms/${room.id}'),
                              isJoined: true,
                            ),
                          );
                        },
                        childCount: rooms.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stackTrace) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'エラーが発生しました: $error',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            
            // アクティブなルーム
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'アクティブなルーム',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            activeRoomsAsync.when(
              data: (rooms) {
                if (rooms.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _EmptyRoomList(
                        message: '現在アクティブなルームはありません',
                        buttonText: '自分でルームを作成',
                        onButtonPressed: () => context.push('/rooms/create'),
                      ),
                    ),
                  );
                }
                
                // 自分が参加中の部屋のIDリスト
                final joinedRoomIds = userRoomsAsync.maybeWhen(
                  data: (userRooms) => userRooms.map((r) => r.id).toSet(),
                  orElse: () => <String>{},
                );
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final room = rooms[index];
                        final isJoined = joinedRoomIds.contains(room.id);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RoomCard(
                            room: room,
                            onTap: () {
                              if (isJoined) {
                                context.push('/rooms/${room.id}');
                              } else {
                                // 参加確認ダイアログを表示
                                showDialog(
                                  context: context,
                                  builder: (context) => _JoinRoomDialog(
                                    room: room,
                                  ),
                                );
                              }
                            },
                            isJoined: isJoined,
                          ),
                        );
                      },
                      childCount: rooms.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'エラーが発生しました: $error',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/rooms/create'),
        tooltip: 'ルームを作成',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ルームカードウィジェット
class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final bool isJoined;

  const _RoomCard({
    required this.room,
    required this.onTap,
    this.isJoined = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ルームID（短縮表示）
                  Text(
                    'ルーム: ${room.id.substring(0, 8)}...',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // 参加状態表示
                  if (isJoined)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '参加中',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // プレイヤー情報
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.playerIds.length}人参加中',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '作成: ${_formatDate(room.createdAt)}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // ステータス
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: room.gameState == GameState.waiting
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      room.gameState == GameState.waiting
                          ? '待機中'
                          : 'ゲーム進行中',
                      style: textTheme.bodySmall?.copyWith(
                        color: room.gameState == GameState.waiting
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  isJoined
                      ? Text(
                          '続ける',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        )
                      : Text(
                          '参加する',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 日付のフォーマット
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '数秒前';
    }
  }
}

/// 空のルームリスト表示ウィジェット
class _EmptyRoomList extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const _EmptyRoomList({
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onButtonPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

/// ルーム参加確認ダイアログ
class _JoinRoomDialog extends ConsumerStatefulWidget {
  final Room room;

  const _JoinRoomDialog({
    required this.room,
  });

  @override
  ConsumerState<_JoinRoomDialog> createState() => _JoinRoomDialogState();
}

class _JoinRoomDialogState extends ConsumerState<_JoinRoomDialog> {
  bool _isJoining = false;

  /// ルームに参加
  Future<void> _joinRoom() async {
    final user = ref.read(authUserProvider);
    if (user == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      await ref.read(joinRoomControllerProvider.notifier).joinRoom(
            widget.room.id,
            user.id,
          );
      
      if (!mounted) return;
      
      final joinRoomState = ref.read(joinRoomControllerProvider);
      if (joinRoomState.status == RoomActionStatus.success && joinRoomState.room != null) {
        Navigator.of(context).pop();
        context.push('/rooms/${joinRoomState.room!.id}');
      } else if (joinRoomState.status == RoomActionStatus.error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(joinRoomState.errorMessage ?? 'ルームへの参加に失敗しました'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ルームへの参加に失敗しました: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return AlertDialog(
      title: const Text('ルームに参加しますか？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ルームID: ${widget.room.id}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '参加人数: ${widget.room.playerIds.length}人',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'このルームに参加して、エモランゲームを楽しみましょう！',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isJoining
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _isJoining ? null : _joinRoom,
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('参加する'),
        ),
      ],
    );
  }
}

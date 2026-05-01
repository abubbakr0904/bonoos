import 'package:bonoos/core/values/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../models/chat_message.dart';
import '../repository/chat_repository.dart';
import '../services/chat_seed_loader_service.dart';
import '../services/chat_websocket_service.dart';
import 'message_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String routeName = '/chat-screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const int _currentUserId = 1;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent + 90;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _scrollController.jumpTo(target);
  }

  List<_TimelineEntry> _buildTimelineEntries(List<ChatMessage> messages) {
    final entries = <_TimelineEntry>[];
    DateTime? previousDate;
    for (final message in messages) {
      final local = message.sentAt.toLocal();
      final currentDate = DateTime(local.year, local.month, local.day);
      if (previousDate == null || previousDate != currentDate) {
        entries.add(_TimelineEntry.date(currentDate));
        previousDate = currentDate;
      }
      entries.add(_TimelineEntry.message(message));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(
        repository: ChatRepository(
          seedLoaderService: ChatSeedLoaderService(),
          websocketService: ChatWebSocketService(),
        ),
      )..initialize(),
      child: BlocConsumer<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.messages.length != current.messages.length ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.c30215A,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              titleSpacing: 0,
              title: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.c842D5F, Color(0xFF6D45EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(CupertinoIcons.headphones,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Qo\'llab-quvvatlash',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: state.isSocketConnected
                                  ? const Color(0xFF84F4A4)
                                  : Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.isSocketConnected ? 'Online' : 'Ulanmoqda...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.76),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.c30215A, AppColors.c55004D],
                ),
              ),
              child: Column(
                children: [
                  Expanded(child: _buildBody(state)),
                  MessageInput(
                    controller: _messageController,
                    isSending: state.isSending,
                    onSend: () {
                      final text = _messageController.text.trim();
                      if (text.isEmpty) return;
                      context.read<ChatCubit>().sendMessage(
                            content: text,
                            currentUserId: _currentUserId,
                          );
                      _messageController.clear();
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ChatState state) {
    switch (state.status) {
      case ChatStatus.loading:
      case ChatStatus.initial:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF9D4DFF)),
        );
      case ChatStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage ?? 'Noma\'lum xatolik',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      case ChatStatus.loaded:
        if (state.messages.isEmpty) {
          return const Center(
            child: Text(
              'Hozircha xabarlar yo\'q.\nYangi suhbatni boshlang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        final entries = _buildTimelineEntries(state.messages);
        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = entries[index];
            if (entry.date != null) {
              return _DateChip(date: entry.date!);
            }
            final message = entry.message!;
            final isMine = message.senderId == _currentUserId;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: _MessageBubble(message: message, isMine: isMine),
            );
          },
        );
    }
  }
}

class _TimelineEntry {
  const _TimelineEntry._({this.message, this.date});

  factory _TimelineEntry.message(ChatMessage message) =>
      _TimelineEntry._(message: message);
  factory _TimelineEntry.date(DateTime date) => _TimelineEntry._(date: date);

  final ChatMessage? message;
  final DateTime? date;
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          DateFormat('dd MMM, EEE').format(date),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bgGradient = isMine
        ? const LinearGradient(
            colors: [AppColors.c842D5F, Color(0xFF6E58FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.08),
            ],
          );
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMine ? 18 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 18),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 295),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: isMine
                    ? const Color(0x40842D5F)
                    : Colors.black.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: isMine ? 0.06 : 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.sentAt.toLocal()),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 6),
                      Icon(
                        message.isLocalPending
                            ? CupertinoIcons.clock
                            : CupertinoIcons.check_mark_circled_solid,
                        color: Colors.white.withValues(alpha: 0.84),
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

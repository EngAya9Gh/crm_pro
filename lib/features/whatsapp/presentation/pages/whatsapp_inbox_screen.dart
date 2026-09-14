import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/di/di_container.dart';
import '../../domain/entities/whatsapp_thread.dart';
import '../bloc/whatsapp_threads_cubit.dart';
import '../bloc/whatsapp_threads_state.dart';
import 'whatsapp_chat_screen.dart';
import 'package:intl/intl.dart';

class WhatsappInboxScreen extends StatelessWidget {
  const WhatsappInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WhatsappThreadsCubit>()..loadThreads(),
      child: const _WhatsappInboxView(),
    );
  }
}

class _WhatsappInboxView extends StatefulWidget {
  const _WhatsappInboxView();

  @override
  State<_WhatsappInboxView> createState() => _WhatsappInboxViewState();
}

class _WhatsappInboxViewState extends State<_WhatsappInboxView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WhatsappThreadsCubit>().loadThreads();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.titleMedium('محادثات الواتس آب', color: Colors.white),
        backgroundColor: const Color(0xFF128C7E), // WhatsApp Green
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<WhatsappThreadsCubit, WhatsappThreadsState>(
        builder: (context, state) {
          if (state is WhatsappThreadsLoading &&
              state is! WhatsappThreadsLoaded) {
            return const Center(child: AppLoader());
          } else if (state is WhatsappThreadsError) {
            return Center(
              child: AppText.bodyMedium(state.message, color: Colors.red),
            );
          } else if (state is WhatsappThreadsLoaded) {
            final threads = state.threads;
            if (threads.isEmpty) {
              return const Center(child: AppText('لا توجد محادثات حالياً'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<WhatsappThreadsCubit>().loadThreads(
                  refresh: true,
                );
              },
              child: ListView.separated(
                controller: _scrollController,
                itemCount: threads.length + (state.hasReachedMax ? 0 : 1),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index >= threads.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: AppLoader()),
                    );
                  }
                  final thread = threads[index];
                  return _ThreadTile(thread: thread);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final WhatsappThread thread;

  const _ThreadTile({required this.thread});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat('hh:mm a').format(date);
    }
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColorScheme.primary.withOpacity(0.1),
        child: const Icon(Icons.person, color: AppColorScheme.primary),
      ),
      title: AppText.bodyMedium(
        thread.clientName ?? thread.clientPhone ?? 'عميل مجهول',
        fontWeight: FontWeight.bold,
      ),
      subtitle: AppText.bodySmall(
        thread.lastMessage?.content ??
            (thread.lastMessage?.mediaUrl != null
                ? '📷 صورة/مرفق'
                : 'لا توجد رسائل'),
        maxLines: 1,
        color: AppColorScheme.textMuted,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppText.labelMedium(
            _formatDate(thread.updatedAt),
            color: thread.unreadCount > 0
                ? const Color(0xFF25D366)
                : AppColorScheme.textMuted,
          ),
          if (thread.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: AppText.labelSmall(
                '${thread.unreadCount}',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WhatsappChatScreen(thread: thread)),
        );
      },
    );
  }
}

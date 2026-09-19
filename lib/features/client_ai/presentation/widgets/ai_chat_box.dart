import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../cubit/client_ai_cubit.dart';
import '../cubit/client_ai_state.dart';
import 'ai_chat_bubble.dart';

class AiChatBox extends StatefulWidget {
  final String clientId;
  const AiChatBox({super.key, required this.clientId});

  @override
  State<AiChatBox> createState() => _AiChatBoxState();
}

class _AiChatBoxState extends State<AiChatBox> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ClientAiCubit>().askQuestion(widget.clientId, text, type: 'free_chat');
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientAiCubit, ClientAiState>(
      listener: (context, state) {
        if (state is ClientAiLoaded) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ClientAiCubit>();
        final messages = cubit.currentMessages.where((m) {
          final content = m.content.trim();
          return !content.startsWith('هذه بيانات العميل التي سأسألك عنها') && m.role != 'system';
        }).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              // Chat Messages
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 40, color: AppColorScheme.textMuted.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            AppText(
                              'لا توجد رسائل بعد.\nابدأ المحادثة الآن!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColorScheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length + (cubit.isAsking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && cubit.isAsking) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          return AiChatBubble(message: messages[index]);
                        },
                      ),
              ),
              
              // Input Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _controller,
                        hintText: 'اسأل مساعد العميل أي شيء...',
                        onFieldSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: cubit.isAsking ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

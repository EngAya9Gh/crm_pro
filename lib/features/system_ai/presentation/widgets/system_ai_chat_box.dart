import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/features/client_ai/presentation/widgets/ai_chat_bubble.dart';
import '../cubit/system_ai_cubit.dart';
import '../cubit/system_ai_state.dart';

class SystemAiChatBox extends StatefulWidget {
  final Widget? header;
  const SystemAiChatBox({super.key, this.header});

  @override
  State<SystemAiChatBox> createState() => _SystemAiChatBoxState();
}

class _SystemAiChatBoxState extends State<SystemAiChatBox> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<SystemAiCubit>().askQuestion(text, type: 'free_chat');
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
    return BlocConsumer<SystemAiCubit, SystemAiState>(
      listener: (context, state) {
        if (state is SystemAiLoaded) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SystemAiCubit>();
        final messages = cubit.currentMessages.where((m) => m.role != 'system').toList();

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
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: (widget.header != null ? 1 : 0) + 
                             (messages.isEmpty && widget.header == null ? 1 : messages.length) + 
                             (cubit.isAsking ? 1 : 0),
                  itemBuilder: (context, index) {
                    int messageIndex = index;
                    
                    if (widget.header != null) {
                      if (index == 0) return widget.header!;
                      messageIndex = index - 1;
                    }

                    if (messages.isEmpty && messageIndex == 0) {
                       return Padding(
                         padding: const EdgeInsets.only(top: 40),
                         child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 40, color: AppColorScheme.textMuted.withOpacity(0.5)),
                              const SizedBox(height: 8),
                              const AppText(
                                'لا توجد رسائل بعد.\nابدأ المحادثة الآن!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColorScheme.textMuted),
                              ),
                            ],
                          ),
                         ),
                       );
                    }

                    if (messageIndex == (messages.isEmpty ? 1 : messages.length) && cubit.isAsking) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (messages.isNotEmpty) {
                       return AiChatBubble(message: messages[messageIndex]);
                    }
                    return const SizedBox.shrink();
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
                        hintText: 'اسأل الوكيل العام أي شيء...',
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/di/di_container.dart';
import '../../domain/entities/whatsapp_thread.dart';
import '../../domain/entities/whatsapp_message.dart';
import '../bloc/whatsapp_chat_cubit.dart';
import '../bloc/whatsapp_chat_state.dart';

class WhatsappChatScreen extends StatelessWidget {
  final WhatsappThread thread;

  const WhatsappChatScreen({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WhatsappChatCubit>()..loadMessages(thread.id.toString()),
      child: _WhatsappChatView(thread: thread),
    );
  }
}

class _WhatsappChatView extends StatefulWidget {
  final WhatsappThread thread;

  const _WhatsappChatView({required this.thread});

  @override
  State<_WhatsappChatView> createState() => _WhatsappChatViewState();
}

class _WhatsappChatViewState extends State<_WhatsappChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WhatsappChatCubit>().loadMessages(widget.thread.id.toString());
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<WhatsappChatCubit>().reply(
      type: 'text',
      content: text,
    );
    _messageController.clear();
    setState(() => _showEmojiPicker = false);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // In a real app, you would upload the file to your server first
      // and get the media_url, then send the reply.
      // For now, we simulate sending a document/media type.
      final fileName = result.files.single.name;
      context.read<WhatsappChatCubit>().reply(
        type: 'document',
        mediaUrl: 'uploading/$fileName', // placeholder
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp chat background
      appBar: AppBar(
        backgroundColor: const Color(0xFF128C7E),
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleMedium(
                    widget.thread.clientName ?? widget.thread.clientPhone ?? 'عميل',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  AppText.bodySmall(
                    'متصل بالواتس آب', // Example status
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<WhatsappChatCubit, WhatsappChatState>(
              builder: (context, state) {
                if (state is WhatsappChatLoading && state is! WhatsappChatLoaded) {
                  return const Center(child: AppLoader());
                } else if (state is WhatsappChatError) {
                  return Center(child: AppText.bodyMedium(state.message, color: Colors.red));
                } else if (state is WhatsappChatLoaded) {
                  final messages = state.messages;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // show latest at the bottom
                    itemCount: messages.length + (state.hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index >= messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: AppLoader()),
                        );
                      }
                      final message = messages[index];
                      return _ChatBubble(message: message);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputArea(),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _messageController.text += emoji.emoji;
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      onTap: () {
                        if (_showEmojiPicker) {
                          setState(() => _showEmojiPicker = false);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: _pickFile,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF128C7E),
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final WhatsappMessage message;

  const _ChatBubble({required this.message});

  Widget _buildMedia(BuildContext context, WhatsappMessage message) {
    if (message.mediaUrl == null) return const SizedBox.shrink();
    
    final fullUrl = message.mediaUrl!.startsWith('http') 
        ? message.mediaUrl! 
        : 'https://app.wakeel.cc${message.mediaUrl}';

    if (message.type.toUpperCase() == 'IMAGE') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            fullUrl,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      );
    } else if (message.type.toUpperCase() == 'AUDIO') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, color: Colors.grey),
            const SizedBox(width: 8),
            AppText.bodyMedium('رسالة صوتية', color: Colors.blue),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: AppText.bodyMedium(
                message.mediaUrl?.split('/').last ?? 'ملف مرفق',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == 'image' && message.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.mediaUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
            _buildMedia(context, message),
            if (message.content != null && message.content!.isNotEmpty)
              AppText.bodyMedium(
                message.content!,
                color: Colors.black87,
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText.labelSmall(
                  DateFormat('hh:mm a').format(message.createdAt),
                  color: Colors.grey[600],
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'read'
                        ? Icons.done_all
                        : message.status == 'delivered'
                            ? Icons.done_all
                            : Icons.done,
                    size: 14,
                    color: message.status == 'read' ? Colors.blue : Colors.grey[600],
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

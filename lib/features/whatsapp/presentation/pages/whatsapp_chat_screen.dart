import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/di/di_container.dart';
import '../../domain/entities/whatsapp_thread.dart';
import '../../domain/entities/whatsapp_message.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../bloc/whatsapp_chat_cubit.dart';
import '../bloc/whatsapp_chat_state.dart';
import 'dart:typed_data';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/download/download_service.dart';
import '../../../../core/utils/end_points.dart';
// Import removed for mobile compatibility
import 'package:audioplayers/audioplayers.dart';

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
  bool _isTyping = false;

  // Recording State
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  String? _recordPath;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(() {
      final isTyping = _messageController.text.trim().isNotEmpty;
      if (_isTyping != isTyping) {
        setState(() => _isTyping = isTyping);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
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
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      String mediaType = 'document';
      final ext = file.extension?.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext)) mediaType = 'image';
      else if (['mp4', 'mov'].contains(ext)) mediaType = 'video';
      else if (['mp3', 'wav', 'ogg', 'm4a'].contains(ext)) mediaType = 'audio';

      if (mounted) {
        context.read<WhatsappChatCubit>().sendMedia(
          thread: widget.thread,
          mediaType: mediaType,
          fileBytes: file.bytes!,
          fileName: file.name,
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          _recordPath = '';
          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: _recordPath!);
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          _recordPath = '${dir.path}/$fileName';
          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: _recordPath!);
        }
        
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });
        
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() => _recordDuration++);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرجاء منح صلاحية الميكروفون')),
          );
        }
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    }
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    _recordTimer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordDuration = 0;
    });

    if (cancel || path == null) {
      if (path != null && !kIsWeb) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      return;
    }

    try {
      List<int> bytes;
      if (kIsWeb) {
        final response = await Dio().get<List<int>>(
          path,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = response.data!;
      } else {
        bytes = await File(path).readAsBytes();
      }

      if (mounted) {
        context.read<WhatsappChatCubit>().sendMedia(
          thread: widget.thread,
          mediaType: 'audio',
          fileBytes: bytes,
          fileName: kIsWeb ? 'voice_message.m4a' : path.split('/').last,
        );
      }
    } catch (e) {
      debugPrint("Error sending audio: $e");
    }
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
              child: _isRecording
                  ? Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _stopRecording(cancel: true),
                        ),
                        Expanded(
                          child: AppText.bodyMedium(
                            _formatDuration(_recordDuration),
                            color: Colors.red,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(Icons.mic, color: Colors.red),
                        ),
                      ],
                    )
                  : Row(
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
              icon: Icon(
                _isRecording 
                  ? Icons.stop 
                  : (_isTyping ? Icons.send : Icons.mic), 
                color: Colors.white
              ),
              onPressed: () {
                if (_isRecording) {
                  _stopRecording();
                } else if (_isTyping) {
                  _sendMessage();
                } else {
                  _startRecording();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final String proxyUrl;
  final String fileName;
  const _DownloadButton({required this.proxyUrl, required this.fileName});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _downloading = false;

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final bytes = await getIt<ApiClient>().getBytes(widget.proxyUrl);
      DownloadService.download(bytes: bytes, fileName: widget.fileName);
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _download,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _downloading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.download, color: Colors.white, size: 18),
      ),
    );
  }
}

class _AudioPlayer extends StatefulWidget {
  final String proxyUrl;
  const _AudioPlayer({required this.proxyUrl});

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  bool _isLoading = false;
  bool _hasError = false;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() { _isLoading = true; _hasError = false; });
      try {
        await _audioPlayer.play(UrlSource(widget.proxyUrl));
      } catch (e) {
        if (mounted) setState(() => _hasError = true);
        debugPrint("Audio playback error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : _togglePlay,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isPlaying ? const Color(0xFFE8F5E9) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isPlaying ? const Color(0xFF128C7E) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Icon(
                _hasError
                    ? Icons.error_outline
                    : _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                color: _hasError ? Colors.red : const Color(0xFF128C7E),
                size: 32,
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyMedium(
                  _hasError ? 'خطأ في التحميل' : 'رسالة صوتية',
                  color: _hasError ? Colors.red : Colors.grey[800]!,
                ),
                if (!_hasError)
                  AppText.bodySmall(
                    _isLoading ? 'جاري التحميل...' : _isPlaying ? 'يُشغَّل الآن' : 'اضغط للتشغيل',
                    color: Colors.grey[600]!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _MediaNetworkImage extends StatefulWidget {
  final String url;
  const _MediaNetworkImage({required this.url});

  @override
  State<_MediaNetworkImage> createState() => _MediaNetworkImageState();
}

class _MediaNetworkImageState extends State<_MediaNetworkImage> {
  Uint8List? _bytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await getIt<ApiClient>().getBytes(widget.url);
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: AppLoader()),
      );
    }
    if (_hasError || _bytes == null) {
      return const SizedBox(
        height: 150,
        child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
    return Image.memory(
      _bytes!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final WhatsappMessage message;

  const _ChatBubble({required this.message});

  Widget _buildMedia(BuildContext context, WhatsappMessage message) {
    if (message.status == 'UPLOADING') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            AppText.bodyMedium('جاري الرفع...', color: Colors.blue),
          ],
        ),
      );
    }

    if (message.mediaUrl == null) return const SizedBox.shrink();

    // Build the full provider URL from relative mediaUrl
    // e.g. /api/v1/chat/media/980981874953901?channelId=... -> https://provider.wakeel.cc/api/v1/chat/media/...
    String getProviderUrl() {
      final url = message.mediaUrl!;
      if (url.startsWith('http')) return url;
      // Strip leading slash, prepend provider host
      final path = url.startsWith('/') ? url : '/$url';
      return 'https://provider.wakeel.cc$path';
    }

    final providerUrl = getProviderUrl();
    // Proxy through our CRM backend (which adds the provider auth token server-side)
    final proxyUrl = '${EndPoints.baseUrl}${EndPoints.whatsappMedia}?url=${Uri.encodeComponent(providerUrl)}';

    Widget mediaWidget;

    final typeLC = message.type.toLowerCase();
    final isImage = typeLC == 'image' ||
        (message.mediaUrl?.toLowerCase().contains('image') ?? false) ||
        (message.mediaUrl?.endsWith('.jpg') ?? false) ||
        (message.mediaUrl?.endsWith('.jpeg') ?? false) ||
        (message.mediaUrl?.endsWith('.png') ?? false) ||
        (message.mediaUrl?.endsWith('.gif') ?? false) ||
        (message.mediaUrl?.endsWith('.webp') ?? false);
    final isAudio = typeLC == 'audio' ||
        (message.mediaUrl?.endsWith('.ogg') ?? false) ||
        (message.mediaUrl?.endsWith('.mp3') ?? false) ||
        (message.mediaUrl?.endsWith('.m4a') ?? false);

    if (isImage) {
      mediaWidget = Container(
        constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _MediaNetworkImage(url: proxyUrl),
            ),
            // Download button overlay
            Positioned(
              bottom: 4,
              right: 4,
              child: _DownloadButton(proxyUrl: proxyUrl, fileName: 'image.jpg'),
            ),
          ],
        ),
      );
    } else if (isAudio) {
      mediaWidget = _AudioPlayer(proxyUrl: proxyUrl);
    } else {
      mediaWidget = Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: AppText.bodyMedium(
                message.mediaUrl?.split('/').last.split('?').first ?? 'ملف مرفق (اضغط للفتح)',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }

    return mediaWidget;
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
                    (message.status == 'PENDING' || message.status == 'UPLOADING')
                        ? Icons.access_time
                        : message.status == 'read' || message.status == 'READ'
                            ? Icons.done_all
                            : message.status == 'delivered' || message.status == 'DELIVERED'
                                ? Icons.done_all
                                : Icons.done,
                    size: 14,
                    color: (message.status == 'read' || message.status == 'READ') ? Colors.blue : Colors.grey[600],
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

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/di/di_container.dart';
import 'package:intl/intl.dart';

class TicketWhatsappChatTab extends StatefulWidget {
  final int ticketId;

  const TicketWhatsappChatTab({super.key, required this.ticketId});

  @override
  State<TicketWhatsappChatTab> createState() => _TicketWhatsappChatTabState();
}

class _TicketWhatsappChatTabState extends State<TicketWhatsappChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.dio.get(
        '/tickets/${widget.ticketId}/provider-messages',
      );
      if (response.data['success'] == true) {
        setState(() {
          _messages = response.data['data'] ?? [];
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error fetching WhatsApp messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.dio.post(
        '/tickets/${widget.ticketId}/provider-messages',
        data: {'content': text},
      );
      if (response.data['success'] == true) {
        _messageController.clear();
        await _fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('فشل الإرسال. تأكد من اتصالك.')),
        );
      }
    } catch (e) {
      debugPrint('Error sending WhatsApp message: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText('حدث خطأ أثناء الإرسال: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0.0, // Because ListView is reversed
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading && _messages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
              ? const Center(child: AppText('لا توجد رسائل واتساب سابقة'))
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages.reversed.toList()[index];
                    final isOutbound =
                        msg['type'] == 'outbound' || msg['is_outbound'] == true;
                    final content = msg['content']?.toString() ?? '';
                    final dateStr = msg['created_at']?.toString() ?? '';
                    DateTime? date = DateTime.tryParse(dateStr);

                    return Align(
                      alignment: isOutbound
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isOutbound
                              ? const Color(0xFFE8F5E9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12).copyWith(
                            topLeft: isOutbound
                                ? const Radius.circular(0)
                                : const Radius.circular(12),
                            topRight: isOutbound
                                ? const Radius.circular(12)
                                : const Radius.circular(0),
                          ),
                          border: Border.all(
                            color: isOutbound
                                ? const Color(0xFFC8E6C9)
                                : AppColorScheme.grey200,
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              content,
                              style: TextStyle(
                                color: isOutbound
                                    ? Colors.black87
                                    : AppColorScheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            if (date != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: AppText(
                                  DateFormat('hh:mm a').format(date.toLocal()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isOutbound
                                        ? Colors.black54
                                        : AppColorScheme.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(
            16,
          ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _messageController,
                  hintText: 'اكتب رداً للعميل عبر الواتساب...',
                  maxLines: 4,
                  onFieldSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _isSending ? null : _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366), // WhatsApp color
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

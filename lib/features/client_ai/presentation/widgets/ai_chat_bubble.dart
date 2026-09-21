import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/entities/ai_message.dart';

class AiChatBubble extends StatelessWidget {
  final AiMessage message;

  const AiChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? AppColorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  const Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: AppText(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColorScheme.textMain,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (!isUser) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: AppText('تم نسخ الرسالة', style: TextStyle(color: Colors.white)),
                          backgroundColor: AppColorScheme.primary,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message.content)}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        final webUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message.content)}');
                        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(FontAwesomeIcons.whatsapp, size: 16, color: Colors.green[600]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

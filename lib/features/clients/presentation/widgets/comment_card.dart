import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/client_enums.dart';

import 'package:url_launcher/url_launcher.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getOutcomeColor(comment.outcome).withOpacity(0.1),
            child: AppText(
              comment.createdBy[0].toUpperCase(),
              style: TextStyle(
                color: _getOutcomeColor(comment.outcome),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppText(
                          comment.createdBy,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          _formatDate(comment.createdAt),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorScheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    if (comment.outcome != null)
                      _buildOutcomeBadge(comment.outcome!),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        comment.content,
                        style: AppTypography.bodyMedium.copyWith(
                          height: 1.4,
                          color: AppColorScheme.textMain,
                        ),
                      ),
                      if (comment.mentions != null &&
                          comment.mentions!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: comment.mentions!
                              .map(
                                (m) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: AppText(
                                    '@${m.name}',
                                    style: const TextStyle(
                                      color: AppColorScheme.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (comment.nextFollowUp != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_repeat,
                              size: 14,
                              color: AppColorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              'متابعة: ${_formatDate(comment.nextFollowUp!)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (comment.attachments != null &&
                          comment.attachments!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColorScheme.surface),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: comment.attachments!
                                .map(
                                  (file) => GestureDetector(
                                    onTap: () async {
                                      final Uri url = Uri.parse(file.url);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColorScheme.background,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColorScheme.surface,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.attach_file,
                                            size: 12,
                                            color: AppColorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          AppText(
                                            file.name.length > 15
                                                ? '...${file.name.substring(file.name.length - 12)}'
                                                : file.name,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColorScheme.textMain,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeBadge(CommentOutcome outcome) {
    String text;
    Color color = _getOutcomeColor(outcome);

    switch (outcome) {
      case CommentOutcome.positive:
        text = 'إيجابي';
        break;
      case CommentOutcome.neutral:
        text = 'محايد';
        break;
      case CommentOutcome.negative:
        text = 'سلبي';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getOutcomeColor(CommentOutcome? outcome) {
    if (outcome == null) return AppColorScheme.primary;
    switch (outcome) {
      case CommentOutcome.positive:
        return AppColorScheme.success;
      case CommentOutcome.neutral:
        return AppColorScheme.silver;
      case CommentOutcome.negative:
        return AppColorScheme.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute}';
  }
}

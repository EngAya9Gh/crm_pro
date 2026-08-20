import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_enums.dart';
import '../../domain/entities/tag_entity.dart';

class ClientInfoTab extends StatelessWidget {
  final Client client;

  const ClientInfoTab({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معلومات الاتصال', Icons.contact_phone_outlined),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_outlined,
            AppStrings.email,
            client.email ?? 'غير متوفر',
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            AppStrings.phoneNumber,
            client.phone,
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            AppStrings.address,
            '${client.city} - ${client.region}',
          ),
          if (client.address != null)
            _buildInfoRow(
              Icons.location_city_outlined,
              'العنوان بالتفصيل',
              client.address!,
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: AppColorScheme.surface),
          ),

          _buildSectionTitle('تفاصيل الحالة', Icons.dashboard_outlined),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.info_outline,
            AppStrings.clientStatus,
            client.status.name,
          ),
          _buildInfoRow(
            Icons.flag_outlined,
            AppStrings.clientPriority,
            EnumHelpers.getClientPriorityArabic(client.priority),
          ),
          if (client.leadRating != null)
            _buildInfoRow(
              Icons.star_outline,
              'التقييم',
              EnumHelpers.getClientRatingArabic(client.leadRating!),
            ),
          _buildInfoRow(
            Icons.calendar_month_outlined,
            'تاريخ الإضافة',
            '${client.createdAt.day}/${client.createdAt.month}/${client.createdAt.year}',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: AppColorScheme.surface),
          ),

          _buildSectionTitle(
            'المصدر والمعلومات الإضافية',
            Icons.campaign_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            client.sourceStatus == SourceStatus.valid
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            'صحة المصدر',
            client.sourceStatus == SourceStatus.valid ? 'صحيح' : 'خاطئ',
            iconColor: client.sourceStatus == SourceStatus.valid
                ? AppColorScheme.success
                : AppColorScheme.error,
          ),
          if (client.sourceName != null)
            _buildInfoRow(Icons.link_outlined, 'المصدر', client.sourceName!),
          if (client.behaviorName != null)
            _buildInfoRow(
              Icons.psychology_outlined,
              'السلوك',
              client.behaviorName!,
            ),
          if (client.sourceStatus == SourceStatus.invalid &&
              client.invalidReasonName != null)
            _buildInfoRow(
              Icons.warning_amber_rounded,
              'سبب الخطأ',
              client.invalidReasonName!,
              iconColor: AppColorScheme.error,
            ),
          if (client.exclusionReason != null)
            _buildInfoRow(
              Icons.block_outlined,
              'سبب الاستبعاد',
              client.exclusionReason!,
              iconColor: AppColorScheme.error,
            ),
          if (client.assignedTo != null)
            _buildInfoRow(
              Icons.person_outline,
              'الموظف المسؤول',
              client.assignedTo!.name,
            ),
          if (client.tags.isNotEmpty) _buildTagsRow(client.tags),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColorScheme.secondary, size: 20),
        const SizedBox(width: 8),
        AppText(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColorScheme.primary).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? AppColorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColorScheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(List<TagEntity> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sell_outlined,
              size: 18,
              color: AppColorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'الوسوم',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColorScheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _parseColor(tag.color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _parseColor(tag.color)),
                          ),
                          child: AppText(
                            tag.name,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              color: _parseColor(tag.color),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

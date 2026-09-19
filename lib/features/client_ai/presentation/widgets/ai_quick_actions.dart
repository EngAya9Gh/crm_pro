import 'package:flutter/material.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';

class AiQuickActions extends StatelessWidget {
  final Function(String question, String type) onActionSelected;

  AiQuickActions({super.key, required this.onActionSelected});

  final List<Map<String, String>> actions = [
    {
      'title': 'لخص تاريخ العميل',
      'icon': '📝',
      'type': 'quick_action',
    },
    {
      'title': 'اقتراح رسالة متابعة ودية',
      'icon': '💬',
      'type': 'quick_action',
    },
    {
      'title': 'عرض سعر مبدئي',
      'icon': '💰',
      'type': 'quick_action',
    },
    {
      'title': 'أبرز الاعتراضات',
      'icon': '🔍',
      'type': 'quick_action',
    },
    {
      'title': 'تاريخ آخر تواصل',
      'icon': '⏰',
      'type': 'quick_action',
    },
    {
      'title': 'أفضل عرض/خصم للعميل',
      'icon': '🎯',
      'type': 'quick_action',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0, right: 4.0),
          child: AppText(
            'إجراءات سريعة ⚡',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColorScheme.textMain,
            ),
          ),
        ),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final action = actions[index];
              return ActionChip(
                backgroundColor: AppColorScheme.primary.withOpacity(0.1),
                side: BorderSide(color: AppColorScheme.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(action['icon']!),
                    const SizedBox(width: 6),
                    Flexible(
                      child: AppText(
                        action['title']!,
                        style: const TextStyle(
                          color: AppColorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  onActionSelected(action['title']!, action['type']!);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

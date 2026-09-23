import 'package:flutter/material.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crm_wakeel/core/common/entities/ai_suggestion_item.dart';

class AiQuickActions extends StatelessWidget {
  final List<AiSuggestionItem> suggestions;
  final Function(AiSuggestionItem suggestion) onActionSelected;

  const AiQuickActions({
    super.key, 
    required this.suggestions,
    required this.onActionSelected,
  });
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
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ActionChip(
                backgroundColor: AppColorScheme.primary.withOpacity(0.1),
                side: BorderSide(color: AppColorScheme.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (suggestion.icon == 'whatsapp' || suggestion.action == 'summarize_whatsapp')
                      const FaIcon(FontAwesomeIcons.whatsapp, size: 16, color: Color(0xFF25D366))
                    else
                      const Text('✨'),
                    const SizedBox(width: 6),
                    Flexible(
                      child: AppText(
                        suggestion.question,
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
                  onActionSelected(suggestion);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

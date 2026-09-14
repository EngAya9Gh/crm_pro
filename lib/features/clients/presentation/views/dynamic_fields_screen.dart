import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import '../../domain/entities/dynamic_field.dart';

class DynamicFieldsScreen extends StatefulWidget {
  const DynamicFieldsScreen({super.key});

  @override
  State<DynamicFieldsScreen> createState() => _DynamicFieldsScreenState();
}

class _DynamicFieldsScreenState extends State<DynamicFieldsScreen> {
  final List<Map<String, dynamic>> _sections = [
    {'title': 'أنواع التعليقات', 'icon': Icons.comment_outlined},
    {'title': 'مصادر العملاء', 'icon': Icons.campaign_outlined},
    {'title': 'سلوكيات العملاء', 'icon': Icons.psychology_outlined},
    {'title': 'أسباب الاستبعاد', 'icon': Icons.person_off_outlined},
    {'title': 'أسباب التسجيل الخاطئ', 'icon': Icons.report_problem_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.surface,
      appBar: AppBar(
        title: const AppText(
          'إدارة القوائم الديناميكية',
          style: TextStyle(color: AppColorScheme.white),
        ),
        backgroundColor: AppColorScheme.primary,
        iconTheme: const IconThemeData(color: AppColorScheme.white),
        elevation: 0,
      ),
      body: AppListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColorScheme.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColorScheme.surface, width: 2),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  section['icon'],
                  color: AppColorScheme.primary,
                  size: 20,
                ),
              ),
              title: AppText(
                section['title'],
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColorScheme.silver,
              ),
              onTap: () {
                _showSectionManagement(section['title']);
              },
            ),
          );
        },
      ),
    );
  }

  void _showSectionManagement(String title) {
    // Mock Data for the selected section
    final List<DynamicField> fields = [
      DynamicField(id: '1', name: 'خيار 1', order: 1, color: '#FF0000'),
      DynamicField(id: '2', name: 'خيار 2', order: 2, color: '#00FF00'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColorScheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(
                        int.parse(field.color!.replaceFirst('#', '0xFF')),
                      ),
                    ),
                    title: AppText(field.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColorScheme.error,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

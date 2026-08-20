import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'generic_lookup_screen.dart';

class LookupsScreen extends StatelessWidget {
  const LookupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'تهيئة النظام',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'إعدادات العملاء',
              items: [
                _LookupItem(
                  title: 'حالات العملاء',
                  icon: Icons.flag,
                  color: Colors.blue,
                  type: LookupType.status,
                ),
                _LookupItem(
                  title: 'المصادر',
                  icon: Icons.source,
                  color: Colors.green,
                  type: LookupType.source,
                ),
                _LookupItem(
                  title: 'السلوكيات',
                  icon: Icons.psychology, // or similar
                  color: Colors.purple,
                  type: LookupType.behavior,
                ),
                _LookupItem(
                  title: 'أسباب غير صالح',
                  icon: Icons.block, // or do_not_disturb
                  color: Colors.red,
                  type: LookupType.invalidReason,
                ),
                _LookupItem(
                  title: 'وسوم العملاء',
                  icon: Icons.label,
                  color: Colors.orange,
                  type: LookupType.clientTag,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'إعدادات الفواتير',
              items: [
                _LookupItem(
                  title: 'وسوم الفواتير',
                  icon: Icons.receipt_long,
                  color: Colors.teal,
                  type: LookupType.invoiceTag,
                ),
                _LookupItem(
                  title: 'المنتجات',
                  icon: Icons.inventory_2,
                  color: Colors.brown,
                  type: LookupType.product,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'الإعدادات العامة',
              items: [
                _LookupItem(
                  title: 'أنواع التعليقات',
                  icon: Icons.comment,
                  color: Colors.indigo,
                  type: LookupType.commentType,
                ),
                _LookupItem(
                  title: 'المناطق',
                  icon: Icons.map,
                  color: Colors.lightGreen,
                  type: LookupType.region,
                ),
                _LookupItem(
                  title: 'المدن',
                  icon: Icons.location_city,
                  color: Colors.cyan,
                  type: LookupType.city,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_LookupItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColorScheme.textMain,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) {
            // Calculate width for 2 columns minus spacing
            final width = (MediaQuery.of(context).size.width - 40 - 16) / 2;
            return SizedBox(width: width, child: _buildCard(context, item));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, _LookupItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    GenericLookupScreen(type: item.type, title: item.title),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 28),
                ),
                const SizedBox(height: 12),
                AppText(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Slightly reduced font size
                  ),
                  textAlign: TextAlign.center, // Center text
                  maxLines: 2, // Allow 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LookupItem {
  final String title;
  final IconData icon;
  final Color color;
  final LookupType type;

  _LookupItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.type,
  });
}

import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';

class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChevron(
              icon: Icons.chevron_right_rounded,
              onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            const SizedBox(width: 8),
            ...List.generate(totalPages, (index) {
              final page = index + 1;
              final isSelected = page == currentPage;
              
              // Show only nearby pages if total is large
              if (totalPages > 5 && (page - currentPage).abs() > 1 && page != 1 && page != totalPages) {
                if (page == 2 || page == totalPages - 1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: AppText("...", style: TextStyle(color: AppColorScheme.textMuted)),
                  );
                }
                return const SizedBox.shrink();
              }

              return _buildPageNumber(page, isSelected);
            }),
            const SizedBox(width: 8),
            _buildChevron(
              icon: Icons.chevron_left_rounded,
              onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageNumber(int page, bool isSelected) {
    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColorScheme.primary : AppColorScheme.silverLight.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        alignment: Alignment.center,
        child: AppText(
          page.toString(),
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColorScheme.textMain,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChevron({required IconData icon, VoidCallback? onTap}) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorScheme.silverLight.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColorScheme.textMuted.withOpacity(0.5) : AppColorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}

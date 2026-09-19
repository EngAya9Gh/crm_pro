import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import '../../domain/entities/dashboard_chart_data.dart';

class DashboardCharts extends StatelessWidget {
  final DashboardChartData? chartData;

  const DashboardCharts({super.key, this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData == null ||
        (chartData!.revenueData.isEmpty &&
            chartData!.clientGrowthData.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "الإيرادات (آخر 6 أشهر)",
          style: AppTypography.titleMedium.copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(16, 24, 32, 16),
          decoration: BoxDecoration(
            color: AppColorScheme.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColorScheme.surface, width: 2),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData!.revenueData.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AppText(
                          chartData!.revenueData[index].label,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorScheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return AppText(
                        '${value.toInt()}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColorScheme.textMuted,
                          fontSize: 9,
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData!.revenueData.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value);
                  }).toList(),
                  isCurved: true,
                  color: AppColorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        AppText(
          "نمو العملاء",
          style: AppTypography.titleMedium.copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: AppColorScheme.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColorScheme.surface, width: 2),
          ),
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 ||
                          index >= chartData!.clientGrowthData.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AppText(
                          chartData!.clientGrowthData[index].label,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorScheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: chartData!.clientGrowthData.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value,
                      color: AppColorScheme.info,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        if (chartData!.sourceDistribution.isNotEmpty) ...[
          const SizedBox(height: 32),
          AppText(
            "مصادر العملاء",
            style: AppTypography.titleMedium.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorScheme.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColorScheme.surface, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: chartData!.sourceDistribution.asMap().entries.map((e) {
                        final colors = [
                          AppColorScheme.primary,
                          AppColorScheme.secondary,
                          AppColorScheme.success,
                          AppColorScheme.info,
                          AppColorScheme.warning,
                          AppColorScheme.error,
                        ];
                        final color = colors[e.key % colors.length];
                        return PieChartSectionData(
                          color: color,
                          value: e.value.value,
                          title: e.value.value.toInt().toString(),
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: chartData!.sourceDistribution.asMap().entries.map((e) {
                      final colors = [
                        AppColorScheme.primary,
                        AppColorScheme.secondary,
                        AppColorScheme.success,
                        AppColorScheme.info,
                        AppColorScheme.warning,
                        AppColorScheme.error,
                      ];
                      final color = colors[e.key % colors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                e.value.label,
                                style: AppTypography.labelSmall.copyWith(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

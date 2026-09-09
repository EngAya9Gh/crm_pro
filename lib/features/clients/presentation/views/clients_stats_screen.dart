import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/utils/app_strings.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart';
import '../../domain/entities/client_stats.dart'; // Import ClientStats

class ClientsStatsScreen extends StatelessWidget {
  const ClientsStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientsBloc>()..add(LoadClientStats()),
      child: Scaffold(
        backgroundColor: AppColorScheme.surface,
        appBar: AppBar(
          title: const AppText(
            'إحصائيات العملاء',
            style: TextStyle(color: AppColorScheme.white),
          ),
          backgroundColor: AppColorScheme.primary,
          iconTheme: const IconThemeData(color: AppColorScheme.white),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: AppColorScheme.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<ClientsBloc, ClientsState>(
          builder: (context, state) {
            if (state is ClientsStatsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClientsError) {
              return Center(child: AppText(state.message));
            } else if (state is ClientsStatsLoaded) {
              final stats = state.stats;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(stats),
                    const SizedBox(height: 32),
                    _buildSectionTitle('توزيع الحالات'),
                    const SizedBox(height: 16),
                    _buildStatusChart(stats.byStatus),

                    const SizedBox(height: 32),
                    _buildSectionTitle('أداء المصادر'),
                    const SizedBox(height: 16),
                    _buildSourcesChart(stats.bySource),

                    const SizedBox(height: 32),
                    _buildSectionTitle('أداء الموظفين'),
                    const SizedBox(height: 16),
                    _buildEmployeesTable(
                      stats.employeesPerformance,
                    ), // Passing real data

                    const SizedBox(height: 32),
                    _buildSectionTitle(AppStrings.registrationAnalysis),
                    const SizedBox(height: 16),
                    _buildInvalidRegistrationsChart(stats.invalidRegistrations),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            ); // specific initial state handling
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ClientStats stats) {
    // Calculate some derived stats
    final totalClients = stats.totalClients;

    // Attempt to find "Active" or "converted" clients if possible, usually status Id or Name.
    // For now, let's just show top status.
    final topStatus = stats.byStatus.isNotEmpty
        ? stats.byStatus.reduce((a, b) => a.count > b.count ? a : b)
        : null;

    final topSource = stats.bySource.isNotEmpty
        ? stats.bySource.reduce((a, b) => a.count > b.count ? a : b)
        : null;

    final totalInvalid = stats.invalidRegistrations.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'إجمالي العملاء',
          value: '$totalClients',
          icon: Icons.people,
          color: AppColorScheme.primary,
        ),
        _buildStatCard(
          title: 'أكثر حالة شيوعاً',
          value: topStatus?.statusName ?? '-',
          subtitle: '${topStatus?.count ?? 0}',
          icon: Icons.pie_chart,
          color: AppColorScheme.info,
        ),
        _buildStatCard(
          title: 'أفضل مصدر',
          value: topSource?.sourceName ?? '-',
          subtitle: '${topSource?.count ?? 0}',
          icon: Icons.source,
          color: AppColorScheme.success,
        ),
        _buildStatCard(
          title: 'تسجيلات غير صحيحة',
          value: '$totalInvalid',
          icon: Icons.warning_amber,
          color: AppColorScheme.error,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorScheme.surface),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColorScheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            AppText(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColorScheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColorScheme.primary,
      ),
    );
  }

  Widget _buildStatusChart(List<StatusStat> data) {
    if (data.isEmpty)
      return const Center(child: AppText('لا توجد بيانات للحالات'));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorScheme.surface, width: 2),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: data.map((item) {
                  Color color = AppColorScheme.primary;
                  try {
                    if (item.color.startsWith('#')) {
                      color = Color(
                        int.parse(item.color.substring(1, 7), radix: 16) +
                            0xFF000000,
                      );
                    }
                  } catch (_) {}

                  return PieChartSectionData(
                    color: color,
                    value: item.count.toDouble(),
                    title: '${item.count}',
                    radius: 50,
                    titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: data.map((item) {
              Color color = AppColorScheme.primary;
              try {
                if (item.color.startsWith('#')) {
                  color = Color(
                    int.parse(item.color.substring(1, 7), radix: 16) + 0xFF000000,
                  );
                }
              } catch (_) {}
              return _buildLegendItem(item.statusName == 'N/A' ? 'غير محدد' : item.statusName, item.count, color);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesChart(List<SourceStat> data) {
    if (data.isEmpty)
      return const Center(child: AppText('لا توجد بيانات للمصادر'));

    // Calculate maxY to adjust formatting
    double maxY = 10;
    if (data.isNotEmpty) {
      maxY =
          data
              .map((e) => e.count.toDouble())
              .reduce((curr, next) => curr > next ? curr : next) *
          1.2;
    }

    final List<Color> colors = [
      AppColorScheme.primary,
      AppColorScheme.secondary,
      AppColorScheme.success,
      AppColorScheme.warning,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorScheme.surface, width: 2),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: data.asMap().entries.map((entry) {
                  return _makeGroupData(
                    entry.key,
                    entry.value.count.toDouble(),
                    colors[entry.key % colors.length],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AppText(
                              data[index].sourceName == 'N/A' ? 'غير محدد' : data[index].sourceName,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: data.asMap().entries.map((entry) {
              return _buildLegendItem(
                entry.value.sourceName == 'N/A' ? 'غير محدد' : entry.value.sourceName,
                entry.value.count,
                colors[entry.key % colors.length],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          AppText(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColorScheme.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildEmployeesTable(List<EmployeePerformanceStat> performance) {
    if (performance.isEmpty)
      return const Center(child: AppText('لا توجد بيانات أداء للموظفين'));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorScheme.surface, width: 2),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(),
          ...performance.map(
            (e) => _buildEmployeeRow(
              e.userName,
              e.totalAssigned.toString(),
              e.convertedCount.toString(),
              '${e.conversionRate}%', // Assuming conversionRate is 0-100
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 3,
          child: AppText(
            'الموظف',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: AppText(
            'عملاء',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: AppText(
            'تحويل',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: AppText(
            'المعدل',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeRow(
    String name,
    String count,
    String converted,
    String rate,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppText(name, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(child: AppText(count, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: AppText(converted, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: AppText(
              rate,
              style: const TextStyle(
                fontSize: 12,
                color: AppColorScheme.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidRegistrationsChart(List<InvalidRegistrationStat> data) {
    if (data.isEmpty) return const SizedBox();

    // Calculate maxY
    double maxY = 10;
    if (data.isNotEmpty) {
      maxY =
          data
              .map((e) => e.count.toDouble())
              .reduce((curr, next) => curr > next ? curr : next) *
          1.2;
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorScheme.surface, width: 2),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: data.asMap().entries.map((entry) {
            // Assign some colors dynamically or cycle
            List<Color> colors = [
              AppColorScheme.error,
              Colors.orange,
              AppColorScheme.silver,
              Colors.blue,
            ];
            Color color = colors[entry.key % colors.length];

            return _makeGroupData(
              entry.key,
              entry.value.count.toDouble(),
              color,
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AppText(
                        data[index].reasonName,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

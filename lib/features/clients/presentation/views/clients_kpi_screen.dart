import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart';

class ClientsKPIScreen extends StatelessWidget {
  const ClientsKPIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientsBloc>()..add(LoadClientKPIs()),
      child: Scaffold(
        backgroundColor: AppColorScheme.surface,
        appBar: AppBar(
          title: const AppText(
            'مؤشرات أداء العملاء',
            style: TextStyle(color: AppColorScheme.white),
          ),
          backgroundColor: AppColorScheme.primary,
          iconTheme: const IconThemeData(color: AppColorScheme.white),
          elevation: 0,
        ),
        body: BlocBuilder<ClientsBloc, ClientsState>(
          builder: (context, state) {
            if (state is ClientsStatsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClientsError) {
              return Center(child: AppText(state.message));
            } else if (state is ClientsKPIsLoaded) {
              final kpis = state.kpis;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKPICard(
                      title: '🎯 معدل التحويل',
                      value: '${kpis.conversionRate}%',
                      description: 'نسبة العملاء الجدد الذين أصبحوا مشتركين',
                      color: AppColorScheme.success,
                      icon: Icons.track_changes_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildKPICard(
                      title: '⚡ متوسط الاستجابة الأولى',
                      value: '${kpis.avgResponseTime} ساعة',
                      description: 'الوقت من إضافة العميل حتى أول تعليق',
                      color: Colors.orange,
                      icon: Icons.bolt_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildKPICard(
                      title: '⏱️ متوسط وقت التحويل',
                      value: '${kpis.avgConversionDays} يوم',
                      description: 'متوسط الأيام من حالة جديد إلى مشترك',
                      color: Colors.purple,
                      icon: Icons.timer_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildKPICard(
                      title: '📉 معدل الفقدان',
                      value: '${kpis.lossRate}%',
                      description: 'نسبة العملاء الذين تم استبعادهم',
                      color: AppColorScheme.error,
                      icon: Icons.trending_down_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildKPICard(
                      title: '✅ العملاء الساخنين',
                      value: '${kpis.hotLeads}',
                      description: 'عدد العملاء المحتملين ذوي الأولوية العالية',
                      color: Colors.blue,
                      icon: Icons.checklist_rtl_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildKPICard(
                      title: '👥 إجمالي العملاء',
                      value: '${kpis.totalClients}',
                      description: 'إجمالي عدد العملاء المسجلين',
                      color: Colors.amber,
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorScheme.surface, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            value,
            style: AppTypography.displayMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            description,
            style: AppTypography.labelSmall.copyWith(
              color: AppColorScheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

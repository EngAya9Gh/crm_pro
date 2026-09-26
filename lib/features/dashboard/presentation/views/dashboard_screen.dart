import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:crm_wakeel/core/common/widgets/app_drawer.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/utils/app_strings.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import 'package:crm_wakeel/core/common/widgets/app_logo.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import 'package:crm_wakeel/features/clients/presentation/views/clients_screen.dart';
import 'package:crm_wakeel/features/invoices/presentation/views/invoices_screen.dart';
import 'package:crm_wakeel/features/appointments/presentation/views/appointments_screen.dart';
import 'package:crm_wakeel/features/stock/presentation/views/stock_check_screen.dart';
import 'package:crm_wakeel/features/whatsapp/presentation/pages/whatsapp_inbox_screen.dart';
import 'package:crm_wakeel/features/system_ai/presentation/views/system_ai_screen.dart';
import 'package:crm_wakeel/features/tickets/presentation/views/tickets_screen.dart';
import 'package:crm_wakeel/features/evaluations/presentation/views/evaluations_screen.dart';
import 'package:crm_wakeel/features/tickets/presentation/bloc/tickets_cubit.dart';
import 'package:crm_wakeel/features/evaluations/presentation/bloc/evaluations_cubit.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_charts.dart';
import 'package:crm_wakeel/core/utils/permission_extension.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<DashboardBloc>()..add(const LoadDashboardData());
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: AppScaffold(
        backgroundColor: AppColorScheme.surface,
        titleWidget: const AppLogo(size: 32, showText: false),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColorScheme.secondary,
            ),
            onPressed: () {},
          ),
        ],
        drawer: const AppDrawer(),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (context.hasFeature('whatsapp'))
              FloatingActionButton(
                heroTag: 'whatsapp_fab',
                backgroundColor: const Color(0xFF25D366),
                child: const Icon(Icons.chat, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WhatsappInboxScreen(),
                    ),
                  );
                },
              ),
            if (context.hasFeature('whatsapp'))
              const SizedBox(height: 16),
            if (context.hasFeature('ai_agent'))
              FloatingActionButton(
                heroTag: 'ai_agent_fab',
                backgroundColor: AppColorScheme.primary,
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SystemAiScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading &&
                state.summary == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DashboardStatus.failure &&
                state.summary == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    AppText(state.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _dashboardBloc.add(
                        const LoadDashboardData(isRefresh: true),
                      ),
                      child: const AppText('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _dashboardBloc.add(const LoadDashboardData(isRefresh: true));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumWelcomeCard(state),
                          const SizedBox(height: 32),
                          AppText(
                            "الإحصاءات السريعة",
                            style: AppTypography.titleMedium.copyWith(
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBentoGrid(context, state),
                          const SizedBox(height: 16),
                          DashboardCharts(chartData: state.charts),
                          const SizedBox(height: 8),
                          _buildActivitySection(context, state),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumWelcomeCard(DashboardState state) {
    final summary = state.summary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorScheme.secondary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.secondary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: -20,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColorScheme.white.withValues(alpha: 0.03),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColorScheme.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          "مرحباً، ${summary?.userName ?? 'مدير النظام'}",
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColorScheme.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      summary != null
                          ? "لديك ${summary.upcomingAppointments} مواعيد اليوم و ${summary.pendingInvoices} فواتير معلقة."
                          : "جاري تحميل البيانات...",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColorScheme.silver,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, DashboardState state) {
    final summary = state.summary;
    final bool hasClientsView =
        context.hasPermission('clients.view') && context.hasFeature('clients');
    final bool hasInvoicesView =
        context.hasPermission('invoices.view') &&
        context.hasFeature('invoices');
    final bool hasAppointmentsView =
        context.hasPermission('appointments.view') &&
        context.hasFeature('appointments');
    final bool hasInventoryView = context.hasFeature('inventory');
    final bool hasTicketsView = context.hasFeature('tickets');
    final bool hasEvaluationsView = context.hasFeature('evaluations');

    return Column(
      children: [
        if (hasClientsView) ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DashboardStatCard(
                  title: AppStrings.totalClients,
                  value: summary?.totalClients.toString() ?? '...',
                  icon: Icons.people_alt_rounded,
                  color: AppColorScheme.info,
                  isLarge: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DashboardStatCard(
                  title: AppStrings.activeClients,
                  value: summary?.activeClients.toString() ?? '...',
                  icon: Icons.star_rounded,
                  color: AppColorScheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (hasInvoicesView || hasAppointmentsView) ...[
          Row(
            children: [
              if (hasInvoicesView)
                Expanded(
                  child: DashboardStatCard(
                    title: "الفواتير",
                    value: summary?.totalInvoices.toString() ?? '...',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColorScheme.warning,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InvoicesScreen(),
                      ),
                    ),
                  ),
                ),
              if (hasInvoicesView && hasAppointmentsView)
                const SizedBox(width: 10),
              if (hasAppointmentsView)
                Expanded(
                  child: DashboardStatCard(
                    title: "المواعيد",
                    value: summary?.totalAppointments.toString() ?? '...',
                    icon: Icons.event_available_rounded,
                    color: AppColorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentsScreen(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (hasTicketsView || hasEvaluationsView) ...[
          Row(
            children: [
              if (hasTicketsView)
                Expanded(
                  child: DashboardStatCard(
                    title: "التذاكر",
                    value: state.summary?.totalTickets.toString() ?? "-",
                    icon: Icons.confirmation_num_outlined,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => getIt<TicketsCubit>(),
                          child: const TicketsScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasTicketsView && hasEvaluationsView)
                const SizedBox(width: 10),
              if (hasEvaluationsView)
                Expanded(
                  child: DashboardStatCard(
                    title: "التقييمات",
                    value: state.summary?.totalEvaluations.toString() ?? "-",
                    icon: Icons.star_rounded,
                    color: Colors.amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => getIt<EvaluationsCubit>(),
                          child: const EvaluationsScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (hasInventoryView) ...[
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: "المخزون",
                  value: "فحص",
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColorScheme.secondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StockCheckScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context, DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              AppStrings.recentActivity,
              style: AppTypography.titleMedium,
            ),
            TextButton(
              onPressed: () {},
              child: AppText(
                "مشاهدة الكل",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityList(state),
      ],
    );
  }

  Widget _buildActivityList(DashboardState state) {
    if (state.recentActivities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColorScheme.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: AppText(
            "لا توجد نشاطات حديثة",
            style: TextStyle(color: AppColorScheme.textMuted),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColorScheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorScheme.surface, width: 2),
      ),
      child: AppListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.recentActivities.length,
        separatorBuilder: (_, __) =>
            Divider(color: AppColorScheme.surface, height: 1, indent: 70),
        itemBuilder: (context, index) {
          final activity = state.recentActivities[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColorScheme.surface,
              child: Icon(
                _getActivityIcon(activity.type),
                color: AppColorScheme.primary,
                size: 20,
              ),
            ),
            title: AppText(
              activity.title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: AppText(
                '${activity.createdAt} • بواسطة ${activity.userName ?? 'النظام'}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorScheme.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'client':
        return Icons.person_add_rounded;
      case 'invoice':
        return Icons.receipt_long_rounded;
      case 'appointment':
        return Icons.calendar_today_rounded;
      default:
        return Icons.history_edu_rounded;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return DateFormat('yyyy/MM/dd').format(dateTime);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:crm_wakeel/core/common/widgets/app_drawer.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../bloc/appointments_bloc.dart';
import '../bloc/appointments_event.dart';
import '../bloc/appointments_state.dart';
import '../../domain/entities/appointment.dart';
import 'appointment_details_screen.dart';
import 'add_edit_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final AppointmentsBloc _appointmentsBloc;
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _appointmentsBloc = getIt<AppointmentsBloc>();
    _loadAppointments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _appointmentsBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAppointments({bool isRefresh = false}) {
    _appointmentsBloc.add(
      LoadAppointments(
        dateFrom: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        ),
        dateTo: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        ),
        isRefresh: isRefresh,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _appointmentsBloc.add(LoadMoreAppointments());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentsBloc,
      child: AppScaffold(
        backgroundColor: AppColorScheme.background,
        title: 'المواعيد',
        drawer: const AppDrawer(),
        body: Column(
          children: [
            _buildHeader(),
            _buildCalendarStrip(),
            const SizedBox(height: 24),
            _buildListHeader(),
            Expanded(
              child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
                builder: (context, state) {
                  if (state.status == AppointmentsStatus.loading &&
                      state.appointments.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == AppointmentsStatus.failure &&
                      state.appointments.isEmpty) {
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
                            onPressed: () => _loadAppointments(isRefresh: true),
                            child: const AppText('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: AppColorScheme.textMuted.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const AppText(
                            'لا توجد مواعيد مقررة لهذا اليوم',
                            style: TextStyle(color: AppColorScheme.textMuted),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadAppointments(isRefresh: true),
                    child: AppListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(24),
                      itemCount: state.hasReachedMax
                          ? state.appointments.length
                          : state.appointments.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.appointments.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _buildAppointmentItem(state.appointments[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: _appointmentsBloc,
                  child: const AddEditAppointmentScreen(),
                ),
              ),
            );
          },
          backgroundColor: AppColorScheme.primary,
          icon: const Icon(Icons.add, color: AppColorScheme.white),
          label: AppText(
            'موعد جديد',
            style: AppTypography.labelMedium.copyWith(
              color: AppColorScheme.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: const BoxDecoration(
        color: AppColorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            DateFormat('MMMM yyyy', 'ar').format(_selectedDate),
            style: AppTypography.titleLarge.copyWith(
              color: AppColorScheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, state) {
              final count = state.appointments.length;
              return AppText(
                count == 0
                    ? 'لا توجد مواعيد مقررة'
                    : 'لديك $count موعداً مقرراً',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColorScheme.white.withValues(alpha: 0.8),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        height: 110, // Increased from 100 to prevent overflow
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColorScheme.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AppListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: 60, // Show 2 months
          itemBuilder: (context, index) {
            final date = DateTime.now()
                .subtract(const Duration(days: 7))
                .add(Duration(days: index));
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                _loadAppointments(isRefresh: true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 58, // Increased width slightly
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColorScheme.primary, Color(0xFFFF8533)],
                        )
                      : null,
                  color: isSelected ? null : AppColorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColorScheme.grey100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      _getWeekDayName(date.weekday),
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColorScheme.white.withValues(alpha: 0.9)
                            : AppColorScheme.textMuted,
                        fontSize: 9, // Reduced from 10
                      ),
                    ),
                    const SizedBox(height: 1), // Reduced from 2
                    AppText(
                      '${date.day}',
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected
                            ? AppColorScheme.white
                            : AppColorScheme.textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Explicitly set smaller font size
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                'جدول المواعيد',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AppText(
                DateFormat('hh:mm a').format(appointment.startAt),
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 2, height: 60, color: AppColorScheme.grey100),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: _appointmentsBloc,
                      child: AppointmentDetailsScreen(
                        appointmentId: appointment.id,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorScheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColorScheme.grey100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusBadge(appointment.status),
                        const Spacer(),
                        const Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: AppColorScheme.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      appointment.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (appointment.clientName != null)
                      AppText(
                        appointment.clientName!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColorScheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          '${DateFormat('hh:mm').format(appointment.startAt)} - ${DateFormat('hh:mm a').format(appointment.endAt)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorScheme.textMuted,
                          ),
                        ),
                        const Spacer(),
                        if (appointment.location != null) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            appointment.location!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'scheduled':
        color = AppColorScheme.info;
        label = 'مجدول';
        break;
      case 'completed':
        color = AppColorScheme.success;
        label = 'مكتمل';
        break;
      case 'cancelled':
        color = AppColorScheme.error;
        label = 'ملغى';
        break;
      case 'pending':
        color = AppColorScheme.warning;
        label = 'قيد الانتظار';
        break;
      default:
        color = AppColorScheme.textMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getWeekDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'الاثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      case 7:
        return 'الأحد';
      default:
        return '';
    }
  }
}

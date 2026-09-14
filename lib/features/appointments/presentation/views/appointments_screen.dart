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
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/appointment.dart';
import 'appointment_details_screen.dart';
import 'add_edit_appointment_screen.dart';
import '../../../clients/presentation/views/client_profile_screen.dart'
    as crm_client;
import '../../../clients/presentation/bloc/clients_bloc.dart'
    as crm_client_bloc;
import '../../../clients/domain/entities/client.dart' as client_entity;
import '../../../clients/domain/entities/client_enums.dart' as client_enums;
import '../../../clients/domain/entities/status_entity.dart' as status_entity;
import 'package:crm_wakeel/core/utils/permission_extension.dart';

class AppointmentsScreen extends StatefulWidget {
  final DateTime? initialDate;
  const AppointmentsScreen({super.key, this.initialDate});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final AppointmentsBloc _appointmentsBloc;
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  bool _isCalendarView = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _appointmentsBloc = getIt<AppointmentsBloc>();
    _appointmentsBloc.add(LoadMonthAppointmentsDates(_selectedDate));
    _loadAppointments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _appointmentsBloc.close();
    _scrollController.dispose();
    _calendarScrollController.dispose();
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
        body: RefreshIndicator(
          onRefresh: () async => _loadAppointments(isRefresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeader(),
                    AnimatedCrossFade(
                      firstChild: _buildCalendarStrip(),
                      secondChild: _buildFullCalendar(),
                      crossFadeState: _isCalendarView
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 16),
                    _buildListHeader(),
                  ],
                ),
              ),
              BlocBuilder<AppointmentsBloc, AppointmentsState>(
                builder: (context, state) {
                  if (state.status == AppointmentsStatus.loading &&
                      state.appointments.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.status == AppointmentsStatus.failure &&
                      state.appointments.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
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
                              onPressed: () =>
                                  _loadAppointments(isRefresh: true),
                              child: const AppText('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state.appointments.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
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
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.appointments.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildAppointmentItem(
                            state.appointments[index],
                          );
                        },
                        childCount: state.hasReachedMax
                            ? state.appointments.length
                            : state.appointments.length + 1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: context.hasPermission('appointments.create')
            ? FloatingActionButton.extended(
                onPressed: () {
                  _appointmentsBloc.add(ResetAppointmentOperationStatusEvent());
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
              )
            : null,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColorScheme.primary,
                            onPrimary: Colors.white,
                            onSurface: AppColorScheme.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _loadAppointments(isRefresh: true);
                  }
                },
                child: Row(
                  children: [
                    AppText(
                      DateFormat('MMMM yyyy', 'ar').format(_selectedDate),
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColorScheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        // Subtract a month (using 1st day to avoid overflow issues like Mar 31 -> Feb 28)
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          1,
                        );
                      });
                      _appointmentsBloc.add(
                        LoadMonthAppointmentsDates(_selectedDate),
                      );
                      _loadAppointments(isRefresh: true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        // Add a month
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                          1,
                        );
                      });
                      _appointmentsBloc.add(
                        LoadMonthAppointmentsDates(_selectedDate),
                      );
                      _loadAppointments(isRefresh: true);
                    },
                  ),
                ],
              ),
            ],
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
    final int daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;

    // Auto-scroll to the selected day if possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarScrollController.hasClients) {
        // Approximate width of a calendar item (around 64 width + 8 spacing)
        final double targetScroll = (_selectedDate.day - 1) * 72.0;
        // Don't scroll beyond max scroll extent
        final double maxScroll =
            _calendarScrollController.position.maxScrollExtent;
        final double finalScroll = targetScroll > maxScroll
            ? maxScroll
            : targetScroll;

        _calendarScrollController.animateTo(
          finalScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          return Container(
            height: 100,
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
            child: ListView.builder(
              controller: _calendarScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final date = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  index + 1,
                );
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;
                final dateStr =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                final hasAppointments = state.monthAppointmentsDates.contains(
                  dateStr,
                );

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _loadAppointments(isRefresh: true);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 64,
                        height: 72,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColorScheme.primary,
                                    Color(0xFFFF8533),
                                  ],
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
                                    ? AppColorScheme.white.withValues(
                                        alpha: 0.9,
                                      )
                                    : AppColorScheme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              '${date.day}',
                              style: AppTypography.titleMedium.copyWith(
                                color: isSelected
                                    ? AppColorScheme.white
                                    : AppColorScheme.textMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dot badge — top-right corner
                      if (hasAppointments)
                        Positioned(
                          top: 0,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColorScheme.white
                                  : AppColorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColorScheme.primary.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppColorScheme.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullCalendar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDate,
              currentDay: _selectedDate,
              calendarFormat: _calendarFormat,
              headerVisible: true,
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppColorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: AppTypography.labelSmall.copyWith(
                  color: AppColorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronVisible: false,
                rightChevronVisible: false,
                headerPadding: const EdgeInsets.only(bottom: 8),
              ),
              availableCalendarFormats: const {
                CalendarFormat.month: 'شهر',
                CalendarFormat.twoWeeks: 'أسبوعين',
                CalendarFormat.week: 'أسبوع',
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTypography.labelSmall,
                weekendStyle: AppTypography.labelSmall.copyWith(
                  color: AppColorScheme.textMuted,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                _loadAppointments(isRefresh: true);
              },
              onPageChanged: (focusedDay) {
                setState(() => _selectedDate = focusedDay);
                _appointmentsBloc.add(LoadMonthAppointmentsDates(focusedDay));
                _loadAppointments(isRefresh: true);
              },
              eventLoader: (day) {
                final dateStr =
                    "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                if (state.monthAppointmentsDates.contains(dateStr)) {
                  return ['event'];
                }
                return [];
              },
              calendarStyle: CalendarStyle(
                markerDecoration: const BoxDecoration(
                  color: AppColorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColorScheme.primary,
                ),
              ),
            ),
          );
        },
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
          IconButton(
            icon: Icon(
              _isCalendarView
                  ? Icons.view_agenda_outlined
                  : Icons.calendar_month_outlined,
              color: AppColorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
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
                      InkWell(
                        onTap: appointment.clientId != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) =>
                                          getIt<crm_client_bloc.ClientsBloc>(),
                                      child: crm_client.ClientProfileScreen(
                                        client: client_entity.Client(
                                          id: appointment.clientId!.toString(),
                                          name:
                                              appointment.clientName ??
                                              'بدون اسم',
                                          phone: '',
                                          region: '',
                                          city: '',
                                          status:
                                              const status_entity.StatusEntity(
                                                id: 0,
                                                name: 'غير محدد',
                                                color: '#000000',
                                              ),
                                          priority:
                                              client_enums.ClientPriority.low,
                                          sourceStatus:
                                              client_enums.SourceStatus.valid,
                                          createdAt: DateTime.now(),
                                          tags: const [],
                                          files: const [],
                                          comments: const [],
                                          invoices: const [],
                                          appointments: const [],
                                          timeline: const [],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: AppText(
                                appointment.clientName!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (appointment.clientStatusName != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (appointment.clientStatusColor != null
                                              ? Color(
                                                  int.parse(
                                                    appointment
                                                        .clientStatusColor!
                                                        .replaceFirst(
                                                          '#',
                                                          '0xFF',
                                                        ),
                                                  ),
                                                )
                                              : AppColorScheme.primary)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  appointment.clientStatusName!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: appointment.clientStatusColor != null
                                        ? Color(
                                            int.parse(
                                              appointment.clientStatusColor!
                                                  .replaceFirst('#', '0xFF'),
                                            ),
                                          )
                                        : AppColorScheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                        const SizedBox(width: 16),
                        if (appointment.location != null)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: AppText(
                                    appointment.location!.replaceAll('\n', ' '),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      case 'no_show':
        color = AppColorScheme.error;
        label = 'لم يحضر';
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

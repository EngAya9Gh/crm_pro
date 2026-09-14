import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import '../../../clients/presentation/views/client_profile_screen.dart'
    as crm_client;
import '../../../clients/presentation/bloc/clients_bloc.dart'
    as crm_client_bloc;
import '../../../clients/domain/entities/client.dart' as client_entity;
import '../../../clients/domain/entities/client_enums.dart' as client_enums;
import '../../../clients/domain/entities/status_entity.dart' as status_entity;
import '../../domain/entities/appointment.dart';
import '../bloc/appointments_bloc.dart';
import '../bloc/appointments_event.dart';
import '../bloc/appointments_state.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import 'package:crm_wakeel/core/utils/permission_extension.dart';
import 'add_edit_appointment_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentsBloc>().add(
      GetAppointmentDetailsEvent(widget.appointmentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'تفاصيل الموعد',
      actions: [
        BlocBuilder<AppointmentsBloc, AppointmentsState>(
          builder: (context, state) {
            final appt = state.appointmentDetail;
            if (appt == null) return const SizedBox.shrink();

            final isCompleted = appt.status.toLowerCase() == 'completed';
            final canReschedule =
                !isCompleted ||
                context.hasPermission('appointments.manage_completed');

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    context.read<AppointmentsBloc>().add(
                      ResetAppointmentOperationStatusEvent(),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AppointmentsBloc>(),
                          child: AddEditAppointmentScreen(
                            appointmentId: widget.appointmentId,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(context);
                    } else if (value == 'reschedule') {
                      _showRescheduleDialog(context, appt);
                    } else {
                      _showStatusDialog(context, value);
                    }
                  },
                  itemBuilder: (context) => [
                    if (canReschedule)
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: AppText('إعادة جدولة'),
                      ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: AppText('تعيين كمكتمل'),
                    ),
                    const PopupMenuItem(
                      value: 'cancelled',
                      child: AppText('إلغاء الموعد'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: AppText(
                        'حذف',
                        style: TextStyle(color: AppColorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
      body: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state.operationStatus == AppointmentOperationStatus.success) {
            if (state.operationMessage.contains('حذف')) {
              Navigator.pop(context);
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: AppText(state.operationMessage)));
          } else if (state.operationStatus ==
              AppointmentOperationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(state.operationMessage),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.detailStatus == AppointmentsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.detailStatus == AppointmentsStatus.failure) {
            return Center(
              child: AppText(
                state.errorMessage,
                style: const TextStyle(color: AppColorScheme.error),
              ),
            );
          }

          final appointment = state.appointmentDetail;
          if (appointment == null) {
            return const Center(child: AppText('لا توجد بيانات'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(appointment.status),
                const SizedBox(height: 24),
                AppText(
                  appointment.title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (appointment.clientName != null) ...[
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
                                          appointment.clientName ?? 'بدون اسم',
                                      phone: '',
                                      region: '',
                                      city: '',
                                      status: const status_entity.StatusEntity(
                                        id: 0,
                                        name: 'غير محدد',
                                        color: '#000000',
                                      ),
                                      priority: client_enums.ClientPriority.low,
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
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: AppColorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          appointment.clientName!,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoItem(
                  Icons.calendar_today_outlined,
                  'التاريخ',
                  DateFormat(
                    'EEEE, d MMMM yyyy',
                    'ar',
                  ).format(appointment.startAt),
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  Icons.access_time,
                  'الوقت',
                  '${DateFormat('hh:mm a').format(appointment.startAt)} - ${DateFormat('hh:mm a').format(appointment.endAt)}',
                ),
                const SizedBox(height: 16),
                if (appointment.location != null) ...[
                  _buildInfoItem(
                    Icons.location_on_outlined,
                    'الموقع',
                    appointment.location!,
                  ),
                  const SizedBox(height: 16),
                ],
                if (appointment.description != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const AppText(
                    'الوصف',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    appointment.description!,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'scheduled':
        color = AppColorScheme.info;
        label = 'موعد مجدول';
        break;
      case 'completed':
        color = AppColorScheme.success;
        label = 'موعد مكتمل';
        break;
      case 'cancelled':
        color = AppColorScheme.error;
        label = 'موعد ملغى';
        break;
      default:
        color = AppColorScheme.textMuted;
        label = status;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          AppText(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColorScheme.textMuted,
              ),
            ),
            AppText(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AppointmentsBloc>(),
        child: AlertDialog(
          title: const AppText('تأكيد الحذف'),
          content: const AppText('هل أنت متأكد من حذف هذا الموعد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                context.read<AppointmentsBloc>().add(
                  DeleteAppointmentEvent(widget.appointmentId),
                );
                Navigator.pop(context);
              },
              child: const AppText(
                'حذف',
                style: TextStyle(color: AppColorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, String newStatus) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AppointmentsBloc>(),
        child: AlertDialog(
          title: const AppText('تغيير حالة الموعد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText('سيتم تغيير الحالة إلى: $newStatus'),
              const SizedBox(height: 16),
              AppTextField(
                controller: noteController,
                label: 'ملاحظة (اختياري)',
                hintText: 'أضف تعليقاً للحالة',
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                context.read<AppointmentsBloc>().add(
                  ChangeAppointmentStatusEvent(
                    widget.appointmentId,
                    newStatus,
                    note: noteController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              child: const AppText('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, Appointment appointment) {
    DateTime selectedDate = appointment.startAt;
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(appointment.startAt);
    int durationMinutes = appointment.endAt
        .difference(appointment.startAt)
        .inMinutes;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AppointmentsBloc>(),
        child: StatefulBuilder(
          builder: (stCtx, setState) {
            return AlertDialog(
              title: const AppText('إعادة جدولة الموعد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: stCtx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null)
                          setState(() => selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'التاريخ الجديد',
                          border: OutlineInputBorder(),
                        ),
                        child: AppText(
                          DateFormat('yyyy/MM/dd').format(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: stCtx,
                          initialTime: selectedStartTime,
                        );
                        if (picked != null)
                          setState(() => selectedStartTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'وقت البدء',
                          border: OutlineInputBorder(),
                        ),
                        child: AppText(selectedStartTime.format(stCtx)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: durationMinutes,
                      decoration: const InputDecoration(
                        labelText: 'المدة (بالدقائق)',
                        border: OutlineInputBorder(),
                      ),
                      items: [15, 30, 45, 60, 90, 120]
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: AppText('$m دقيقة'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => durationMinutes = v ?? 60),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: noteController,
                      label: 'سبب الجدولة (اختياري)',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const AppText('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    final startAt = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedStartTime.hour,
                      selectedStartTime.minute,
                    );
                    final endAt = startAt.add(
                      Duration(minutes: durationMinutes),
                    );
                    context.read<AppointmentsBloc>().add(
                      RescheduleAppointmentEvent(
                        widget.appointmentId,
                        startAt,
                        endAt,
                        note: noteController.text.trim(),
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const AppText('حفظ الجدولة'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

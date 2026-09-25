import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import 'package:crm_wakeel/features/clients/domain/entities/timeline_event.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_enums.dart';

import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart';

class ClientTimelineTab extends StatefulWidget {
  final String clientId;

  const ClientTimelineTab({super.key, required this.clientId});

  @override
  State<ClientTimelineTab> createState() => _ClientTimelineTabState();
}

class _ClientTimelineTabState extends State<ClientTimelineTab> {
  @override
  void initState() {
    super.initState();
    context.read<ClientsBloc>().add(LoadClientTimeline(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientsBloc, ClientsState>(
      buildWhen: (previous, current) =>
          current is ClientTimelineLoaded ||
          (current is ClientsLoading && previous is! ClientTimelineLoaded) ||
          current is ClientsError,
      builder: (context, state) {
        if (state is ClientsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClientsError) {
          // If we have previous events maybe show them? For now just error.
          return Center(child: AppText(state.message));
        }

        List<TimelineEvent> events = [];
        if (state is ClientTimelineLoaded) {
          events = state.events;
        }

        if (events.isEmpty) {
          // Fallback if not loaded yet (shouldn't happen if loading handled) or empty
          if (state is ClientTimelineLoaded) {
            return const Center(
              child: AppText(
                'لا توجد أحداث',
                style: TextStyle(color: AppColorScheme.textMuted),
              ),
            );
          }
          if (state is ClientsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
        }

        return AppListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isLast = index == events.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getEventColor(event.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColorScheme.surface,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                _getEventTitle(event.type),
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              AppText(
                                _formatDate(event.occurredAt),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColorScheme.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            event.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColorScheme.textMain,
                            ),
                          ),
                          if (event.performedBy != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: AppText(
                                'بواسطة: ${event.performedBy}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColorScheme.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getEventColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.clientCreated:
        return AppColorScheme.success;
      case TimelineEventType.statusChanged:
        return AppColorScheme.info;
      case TimelineEventType.commentAdded:
        return AppColorScheme.primary;
      case TimelineEventType.fileUploaded:
        return Colors.purple;
      case TimelineEventType.invoiceCreated:
        return Colors.orange;
      case TimelineEventType.appointmentScheduled:
        return Colors.teal;
      case TimelineEventType.assigned:
        return AppColorScheme.secondary;
      case TimelineEventType.contacted:
        return Colors.blueGrey;
      case TimelineEventType.unknown:
        return AppColorScheme.textMuted;
    }
  }

  String _getEventTitle(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.clientCreated:
        return 'إضافة عميل';
      case TimelineEventType.statusChanged:
        return 'تغيير الحالة';
      case TimelineEventType.commentAdded:
        return 'تعليق جديد';
      case TimelineEventType.fileUploaded:
        return 'رفع ملف';
      case TimelineEventType.invoiceCreated:
        return 'فاتورة جديدة';
      case TimelineEventType.appointmentScheduled:
        return 'موعد مجدول';
      case TimelineEventType.assigned:
        return 'إسناد موظف';
      case TimelineEventType.contacted:
        return 'تواصل جديد';
      case TimelineEventType.unknown:
        return 'حدث';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

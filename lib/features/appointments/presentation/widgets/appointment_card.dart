import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentCard({super.key, required this.appointment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('dd');
    final monthFormat = DateFormat('MMM');
    final timeFormat = DateFormat('hh:mm a');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Date Strip
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: AppColorScheme.primary.withOpacity(0.08),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      dayFormat.format(appointment.startAt),
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 26,
                        color: AppColorScheme.primary,
                        height: 1.1,
                      ),
                    ),
                    AppText(
                      monthFormat.format(appointment.startAt).toUpperCase(),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _buildTypeIcon(appointment.type),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppText(
                                    appointment.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(appointment.status),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppColorScheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          AppText(
                            '${timeFormat.format(appointment.startAt)} - ${timeFormat.format(appointment.endAt)}',
                            style: const TextStyle(
                              color: AppColorScheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Location (if present)
                      if (appointment.location != null &&
                          appointment.location!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColorScheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText(
                                appointment.location!,
                                style: const TextStyle(
                                  color: AppColorScheme.textMuted,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'meeting':
        icon = Icons.people_alt_outlined;
        color = Colors.purple;
        break;
      case 'call':
        icon = Icons.phone_callback_rounded;
        color = Colors.blue;
        break;
      case 'visit':
        icon = Icons.business_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.calendar_today_rounded;
        color = AppColorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.done_all;
        break;
      case 'scheduled':
        color = Colors.blue;
        icon = Icons.event;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          AppText(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

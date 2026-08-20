import 'package:crm_wakeel/features/clients/domain/entities/client_enums.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class EnumHelpers {
  static String getClientStatusArabic(ClientStatus status) {
    switch (status) {
      case ClientStatus.newClient:
        return 'جديد';
      case ClientStatus.contacted:
        return 'تواصل';
      case ClientStatus.interested:
        return 'مهتم';
      case ClientStatus.proposal:
        return 'عرض سعر';
      case ClientStatus.negotiation:
        return 'تفاوض';
      case ClientStatus.subscribed:
        return 'مشترك';
      case ClientStatus.excluded:
        return 'مستبعد';
    }
  }

  static Color getClientStatusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.newClient:
        return AppColorScheme.info; // Blue
      case ClientStatus.contacted:
        return AppColorScheme.warning; // Yellow/Amber
      case ClientStatus.interested:
        return Colors.orange;
      case ClientStatus.proposal:
        return Colors.purple;
      case ClientStatus.negotiation:
        return Colors.deepOrange;
      case ClientStatus.subscribed:
        return AppColorScheme.success; // Green
      case ClientStatus.excluded:
        return AppColorScheme.error; // Red
    }
  }

  static String getClientPriorityArabic(ClientPriority priority) {
    switch (priority) {
      case ClientPriority.high:
        return 'عالية';
      case ClientPriority.medium:
        return 'متوسطة';
      case ClientPriority.low:
        return 'منخفضة';
    }
  }

  static Color getClientPriorityColor(ClientPriority priority) {
    switch (priority) {
      case ClientPriority.high:
        return AppColorScheme.error;
      case ClientPriority.medium:
        return AppColorScheme.warning;
      case ClientPriority.low:
        return AppColorScheme.success;
    }
  }

  static String getClientRatingArabic(ClientRating rating) {
    switch (rating) {
      case ClientRating.hot:
        return '🔥 Hot';
      case ClientRating.warm:
        return '🌡️ Warm';
      case ClientRating.cold:
        return '❄️ Cold';
    }
  }
}

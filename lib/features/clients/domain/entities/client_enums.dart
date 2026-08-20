import 'package:flutter/material.dart';

enum ClientStatus {
  newClient, // جديد 🔵
  contacted, // تواصل 🟡
  interested, // مهتم 🟠
  proposal, // عرض سعر 🟣
  negotiation, // تفاوض 🟠
  subscribed, // مشترك 🟢
  excluded, // مستبعد 🔴
}

extension ClientStatusExtension on ClientStatus {
  String get localizedName {
    switch (this) {
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

  Color get color {
    switch (this) {
      case ClientStatus.newClient:
        return Colors.blue;
      case ClientStatus.contacted:
        return Colors.amber;
      case ClientStatus.interested:
        return Colors.orange;
      case ClientStatus.proposal:
        return Colors.purple;
      case ClientStatus.negotiation:
        return Colors.deepOrange;
      case ClientStatus.subscribed:
        return Colors.green;
      case ClientStatus.excluded:
        return Colors.red;
    }
  }
}

enum ClientPriority { high, medium, low }

enum ClientRating { hot, warm, cold }

enum SourceStatus { valid, invalid }

enum CommentOutcome { positive, neutral, negative }

enum FileType { contract, identity, document, image, pdf, doc, other }

enum TimelineEventType {
  clientCreated, // تم إضافة العميل
  statusChanged, // تغيير الحالة
  assigned, // تم الإسناد
  commentAdded, // تم إضافة تعليق
  fileUploaded, // تم رفع ملف
  invoiceCreated, // تم إنشاء فاتورة
  appointmentScheduled, // تم جدولة موعد
  contacted, // تم التواصل
  unknown, // غير معروف
}

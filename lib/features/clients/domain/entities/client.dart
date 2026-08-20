import '../../../../features/appointments/domain/entities/appointment.dart';
import '../../../../features/invoices/domain/entities/invoice.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'client_enums.dart';
import 'client_file.dart';
import 'comment.dart';
import 'status_entity.dart';
import 'tag_entity.dart';
import 'timeline_event.dart';

class Client {
  // ─── المعلومات الأساسية ───
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? company;

  // ─── الموقع ───
  // ─── الموقع ───
  final String region;
  final int? regionId;
  final String city;
  final int? cityId;
  final String? address;

  // ─── الحالة والتقييم ───
  final StatusEntity status;
  final ClientPriority priority; // عالية، متوسطة، منخفضة
  final ClientRating? leadRating; // hot, warm, cold (قبل الاشتراك)

  final String? behaviorId;
  final String? behaviorName; // Added

  // ─── المصدر ───
  final String? sourceId;
  final String? sourceName; // Added
  final SourceStatus sourceStatus;
  final String? invalidReasonId;
  final String? invalidReasonName; // Added

  // ─── الإسناد ───
  final UserEntity? assignedTo; // الموظف المسؤول

  // ─── الأوقات المهمة ───
  final DateTime createdAt; // تاريخ الإضافة
  final DateTime? firstContactAt; // أول تواصل (لحساب KPI)
  final DateTime? convertedAt; // تاريخ التحويل لمشترك

  // ─── الاستبعاد ───
  final String? exclusionReason; // سبب الاستبعاد

  // ─── الإضافات ───
  final List<TagEntity> tags; // الوسوم
  final List<ClientFile> files; // الملفات (عقود، هوية...)

  // ─── العلاقات ───
  final List<Comment> comments;
  final List<Invoice> invoices;
  final List<Appointment> appointments;
  final List<TimelineEvent> timeline;

  Client({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.company,
    required this.region,
    this.regionId,
    required this.city,
    this.cityId,
    this.address,
    required this.status,
    required this.priority,

    this.leadRating,
    this.behaviorId,
    this.behaviorName,
    this.sourceId,
    this.sourceName,
    required this.sourceStatus,
    this.invalidReasonId,
    this.invalidReasonName,
    this.assignedTo,
    required this.createdAt,
    this.firstContactAt,
    this.convertedAt,
    this.exclusionReason,
    required this.tags,
    required this.files,
    required this.comments,
    required this.invoices,
    required this.appointments,
    required this.timeline,
  });
}

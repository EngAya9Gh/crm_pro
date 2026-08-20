import 'client_enums.dart';

class SavedFilter {
  final String id;
  final String name;
  final ClientFilter filter;
  final DateTime createdAt;
  final bool isDefault;

  SavedFilter({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'criteria': filter.toJson(), 'is_default': isDefault};
  }

  factory SavedFilter.fromJson(Map<String, dynamic> json) {
    return SavedFilter(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      filter: ClientFilter.fromJson(json['criteria'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isDefault: json['is_default'] ?? false,
    );
  }
}

class ClientFilter {
  final List<String>? statusIds; // IDs from API
  final List<ClientPriority>? priorities;
  final List<ClientRating>? ratings;
  final List<String>? sourceIds;
  final List<String>? behaviorIds;
  final List<String>? tagIds;
  final String? assignedTo;
  final String? region;
  final String? city;
  final SourceStatus? sourceStatus;
  final DateTimeRange? createdDateRange;
  final DateTimeRange? lastActivityRange;
  final String? searchQuery;

  ClientFilter({
    this.statusIds,
    this.priorities,
    this.ratings,
    this.sourceIds,
    this.behaviorIds,
    this.tagIds,
    this.assignedTo,
    this.region,
    this.city,
    this.sourceStatus,
    this.createdDateRange,
    this.lastActivityRange,
    this.searchQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'status_ids': statusIds,
      'priorities': priorities?.map((e) => e.name).toList(),
      'ratings': ratings?.map((e) => e.name).toList(),
      'source_ids': sourceIds,
      'behavior_ids': behaviorIds,
      'tag_ids': tagIds,
      'assigned_to': assignedTo,
      'region': region,
      'city': city,
      'source_status': sourceStatus?.name,
      'created_date_range': createdDateRange?.toJson(),
      'last_activity_range': lastActivityRange?.toJson(),
      'search_query': searchQuery,
    };
  }

  factory ClientFilter.fromJson(Map<String, dynamic> json) {
    return ClientFilter(
      statusIds: (json['status_ids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      priorities: (json['priorities'] as List?)
          ?.map(
            (e) => ClientPriority.values.firstWhere(
              (v) => v.name == e,
              orElse: () => ClientPriority.low, // Default or safer fallback?
            ),
          )
          .toList(),
      ratings: (json['ratings'] as List?)
          ?.map(
            (e) => ClientRating.values.firstWhere(
              (v) => v.name == e,
              orElse: () => ClientRating.cold,
            ),
          )
          .toList(),
      sourceIds: (json['source_ids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      behaviorIds: (json['behavior_ids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      tagIds: (json['tag_ids'] as List?)?.map((e) => e.toString()).toList(),
      assignedTo: json['assigned_to'],
      region: json['region'],
      city: json['city'],
      sourceStatus: json['source_status'] != null
          ? SourceStatus.values.firstWhere(
              (e) => e.name == json['source_status'],
              orElse: () => SourceStatus.valid,
            )
          : null,
      createdDateRange: json['created_date_range'] != null
          ? DateTimeRange.fromJson(json['created_date_range'])
          : null,
      lastActivityRange: json['last_activity_range'] != null
          ? DateTimeRange.fromJson(json['last_activity_range'])
          : null,
      searchQuery: json['search_query'],
    );
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {'start': start.toIso8601String(), 'end': end.toIso8601String()};
  }

  factory DateTimeRange.fromJson(Map<String, dynamic> json) {
    return DateTimeRange(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}

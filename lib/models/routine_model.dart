import 'class_session.dart';

class RoutineMetadata {
  final String batch;
  final String section;
  final String department;
  final String effectiveDate;

  RoutineMetadata({
    required this.batch,
    required this.section,
    required this.department,
    this.effectiveDate = '',
  });

  String get semester => 'Fall';
  int get year => 2026;
  String get campus => 'Permanent Campus';

  factory RoutineMetadata.fromJson(Map<String, dynamic> json) {
    return RoutineMetadata(
      batch: (json['batch'] ?? 'N/A').toString().trim(),
      section: (json['section'] ?? 'N/A').toString().trim().toUpperCase(),
      department: (json['department'] ?? 'Department of Software Engineering').toString().trim(),
      effectiveDate: (json['effectiveDate'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch': batch,
      'section': section,
      'department': department,
      'effectiveDate': effectiveDate,
    };
  }

  RoutineMetadata copyWith({
    String? batch,
    String? section,
    String? department,
    String? effectiveDate,
  }) {
    return RoutineMetadata(
      batch: batch ?? this.batch,
      section: section ?? this.section,
      department: department ?? this.department,
      effectiveDate: effectiveDate ?? this.effectiveDate,
    );
  }
}

class RoutineModel {
  final RoutineMetadata metadata;
  final List<ClassSession> schedule;

  RoutineModel({
    required this.metadata,
    required this.schedule,
  });

  static const List<String> weekdays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static const List<String> standardTimeSlots = [
    '08:30 - 10:00',
    '10:00 - 11:30',
    '11:30 - 13:00',
    '13:00 - 14:30',
    '14:30 - 16:00',
    '16:00 - 17:30',
    '17:30 - 19:00',
  ];

  /// Get available subgroups dynamically based on schedule and section (e.g. ['A1', 'A2'] or ['D1', 'D2'])
  List<String> get availableSubgroups {
    final groupsSet = schedule
        .map((s) => s.subgroup.toUpperCase().trim())
        .where((g) => g != 'ALL' && g.isNotEmpty)
        .toSet();

    if (groupsSet.isEmpty) {
      final sec = metadata.section.isNotEmpty ? metadata.section : 'A';
      return ['${sec}1', '${sec}2'];
    }

    final list = groupsSet.toList()..sort();
    return list;
  }

  /// Get sessions for a specific day
  List<ClassSession> getSessionsForDay(String day, {String subgroupFilter = 'ALL', String search = ''}) {
    return schedule.where((session) {
      if (session.day.toLowerCase() != day.toLowerCase()) return false;
      if (!session.matchesSubgroup(subgroupFilter)) return false;
      if (search.isNotEmpty) {
        final query = search.toLowerCase();
        final match = session.courseCode.toLowerCase().contains(query) ||
            session.courseTitle.toLowerCase().contains(query) ||
            (session.facultyInitial ?? '').toLowerCase().contains(query) ||
            session.room.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  /// All filtered sessions
  List<ClassSession> getFilteredSchedule({String? day, String subgroupFilter = 'ALL', String search = ''}) {
    return schedule.where((session) {
      if (day != null && session.day.toLowerCase() != day.toLowerCase()) return false;
      if (!session.matchesSubgroup(subgroupFilter)) return false;
      if (search.isNotEmpty) {
        final query = search.toLowerCase();
        final match = session.courseCode.toLowerCase().contains(query) ||
            session.courseTitle.toLowerCase().contains(query) ||
            (session.facultyInitial ?? '').toLowerCase().contains(query) ||
            session.room.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  /// Unique courses
  Set<String> get uniqueCourses {
    return schedule.map((s) => '${s.courseCode}: ${s.courseTitle}').toSet();
  }

  /// Unique faculties
  Set<String> get uniqueFaculty {
    return schedule
        .where((s) => s.facultyInitial != null && s.facultyInitial!.isNotEmpty)
        .map((s) => s.facultyInitial!)
        .toSet();
  }

  /// Unique rooms
  Set<String> get uniqueRooms {
    return schedule.map((s) => s.room).toSet();
  }

  /// Total classes count
  int get totalSessions => schedule.length;

  /// Total labs count
  int get totalLabs => schedule.where((s) => s.isLab).length;

  /// Total theory count
  int get totalTheories => schedule.where((s) => s.isTheory).length;

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    final metadataJson = json['metadata'] as Map<String, dynamic>? ?? {};
    final meta = RoutineMetadata.fromJson(metadataJson);

    final scheduleList = (json['schedule'] as List<dynamic>?) ?? [];

    return RoutineModel(
      metadata: meta,
      schedule: scheduleList
          .map((item) => ClassSession.fromJson(
                item as Map<String, dynamic>,
                section: meta.section,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'schedule': schedule.map((session) => session.toJson()).toList(),
    };
  }

  RoutineModel copyWith({
    RoutineMetadata? metadata,
    List<ClassSession>? schedule,
  }) {
    return RoutineModel(
      metadata: metadata ?? this.metadata,
      schedule: schedule ?? this.schedule,
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClassSession {
  final String id;
  final String day; // Saturday, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String courseTitle;
  final String courseCode;
  final String? facultyInitial;
  final String room;
  final String type; // 'theory' or 'lab'
  final String subgroup; // 'ALL', 'A1', 'A2', 'D1', 'D2', etc.

  ClassSession({
    String? id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.courseTitle,
    required this.courseCode,
    this.facultyInitial,
    required this.room,
    required this.type,
    required this.subgroup,
  }) : id = id ?? '${day}_${startTime}_${courseCode}_$subgroup';

  bool get isLab => type.toLowerCase() == 'lab';
  bool get isTheory => type.toLowerCase() == 'theory';
  bool get isOnline => room.toLowerCase().contains('online') || room.toLowerCase().contains('meet');
  String get roomNo => room;
  String get teacherName => facultyInitial ?? '';
  String get timeSlot => formattedTimeRange;

  /// Check if this session matches the selected subgroup filter
  bool matchesSubgroup(String filter) {
    final f = filter.toUpperCase().trim();
    if (f == 'ALL') return true;
    if (f == 'THEORY') return isTheory;
    if (f == 'LAB') return isLab;

    final s = subgroup.toUpperCase().trim();
    if (s == 'ALL') return true; // Theory/general classes apply to all groups
    if (s == f) return true;

    // Match if numerical subgroup matches (e.g. filter 'A1' matches '1' or 'D1' when normalized)
    if (f.endsWith('1') && (s.endsWith('1') || s == '1')) return true;
    if (f.endsWith('2') && (s.endsWith('2') || s == '2')) return true;

    return false;
  }

  /// Start time in minutes from midnight for sorting/layout
  int get startMinutes {
    return _parseMinutes(startTime);
  }

  /// End time in minutes from midnight
  int get endMinutes {
    return _parseMinutes(endTime);
  }

  /// Duration in minutes
  int get durationMinutes => endMinutes - startMinutes;

  static int _parseMinutes(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return (hours * 60) + minutes;
      }
    } catch (_) {}
    return 0;
  }

  /// Formatted time string, e.g. "10:00 - 11:30" or 12h format
  String get formattedTimeRange => '$startTime - $endTime';

  /// Generates a consistent accent color for the course code
  Color get courseColor {
    final colors = [
      const Color(0xFF0284C7), // Sky blue
      const Color(0xFF0D9488), // Teal
      const Color(0xFF059669), // Emerald
      const Color(0xFF7C3AED), // Violet
      const Color(0xFFD97706), // Amber
      const Color(0xFFE11D48), // Rose
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFFEA580C), // Orange
    ];
    int hash = 0;
    for (int i = 0; i < courseCode.length; i++) {
      hash = (hash * 31 + courseCode.codeUnitAt(i)) & 0xFFFFFF;
    }
    return colors[hash % colors.length];
  }

  /// Color for subgroup badge
  Color get subgroupColor {
    final s = subgroup.toUpperCase();
    if (s == 'ALL') return AppTheme.groupAllColor;
    if (s.endsWith('1') || s == '1') return AppTheme.groupD1Color;
    if (s.endsWith('2') || s == '2') return AppTheme.groupD2Color;
    return AppTheme.primaryTeal;
  }

  factory ClassSession.fromJson(Map<String, dynamic> json, {String? section}) {
    final cleanSection = (section ?? '').trim().toUpperCase();

    // Clean and normalize subgroup
    String rawSubgroup = (json['subgroup'] ?? 'ALL').toString().toUpperCase().trim();

    if (rawSubgroup == 'ALL' || rawSubgroup.isEmpty) {
      rawSubgroup = 'ALL';
    } else {
      // If we know the section letter (e.g. 'A', 'B', 'C', 'D')
      final secLetter = cleanSection.isNotEmpty && cleanSection.length == 1 ? cleanSection : '';

      if (rawSubgroup.contains('1')) {
        rawSubgroup = secLetter.isNotEmpty ? '${secLetter}1' : (rawSubgroup.length <= 2 ? rawSubgroup : '1');
      } else if (rawSubgroup.contains('2')) {
        rawSubgroup = secLetter.isNotEmpty ? '${secLetter}2' : (rawSubgroup.length <= 2 ? rawSubgroup : '2');
      }
    }

    // Clean and normalize type
    String rawType = (json['type'] ?? 'theory').toString().toLowerCase().trim();
    if (rawType != 'lab' && rawType != 'theory') {
      rawType = rawType.contains('lab') ? 'lab' : 'theory';
    }

    return ClassSession(
      day: json['day'] as String? ?? 'Sunday',
      startTime: _normalizeTime(json['startTime'] as String? ?? '10:00'),
      endTime: _normalizeTime(json['endTime'] as String? ?? '11:30'),
      courseTitle: json['courseTitle'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      facultyInitial: json['facultyInitial'] as String?,
      room: json['room'] as String? ?? 'TBD',
      type: rawType,
      subgroup: rawSubgroup,
    );
  }

  static String _normalizeTime(String time) {
    final clean = time.trim();
    final parts = clean.split(':');
    if (parts.length == 2 && parts[0].length == 1) {
      return '0${parts[0]}:${parts[1]}';
    }
    return clean;
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'courseTitle': courseTitle,
      'courseCode': courseCode,
      'facultyInitial': facultyInitial,
      'room': room,
      'type': type,
      'subgroup': subgroup,
    };
  }

  ClassSession copyWith({
    String? day,
    String? startTime,
    String? endTime,
    String? courseTitle,
    String? courseCode,
    String? facultyInitial,
    String? room,
    String? type,
    String? subgroup,
  }) {
    return ClassSession(
      id: id,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      courseTitle: courseTitle ?? this.courseTitle,
      courseCode: courseCode ?? this.courseCode,
      facultyInitial: facultyInitial ?? this.facultyInitial,
      room: room ?? this.room,
      type: type ?? this.type,
      subgroup: subgroup ?? this.subgroup,
    );
  }
}

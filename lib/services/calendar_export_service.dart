import '../models/routine_model.dart';
import 'export_helper.dart';

class CalendarExportService {
  /// Converts routine schedule to iCalendar (.ics) format
  static String generateICalendar(RoutineModel routine, {String subgroupFilter = 'ALL'}) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//DIU Class Routine//University Timetable//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:${routine.metadata.department} - Sec ${routine.metadata.section} (Batch ${routine.metadata.batch})');
    buffer.writeln('X-WR-TIMEZONE:Asia/Dhaka');

    final filtered = routine.getFilteredSchedule(subgroupFilter: subgroupFilter);

    final dayToIcsDay = {
      'saturday': 'SA',
      'sunday': 'SU',
      'monday': 'MO',
      'tuesday': 'TU',
      'wednesday': 'WE',
      'thursday': 'TH',
      'friday': 'FR',
    };

    final now = DateTime.now();

    for (int i = 0; i < filtered.length; i++) {
      final session = filtered[i];
      final dayLower = session.day.toLowerCase();
      final icsDay = dayToIcsDay[dayLower] ?? 'SU';

      final startParts = session.startTime.split(':');
      final endParts = session.endTime.split(':');
      final startH = startParts.isNotEmpty ? int.tryParse(startParts[0]) ?? 10 : 10;
      final startM = startParts.length > 1 ? int.tryParse(startParts[1]) ?? 0 : 0;
      final endH = endParts.isNotEmpty ? int.tryParse(endParts[0]) ?? 11 : 11;
      final endM = endParts.length > 1 ? int.tryParse(endParts[1]) ?? 30 : 30;

      final targetWeekday = _weekdayToInt(session.day);
      final daysDiff = (targetWeekday - now.weekday + 7) % 7;
      final sessionDate = now.add(Duration(days: daysDiff));

      final dtStartStr = _formatIcsDateTime(sessionDate, startH, startM);
      final dtEndStr = _formatIcsDateTime(sessionDate, endH, endM);
      final uid = 'routine_${session.day}_${session.startTime}_${session.courseCode}_${session.subgroup}_$i@diuroutine.com';

      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('UID:$uid');
      buffer.writeln('DTSTAMP:${_formatIcsDateTime(now, now.hour, now.minute)}');
      buffer.writeln('DTSTART:$dtStartStr');
      buffer.writeln('DTEND:$dtEndStr');
      buffer.writeln('RRULE:FREQ=WEEKLY;BYDAY=$icsDay;UNTIL=20271231T235959Z');
      buffer.writeln('SUMMARY:[${session.type.toUpperCase()}] ${session.courseCode}: ${session.courseTitle}');
      buffer.writeln('LOCATION:${session.room}');
      buffer.writeln(
        'DESCRIPTION:Course: ${session.courseTitle}\\nCode: ${session.courseCode}\\nFaculty: ${session.facultyInitial ?? "TBD"}\\nRoom: ${session.room}\\nType: ${session.type.toUpperCase()}\\nGroup: ${session.subgroup}',
      );
      buffer.writeln('STATUS:CONFIRMED');
      buffer.writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  static int _weekdayToInt(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
      default:
        return DateTime.sunday;
    }
  }

  static String _formatIcsDateTime(DateTime date, int hour, int minute) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    return '$y$m${d}T$h${min}00';
  }

  /// Downloads text content as a file
  static void downloadFile(String content, String fileName, String mimeType) {
    downloadWebFile(content, fileName, mimeType);
  }
}

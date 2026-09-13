import 'package:flutter_test/flutter_test.dart';
import 'package:swe_routine/models/routine_model.dart';
import 'package:swe_routine/data/sample_routine_data.dart';
import 'package:swe_routine/services/calendar_export_service.dart';

void main() {
  group('RoutineModel & ClassSession tests', () {
    test('Sample routine has correct metadata and session count', () {
      final routine = SampleRoutineData.getSampleRoutine();

      expect(routine.metadata.batch, equals('42'));
      expect(routine.metadata.section, equals('D'));
      expect(routine.metadata.department, equals('Department of Software Engineering'));
      expect(routine.metadata.effectiveDate, equals('12 September 2026'));
      expect(routine.totalSessions, equals(14));
      expect(routine.totalLabs, equals(8));
      expect(routine.totalTheories, equals(6));
      expect(routine.availableSubgroups, equals(['D1', 'D2']));
    });

    test('Section A routine dynamically yields A1 and A2 subgroups and filters correctly', () {
      // Simulate raw extraction where metadata is Section A and raw items have group 1, group 2, or D1/A1
      final rawJson = {
        'metadata': {
          'batch': '44',
          'section': 'A',
          'department': 'Department of Software Engineering',
          'effectiveDate': '12 September 2026',
        },
        'schedule': [
          {
            'day': 'Sunday',
            'startTime': '10:00',
            'endTime': '11:30',
            'courseTitle': 'Operating System & System Programming',
            'courseCode': 'SE232',
            'facultyInitial': 'IS',
            'room': 'Annex-106',
            'type': 'theory',
            'subgroup': 'ALL',
          },
          {
            'day': 'Tuesday',
            'startTime': '08:30',
            'endTime': '10:00',
            'courseTitle': 'System Analysis & Design',
            'courseCode': 'SE231',
            'facultyInitial': 'DKS',
            'room': '903',
            'type': 'lab',
            'subgroup': 'D1', // Model output from previous prompt or raw
          },
          {
            'day': 'Monday',
            'startTime': '10:00',
            'endTime': '11:30',
            'courseTitle': 'System Analysis & Design',
            'courseCode': 'SE231',
            'facultyInitial': 'DKS',
            'room': 'ONLINE',
            'type': 'lab',
            'subgroup': 'A2',
          },
        ],
      };

      final routineA = RoutineModel.fromJson(rawJson);

      expect(routineA.metadata.section, equals('A'));
      expect(routineA.metadata.batch, equals('44'));
      // Subgroups should automatically be normalized to A1 and A2 based on Section A!
      expect(routineA.availableSubgroups, contains('A1'));
      expect(routineA.availableSubgroups, contains('A2'));

      // Filter by A1: should return the theory class + A1 lab
      final a1Sessions = routineA.getFilteredSchedule(subgroupFilter: 'A1');
      expect(a1Sessions.length, equals(2));

      // Filter by A2: should return the theory class + A2 lab
      final a2Sessions = routineA.getFilteredSchedule(subgroupFilter: 'A2');
      expect(a2Sessions.length, equals(2));
    });

    test('Subgroup filtering works accurately', () {
      final routine = SampleRoutineData.getSampleRoutine();

      // ALL should return 14
      final allSessions = routine.getFilteredSchedule(subgroupFilter: 'ALL');
      expect(allSessions.length, equals(14));

      // D1 filter should return all ALL theory (6) + D1 labs (4) = 10
      final d1Sessions = routine.getFilteredSchedule(subgroupFilter: 'D1');
      expect(d1Sessions.length, equals(10));
      for (final s in d1Sessions) {
        expect(s.subgroup == 'D1' || s.subgroup == 'ALL', isTrue);
      }

      // D2 filter should return all ALL theory (6) + D2 labs (4) = 10
      final d2Sessions = routine.getFilteredSchedule(subgroupFilter: 'D2');
      expect(d2Sessions.length, equals(10));
      for (final s in d2Sessions) {
        expect(s.subgroup == 'D2' || s.subgroup == 'ALL', isTrue);
      }

      // THEORY filter should return 6
      final theorySessions = routine.getFilteredSchedule(subgroupFilter: 'THEORY');
      expect(theorySessions.length, equals(6));

      // LAB filter should return 8
      final labSessions = routine.getFilteredSchedule(subgroupFilter: 'LAB');
      expect(labSessions.length, equals(8));
    });

    test('Search filter works for course code, title, and faculty', () {
      final routine = SampleRoutineData.getSampleRoutine();

      final se331Sessions = routine.getFilteredSchedule(search: 'SE331');
      expect(se331Sessions.length, equals(6)); // Software Engineering classes

      final ssaSessions = routine.getFilteredSchedule(search: 'SSA');
      expect(ssaSessions.length, equals(6)); // Faculty SSA

      final onlineSessions = routine.getFilteredSchedule(search: 'ONLINE');
      expect(onlineSessions.length, equals(2)); // Sunday online sessions
    });

    test('JSON serialization & deserialization adheres to schema', () {
      final original = SampleRoutineData.getSampleRoutine();
      final jsonMap = original.toJson();

      expect(jsonMap.containsKey('metadata'), isTrue);
      expect(jsonMap.containsKey('schedule'), isTrue);

      final decoded = RoutineModel.fromJson(jsonMap);
      expect(decoded.metadata.section, equals('D'));
      expect(decoded.schedule.length, equals(14));
      expect(decoded.schedule.first.courseCode, equals(original.schedule.first.courseCode));
    });

    test('Calendar export generates valid VCALENDAR with VEVENT items', () {
      final routine = SampleRoutineData.getSampleRoutine();
      final ics = CalendarExportService.generateICalendar(routine, subgroupFilter: 'D1');

      expect(ics.contains('BEGIN:VCALENDAR'), isTrue);
      expect(ics.contains('END:VCALENDAR'), isTrue);
      expect(ics.contains('BEGIN:VEVENT'), isTrue);
      expect(ics.contains('RRULE:FREQ=WEEKLY'), isTrue);
      expect(ics.contains('SE331'), isTrue);
    });
  });
}

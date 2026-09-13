import '../models/routine_model.dart';
import '../models/class_session.dart';

class SampleRoutineData {
  static RoutineModel getSampleRoutine() {
    return RoutineModel(
      metadata: RoutineMetadata(
        batch: '42',
        section: 'D',
        department: 'Department of Software Engineering',
        effectiveDate: '12 September 2026',
      ),
      schedule: [
        // Sunday
        ClassSession(
          day: 'Sunday',
          startTime: '10:00',
          endTime: '11:30',
          courseTitle: 'Software Engineering',
          courseCode: 'SE331',
          facultyInitial: 'SSA',
          room: 'ONLINE',
          type: 'lab',
          subgroup: 'D1',
        ),
        ClassSession(
          day: 'Sunday',
          startTime: '11:30',
          endTime: '13:00',
          courseTitle: 'Software Engineering',
          courseCode: 'SE331',
          facultyInitial: 'SSA',
          room: 'ONLINE',
          type: 'lab',
          subgroup: 'D2',
        ),

        // Monday
        ClassSession(
          day: 'Monday',
          startTime: '13:00',
          endTime: '14:30',
          courseTitle: 'Introduction to Machine Learning',
          courseCode: 'SE544',
          facultyInitial: 'MSA',
          room: '504',
          type: 'theory',
          subgroup: 'ALL',
        ),
        ClassSession(
          day: 'Monday',
          startTime: '14:30',
          endTime: '16:00',
          courseTitle: 'Information System Security',
          courseCode: 'SE332',
          facultyInitial: 'IAT',
          room: '812',
          type: 'theory',
          subgroup: 'ALL',
        ),

        // Tuesday
        ClassSession(
          day: 'Tuesday',
          startTime: '14:30',
          endTime: '16:00',
          courseTitle: 'Introduction to Machine Learning',
          courseCode: 'SE544',
          facultyInitial: 'MSA',
          room: '504',
          type: 'theory',
          subgroup: 'ALL',
        ),
        ClassSession(
          day: 'Tuesday',
          startTime: '16:00',
          endTime: '17:30',
          courseTitle: 'Information System Security',
          courseCode: 'SE332',
          facultyInitial: 'IAT',
          room: '604',
          type: 'theory',
          subgroup: 'ALL',
        ),

        // Wednesday
        ClassSession(
          day: 'Wednesday',
          startTime: '10:00',
          endTime: '11:30',
          courseTitle: 'Artificial Intelligence',
          courseCode: 'SE334',
          facultyInitial: 'JA',
          room: '711B',
          type: 'lab',
          subgroup: 'D2',
        ),
        ClassSession(
          day: 'Wednesday',
          startTime: '11:30',
          endTime: '13:00',
          courseTitle: 'Artificial Intelligence',
          courseCode: 'SE333',
          facultyInitial: 'JA',
          room: '701B',
          type: 'theory',
          subgroup: 'ALL',
        ),
        ClassSession(
          day: 'Wednesday',
          startTime: '14:30',
          endTime: '16:00',
          courseTitle: 'Software Engineering',
          courseCode: 'SE331',
          facultyInitial: 'SSA',
          room: 'AB3-106',
          type: 'lab',
          subgroup: 'D1',
        ),
        ClassSession(
          day: 'Wednesday',
          startTime: '16:00',
          endTime: '17:30',
          courseTitle: 'Software Engineering',
          courseCode: 'SE331',
          facultyInitial: 'SSA',
          room: 'AB3-106',
          type: 'lab',
          subgroup: 'D1',
        ),

        // Thursday
        ClassSession(
          day: 'Thursday',
          startTime: '10:00',
          endTime: '11:30',
          courseTitle: 'Artificial Intelligence',
          courseCode: 'SE334',
          facultyInitial: 'JA',
          room: '814A',
          type: 'lab',
          subgroup: 'D1',
        ),
        ClassSession(
          day: 'Thursday',
          startTime: '11:30',
          endTime: '13:00',
          courseTitle: 'Artificial Intelligence',
          courseCode: 'SE333',
          facultyInitial: 'JA',
          room: '611',
          type: 'theory',
          subgroup: 'ALL',
        ),
        ClassSession(
          day: 'Thursday',
          startTime: '14:30',
          endTime: '16:00',
          courseTitle: 'Software Engineering',
          courseCode: 'SE331',
          facultyInitial: 'SSA',
          room: 'AB3-104',
          type: 'lab',
          subgroup: 'D2',
        ),
        ClassSession(
          day: 'Thursday',
          startTime: '16:00',
          endTime: '17:30',
          courseTitle: 'Software Engineering',
          courseCode: 'SE331',
          facultyInitial: 'SSA',
          room: 'AB3-104',
          type: 'lab',
          subgroup: 'D2',
        ),
      ],
    );
  }

  static const String sampleAssetPath = 'assets/sample_routine.jpg';
}

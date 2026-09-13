import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'session_card.dart';
import 'session_detail_dialog.dart';

class TimetableGridView extends StatelessWidget {
  final RoutineProvider provider;

  const TimetableGridView({super.key, required this.provider});

  // Time slots corresponding to university routine
  static const List<Map<String, dynamic>> slots = [
    {'label': '08:30 -\n10:00', 'startMin': 8 * 60 + 30, 'endMin': 10 * 60, 'startStr': '08:30', 'endStr': '10:00'},
    {'label': '10:00 -\n11:30', 'startMin': 10 * 60, 'endMin': 11 * 60 + 30, 'startStr': '10:00', 'endStr': '11:30'},
    {'label': '11:30 -\n01:00', 'startMin': 11 * 60 + 30, 'endMin': 13 * 60, 'startStr': '11:30', 'endStr': '13:00'},
    {'label': '01:00 -\n02:30', 'startMin': 13 * 60, 'endMin': 14 * 60 + 30, 'startStr': '13:00', 'endStr': '14:30'},
    {'label': '02:30 -\n04:00', 'startMin': 14 * 60 + 30, 'endMin': 16 * 60, 'startStr': '14:30', 'endStr': '16:00'},
    {'label': '04:00 -\n05:30', 'startMin': 16 * 60, 'endMin': 17 * 60 + 30, 'startStr': '16:00', 'endStr': '17:30'},
    {'label': '05:30 -\n07:00', 'startMin': 17 * 60 + 30, 'endMin': 19 * 60, 'startStr': '17:30', 'endStr': '19:00'},
  ];

  @override
  Widget build(BuildContext context) {
    final routine = provider.routine;
    if (routine == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const weekdays = RoutineModel.weekdays;
    final totalFilteredSessions = routine.getFilteredSchedule(
      subgroupFilter: provider.subgroupFilter,
      search: provider.searchQuery,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Clock + 7 Weekday columns)
                Container(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // Time Header
                      Container(
                        width: 90,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule, size: 16, color: AppTheme.primaryTeal),
                            const SizedBox(width: 4),
                            Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.grey[300] : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Day columns
                      ...weekdays.map((day) {
                        final isFriday = day.toLowerCase() == 'friday';
                        final sessionsOnDay = totalFilteredSessions.where((s) => s.day.toLowerCase() == day.toLowerCase()).length;

                        return Container(
                          width: 145,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isFriday
                                ? const Color(0xFFEF4444).withAlpha(isDark ? 40 : 25)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0).withAlpha(120)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isFriday
                                  ? const Color(0xFFEF4444).withAlpha(100)
                                  : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isFriday
                                      ? const Color(0xFFEF4444)
                                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: (sessionsOnDay > 0
                                      ? AppTheme.primaryTeal
                                      : (isDark ? Colors.grey[700] : Colors.grey[300]))!.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  sessionsOnDay == 1 ? '1 class' : '$sessionsOnDay classes',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: sessionsOnDay > 0 ? AppTheme.primaryTeal : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFCBD5E1)),

                // Time Slot Rows
                ...slots.map((slot) {
                  final slotLabel = slot['label'] as String;
                  final slotStart = slot['startMin'] as int;
                  final slotEnd = slot['endMin'] as int;
                  final startStr = slot['startStr'] as String;
                  final endStr = slot['endStr'] as String;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time slot cell on left
                        Container(
                          width: 90,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              slotLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),

                        // Day cells
                        ...weekdays.map((day) {
                          // Find classes in this day and slot
                          final daySessions = totalFilteredSessions.where((s) {
                            if (s.day.toLowerCase() != day.toLowerCase()) return false;
                            final sStart = s.startMinutes;
                            // Match if session starts within slot window (allowing 15 min tolerance)
                            return sStart >= (slotStart - 15) && sStart < (slotEnd - 10);
                          }).toList();

                          return Container(
                            width: 145,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            constraints: const BoxConstraints(minHeight: 88),
                            child: daySessions.isEmpty
                                ? _buildEmptySlotCell(
                                    context,
                                    day: day,
                                    timeSlot: '$startStr - $endStr',
                                    isFriday: day.toLowerCase() == 'friday',
                                    isDark: isDark,
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: daySessions.map((session) {
                                      return SessionCard(
                                        session: session,
                                        isCompact: daySessions.length > 1,
                                        onTap: () {
                                          SessionDetailDialog.show(
                                            context,
                                            session: session,
                                            provider: provider,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlotCell(
    BuildContext context, {
    required String day,
    required String timeSlot,
    required bool isFriday,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        SessionDetailDialog.show(
          context,
          provider: provider,
          initialDay: day,
          initialTimeSlot: timeSlot,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: isFriday
              ? (isDark ? const Color(0xFF201515) : const Color(0xFFFFF5F5))
              : (isDark ? const Color(0xFF141E2E).withAlpha(100) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF26334D) : const Color(0xFFEEF2F6),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.25,
            child: Icon(Icons.add, size: 16, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}

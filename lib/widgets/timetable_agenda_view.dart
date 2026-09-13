import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'session_card.dart';
import 'session_detail_dialog.dart';

class TimetableAgendaView extends StatelessWidget {
  final RoutineProvider provider;

  const TimetableAgendaView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final routine = provider.routine;
    if (routine == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const weekdays = RoutineModel.weekdays;

    // Day filter buttons at top
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: const Text('All Days'),
                    selected: provider.selectedDay == null,
                    onSelected: (selected) {
                      if (selected) provider.setSelectedDay(null);
                    },
                    selectedColor: AppTheme.primaryTeal,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: provider.selectedDay == null ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                    ),
                  ),
                ),
                ...weekdays.map((day) {
                  final isSelected = provider.selectedDay == day;
                  final count = routine.getSessionsForDay(
                    day,
                    subgroupFilter: provider.subgroupFilter,
                    search: provider.searchQuery,
                  ).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('$day ($count)'),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setSelectedDay(selected ? day : null);
                      },
                      selectedColor: AppTheme.primaryTeal,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Days cards
          ...weekdays.map((day) {
            if (provider.selectedDay != null && provider.selectedDay != day) {
              return const SizedBox.shrink();
            }

            final daySessions = routine.getSessionsForDay(
              day,
              subgroupFilter: provider.subgroupFilter,
              search: provider.searchQuery,
            );

            if (daySessions.isEmpty && provider.selectedDay == null) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${daySessions.length} classes',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Session List for Day
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: daySessions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Icon(Icons.weekend_outlined, size: 32, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No classes scheduled for $day',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: daySessions.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (ctx, idx) {
                              final s = daySessions[idx];
                              return SessionCard(
                                session: s,
                                onTap: () {
                                  SessionDetailDialog.show(context, session: s, provider: provider);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

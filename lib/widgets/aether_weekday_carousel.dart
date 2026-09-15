import 'package:flutter/material.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';

class AetherWeekdayCarousel extends StatelessWidget {
  final RoutineProvider provider;

  const AetherWeekdayCarousel({super.key, required this.provider});

  static const List<Map<String, String>> daysConfig = [
    {'day': 'Saturday', 'short': 'SAT', 'date': '18'},
    {'day': 'Sunday', 'short': 'SUN', 'date': '19'},
    {'day': 'Monday', 'short': 'MON', 'date': '20'},
    {'day': 'Tuesday', 'short': 'TUE', 'date': '21'},
    {'day': 'Wednesday', 'short': 'WED', 'date': '22'},
    {'day': 'Thursday', 'short': 'THU', 'date': '23'},
    {'day': 'Friday', 'short': 'FRI', 'date': '24'},
  ];

  @override
  Widget build(BuildContext context) {
    final routine = provider.routine;
    final selectedDay = provider.selectedDay;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Active Cycle telemetry
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondaryContainer,
                        boxShadow: [
                          BoxShadow(color: AppTheme.secondaryContainer, blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ACTIVE CYCLE • ACADEMIC WEEK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => provider.setSelectedDay(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: selectedDay == null
                          ? AppTheme.primary.withAlpha(40)
                          : AppTheme.surfaceContainer.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedDay == null
                            ? AppTheme.primary.withAlpha(150)
                            : AppTheme.outlineVariant.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      selectedDay == null ? 'VIEW ALL DAYS' : 'SHOW ALL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: selectedDay == null ? AppTheme.primary : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Horizontal Carousel Track
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: daysConfig.map((item) {
                final dayName = item['day']!;
                final shortName = item['short']!;
                final dateNum = item['date']!;
                final isSelected = selectedDay != null && selectedDay.toLowerCase() == dayName.toLowerCase();
                final isFriday = dayName.toLowerCase() == 'friday';

                // Check sessions on this day
                int theoryCount = 0;
                int labCount = 0;
                if (routine != null) {
                  final sessions = routine.getFilteredSchedule(
                    day: dayName,
                    subgroupFilter: provider.subgroupFilter,
                  );
                  for (final s in sessions) {
                    if (s.isLab) {
                      labCount++;
                    } else {
                      theoryCount++;
                    }
                  }
                }
                final hasClasses = (theoryCount + labCount) > 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        provider.setSelectedDay(null); // toggle off
                      } else {
                        provider.setSelectedDay(dayName);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppTheme.primaryContainer.withAlpha(60),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primary.withAlpha(200),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryContainer.withAlpha(120),
                                  blurRadius: 20,
                                  spreadRadius: -2,
                                ),
                              ],
                            )
                          : isFriday
                              ? BoxDecoration(
                                  color: AppTheme.tertiaryContainer.withAlpha(30),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppTheme.tertiary.withAlpha(80),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.tertiaryContainer.withAlpha(40),
                                      blurRadius: 14,
                                    ),
                                  ],
                                )
                              : BoxDecoration(
                                  color: AppTheme.surfaceContainerLow.withAlpha(150),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppTheme.outlineVariant.withAlpha(50),
                                    width: 1,
                                  ),
                                ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Top Glow Bar if selected
                          if (isSelected)
                            Positioned(
                              top: -10,
                              child: Container(
                                width: 24,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: const [
                                    BoxShadow(color: AppTheme.primary, blurRadius: 6),
                                  ],
                                ),
                              ),
                            ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                shortName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.primaryFixed
                                      : (isFriday ? AppTheme.tertiary : AppTheme.onSurfaceVariant),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateNum,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                  color: isSelected
                                      ? AppTheme.onSurface
                                      : (isFriday ? AppTheme.tertiary : AppTheme.onSurface),
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Dot telemetry
                              if (isFriday && !hasClasses)
                                const Text(
                                  'OFF',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.tertiary,
                                    letterSpacing: 0.5,
                                  ),
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (theoryCount > 0)
                                      Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.secondaryContainer,
                                          boxShadow: [
                                            BoxShadow(color: AppTheme.secondaryContainer, blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                    if (labCount > 0)
                                      Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.tertiary,
                                          boxShadow: [
                                            BoxShadow(color: AppTheme.tertiary, blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                    if (theoryCount == 0 && labCount == 0)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.outlineVariant.withAlpha(120),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'session_detail_dialog.dart';

class AetherMatrixScreen extends StatelessWidget {
  final RoutineProvider provider;

  const AetherMatrixScreen({super.key, required this.provider});

  static const List<Map<String, dynamic>> slots = [
    {'label': '08:30', 'startMin': 8 * 60 + 30, 'endMin': 10 * 60, 'str': '08:30'},
    {'label': '10:00', 'startMin': 10 * 60, 'endMin': 11 * 60 + 30, 'str': '10:00'},
    {'label': '11:30', 'startMin': 11 * 60 + 30, 'endMin': 13 * 60, 'str': '11:30'},
    {'label': '13:00', 'startMin': 13 * 60, 'endMin': 14 * 60 + 30, 'str': '13:00', 'isBreak': true},
    {'label': '14:30', 'startMin': 14 * 60 + 30, 'endMin': 16 * 60, 'str': '14:30'},
    {'label': '16:00', 'startMin': 16 * 60, 'endMin': 17 * 60 + 30, 'str': '16:00'},
    {'label': '17:30', 'startMin': 17 * 60 + 30, 'endMin': 19 * 60, 'str': '17:30'},
  ];

  static const List<Map<String, String>> weekdays = [
    {'name': 'Saturday', 'short': 'SAT'},
    {'name': 'Sunday', 'short': 'SUN'},
    {'name': 'Monday', 'short': 'MON'},
    {'name': 'Tuesday', 'short': 'TUE'},
    {'name': 'Wednesday', 'short': 'WED'},
    {'name': 'Thursday', 'short': 'THU'},
    {'name': 'Friday', 'short': 'FRI'},
  ];

  @override
  Widget build(BuildContext context) {
    final routine = provider.routine;
    final metadata = routine?.metadata;
    final availableGroups = routine?.availableSubgroups ?? ['A1', 'A2'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cohort Granularity Scope Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.groups_3_outlined, size: 18, color: AppTheme.secondaryFixed),
                    SizedBox(width: 8),
                    Text(
                      'ACTIVE COHORT SCOPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh.withAlpha(180),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 6),
                      Text(
                        'DIU CSE ${metadata?.semester ?? "Fall"} ${metadata?.year ?? 2026}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liquid Glass Segmented Cohort Cards
          Column(
            children: [
              ...availableGroups.map((group) {
                final isSelected = provider.isFilterActive(group);
                final nodeCount = routine?.getFilteredSchedule(subgroupFilter: group).length ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCohortCard(
                    context: context,
                    isSelected: isSelected,
                    title: 'Personal Schedule (Group $group)',
                    subtitle: 'Synchronized with enrolled syllabus & labs',
                    nodes: '$nodeCount Nodes',
                    onTap: () => provider.setSubgroupFilter(group),
                  ),
                );
              }),

              // ALL Master Section Card
              _buildCohortCard(
                context: context,
                isSelected: provider.subgroupFilter == 'ALL',
                title: 'Whole Section Master Routine (ALL)',
                subtitle: 'Complete merged lecture overlaps and lab sections',
                nodes: '${routine?.schedule.length ?? 0} Nodes',
                onTap: () => provider.setSubgroupFilter('ALL'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Weekly Matrix Grid Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_view_week, size: 20, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Weekly Matrix Grid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                // Legend
                Row(
                  children: [
                    _buildLegendItem('Theory', AppTheme.secondaryContainer),
                    const SizedBox(width: 8),
                    _buildLegendItem('Lab', AppTheme.tertiary),
                    const SizedBox(width: 8),
                    _buildLegendItem('Tut', AppTheme.primary),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Specular Frosted Grid Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest.withAlpha(200),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(160),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Axis Header
                    Row(
                      children: [
                        Container(
                          width: 70,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'Day/Slot',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ...slots.map((slot) {
                          final isBreak = slot['isBreak'] == true;
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: isBreak
                                ? BoxDecoration(
                                    color: AppTheme.surfaceContainerLow.withAlpha(100),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Text(
                              slot['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isBreak ? AppTheme.outline : AppTheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Weekday Rows
                    ...weekdays.map((wd) {
                      final dayName = wd['name']!;
                      final shortName = wd['short']!;
                      final isFriday = dayName.toLowerCase() == 'friday';

                      final daySessions = routine?.getFilteredSchedule(
                            day: dayName,
                            subgroupFilter: provider.subgroupFilter,
                          ) ??
                          [];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // Day Label Box
                            Container(
                              width: 70,
                              height: 68,
                              decoration: BoxDecoration(
                                color: isFriday
                                    ? AppTheme.tertiaryContainer.withAlpha(30)
                                    : AppTheme.surfaceContainerHigh.withAlpha(140),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isFriday
                                      ? AppTheme.tertiary.withAlpha(80)
                                      : AppTheme.outlineVariant.withAlpha(40),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                shortName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isFriday ? AppTheme.tertiary : AppTheme.onSurface,
                                ),
                              ),
                            ),

                            // Slots
                            ...slots.map((slot) {
                              final startMin = slot['startMin'] as int;
                              final endMin = slot['endMin'] as int;
                              final isBreak = slot['isBreak'] == true;

                              if (isBreak) {
                                return Container(
                                  width: 100,
                                  height: 68,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerLowest.withAlpha(120),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'LUNCH',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                      color: AppTheme.outline,
                                    ),
                                  ),
                                );
                              }

                              // Find sessions matching this slot
                              final matches = daySessions.where((s) {
                                return (s.startMinutes >= startMin - 15 && s.startMinutes < endMin - 15);
                              }).toList();

                              if (matches.isEmpty) {
                                return Container(
                                  width: 100,
                                  height: 68,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerLow.withAlpha(80),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.outlineVariant.withAlpha(80),
                                    ),
                                  ),
                                );
                              }

                              final session = matches.first;
                              final isLab = session.isLab;
                              final accentColor = isLab ? AppTheme.tertiary : AppTheme.secondaryContainer;

                              return GestureDetector(
                                onTap: () => SessionDetailDialog.show(context, session: session, provider: provider),
                                child: Container(
                                  width: 100,
                                  height: 68,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerHigh.withAlpha(200),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: accentColor.withAlpha(100),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withAlpha(30),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        session.courseCode,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: accentColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        session.courseTitle,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            session.roomNo.isNotEmpty ? session.roomNo : 'ONLINE',
                                            style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.onSurface,
                                            ),
                                          ),
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
        ],
      ),
    );
  }

  Widget _buildCohortCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required String nodes,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.surfaceContainerHigh.withAlpha(220)
              : AppTheme.surfaceContainerLow.withAlpha(120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.secondaryContainer.withAlpha(180)
                : AppTheme.outlineVariant.withAlpha(50),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.secondaryContainer.withAlpha(40),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.secondaryContainer.withAlpha(40)
                    : AppTheme.surfaceContainerHighest.withAlpha(100),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.secondaryContainer : AppTheme.outlineVariant,
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(color: AppTheme.secondaryContainer, blurRadius: 8),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest.withAlpha(180),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nodes,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.secondaryFixed : AppTheme.onSurfaceVariant,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, size: 12, color: AppTheme.secondaryFixed),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

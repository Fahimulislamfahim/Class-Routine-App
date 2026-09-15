import 'dart:async';
import 'package:flutter/material.dart';
import '../models/class_session.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'session_detail_dialog.dart';

class AetherLiveHeroCapsule extends StatefulWidget {
  final RoutineProvider provider;

  const AetherLiveHeroCapsule({super.key, required this.provider});

  @override
  State<AetherLiveHeroCapsule> createState() => _AetherLiveHeroCapsuleState();
}

class _AetherLiveHeroCapsuleState extends State<AetherLiveHeroCapsule> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pingController;
  late Animation<double> _pingAnimation;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pingAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pingController, curve: Curves.easeInOut),
    );

    // Update every second for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pingController.dispose();
    super.dispose();
  }

  ClassSession? _resolveActiveOrFeaturedSession() {
    final routine = widget.provider.routine;
    if (routine == null) return null;

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final weekdayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayName = weekdayNames[now.weekday - 1];

    final activeDay = widget.provider.selectedDay ?? todayName;

    final sessions = routine.getFilteredSchedule(
      day: activeDay,
      subgroupFilter: widget.provider.subgroupFilter,
    );

    if (sessions.isEmpty) {
      // Fallback to any day's first session
      final allFiltered = routine.getFilteredSchedule(
        subgroupFilter: widget.provider.subgroupFilter,
      );
      return allFiltered.isNotEmpty ? allFiltered.first : null;
    }

    // Try finding currently ongoing session
    for (final s in sessions) {
      if (nowMinutes >= s.startMinutes && nowMinutes <= s.endMinutes) {
        return s;
      }
    }

    // Try finding next upcoming session today
    for (final s in sessions) {
      if (s.startMinutes > nowMinutes) {
        return s;
      }
    }

    // Otherwise return the first session of the day
    return sessions.first;
  }

  @override
  Widget build(BuildContext context) {
    final session = _resolveActiveOrFeaturedSession();
    if (session == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final isLive = nowMinutes >= session.startMinutes && nowMinutes <= session.endMinutes;
    final isLab = session.isLab;

    final accentColor = isLab ? AppTheme.tertiary : AppTheme.secondaryContainer;
    final glowColor = isLab ? AppTheme.tertiaryContainer : AppTheme.secondaryFixedDim;

    // Calculate elapsed percentage
    double elapsedPercent;
    String countdownText;
    if (isLive) {
      final total = (session.endMinutes - session.startMinutes).clamp(1, 400);
      final elapsed = (nowMinutes - session.startMinutes).clamp(0, total);
      elapsedPercent = (elapsed / total).clamp(0.05, 0.95);
      final remainingMins = session.endMinutes - nowMinutes;
      final remainingSecs = 60 - now.second;
      countdownText = '${remainingMins}m ${remainingSecs < 10 ? '0' : ''}${remainingSecs}s remaining';
    } else if (nowMinutes < session.startMinutes) {
      final waitMins = session.startMinutes - nowMinutes;
      elapsedPercent = 0.08;
      countdownText = 'Starts in $waitMins min';
    } else {
      elapsedPercent = 1.0;
      countdownText = 'Session Completed';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Prismatic Ambient Underglow Orbs
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withAlpha(45),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(35),
              ),
            ),
          ),

          // Main Glass Card
          InkWell(
            onTap: () => SessionDetailDialog.show(context, session: session, provider: widget.provider),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow.withAlpha(210),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accentColor.withAlpha(80),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withAlpha(50),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(160),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Live Status Badge + Countdown Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pingAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor.withAlpha((_pingAnimation.value * 255).round()),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withAlpha((_pingAnimation.value * 180).round()),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLive
                                ? (isLab ? 'NOW LIVE • LAB BLOCK' : 'NOW LIVE • THEORY')
                                : (isLab ? 'SCHEDULED • LAB BLOCK' : 'SCHEDULED • THEORY'),
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest.withAlpha(200),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.outlineVariant.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 13, color: accentColor),
                            const SizedBox(width: 5),
                            Text(
                              countdownText,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Row 2: Course Name & Room Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${session.courseCode} ${session.courseTitle}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 15,
                                  color: AppTheme.tertiary.withAlpha(220),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${session.teacherName.isNotEmpty ? session.teacherName : "Faculty"} • Section ${session.subgroup}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: accentColor.withAlpha(160)),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withAlpha(60),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Text(
                              session.roomNo.isNotEmpty ? session.roomNo : 'ONLINE',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Smart Desk 04',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Row 3: Scrubber Track & Elapsed Percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${session.timeSlot} • ${session.day}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isLive
                                ? '${(elapsedPercent * 100).toInt()}% Session Done'
                                : (nowMinutes < session.startMinutes ? 'Upcoming' : '100% Completed'),
                            style: TextStyle(
                              fontSize: 11,
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 7,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHighest.withAlpha(120),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: elapsedPercent,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  accentColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withAlpha(160),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Row 4: Quick Action Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickChip(
                          icon: Icons.screen_share_outlined,
                          label: 'Class Stream',
                          color: AppTheme.secondaryContainer,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Class stream feed opened')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickChip(
                          icon: Icons.assignment_turned_in_outlined,
                          label: 'Lab Notes / Sheet',
                          color: AppTheme.primary,
                          onTap: () {
                            SessionDetailDialog.show(context, session: session, provider: widget.provider);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickChip(
                          icon: Icons.forum_outlined,
                          label: 'Desk Mesh',
                          color: AppTheme.tertiary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Connecting to Section Desk Mesh...')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer.withAlpha(180),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outlineVariant.withAlpha(70)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/class_session.dart';
import '../theme/app_theme.dart';

class SessionCard extends StatefulWidget {
  final ClassSession session;
  final VoidCallback? onTap;
  final bool isCompact;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.isCompact = false,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final isLab = session.isLab;
    final isRemote = session.isOnline;

    // Color coordination based on Stitch AetherSchedule tokens:
    // Lab: Tertiary (Laser Rose / Magenta #FBABFF)
    // Theory: Secondary Container (Electric Cyan #00F2D1)
    // Hybrid/Tutorial: Primary (Holographic Indigo #C0C1FF)
    final Color accentColor = isLab
        ? AppTheme.tertiary
        : (isRemote ? AppTheme.primary : AppTheme.secondaryContainer);

    final Color glowColor = isLab
        ? AppTheme.tertiaryContainer
        : (isRemote ? AppTheme.primaryContainer : AppTheme.secondaryFixedDim);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withAlpha(_isHovered ? 230 : 190),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? accentColor.withAlpha(160)
                  : (isLab ? AppTheme.tertiaryContainer.withAlpha(70) : AppTheme.outlineVariant.withAlpha(50)),
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? glowColor.withAlpha(70) : glowColor.withAlpha(20),
                blurRadius: _isHovered ? 24 : 14,
                spreadRadius: _isHovered ? 0 : -2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(140),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Specular Vertical Neon Accent Bar
              Positioned(
                left: 0,
                top: 14,
                bottom: 14,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(220),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: EdgeInsets.fromLTRB(widget.isCompact ? 16 : 20, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Time, Type Chip, Subgroup, Room Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              session.timeSlot,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: widget.isCompact ? 11 : 13,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(35),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accentColor.withAlpha(90), width: 0.8),
                              ),
                              child: Text(
                                isLab ? 'Lab Block' : (isRemote ? 'Hybrid / Remote' : 'Theory'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            if (session.subgroup != 'ALL') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerHighest.withAlpha(150),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Group ${session.subgroup}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Room badge pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHigh.withAlpha(220),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: accentColor.withAlpha(80)),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withAlpha(40),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLab ? Icons.desktop_windows_outlined : Icons.meeting_room_outlined,
                                size: 12,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.roomNo.isNotEmpty ? session.roomNo : 'ONLINE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Row 2: Course Title + Code
                    Text(
                      '${session.courseCode}: ${session.courseTitle}',
                      style: TextStyle(
                        fontSize: widget.isCompact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Row 3: Instructor info
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withAlpha(35),
                          ),
                          child: Icon(
                            isLab ? Icons.psychology_outlined : Icons.school_outlined,
                            size: 13,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            session.teacherName.isNotEmpty ? session.teacherName : 'Faculty Member',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Optional Lab HUD sub-strip if lab session
                    if (isLab && !widget.isCompact) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest.withAlpha(160),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outlineVariant.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.terminal, size: 14, color: AppTheme.secondaryContainer),
                                const SizedBox(width: 6),
                                Text(
                                  'Hands-on Lab Task / Code',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface.withAlpha(220),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryContainer.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Inspect',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (!widget.isCompact) ...[
                      const SizedBox(height: 10),
                      // Meta footer row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.outlineVariant,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                session.day,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Tap for details',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios, size: 10, color: accentColor),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

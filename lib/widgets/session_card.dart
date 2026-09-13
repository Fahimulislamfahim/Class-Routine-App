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

  Color _getSubgroupColor(String group) {
    switch (group.toUpperCase()) {
      case 'D1':
        return AppTheme.groupD1Color;
      case 'D2':
        return AppTheme.groupD2Color;
      case 'ALL':
      default:
        return AppTheme.groupAllColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = session.courseColor;
    final groupColor = _getSubgroupColor(session.subgroup);
    final isLab = session.isLab;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
          padding: EdgeInsets.all(widget.isCompact ? 8 : 10),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered ? const Color(0xFF26334D) : const Color(0xFF1E293B))
                : (_isHovered ? Colors.white : const Color(0xFFFBFDFF)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? baseColor.withAlpha(200)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: baseColor.withAlpha(35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Code + Subgroup + Type Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: baseColor.withAlpha(isDark ? 50 : 30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: baseColor.withAlpha(120), width: 0.8),
                    ),
                    child: Text(
                      session.courseCode,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? baseColor.withAlpha(240) : baseColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Group Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: groupColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      session.subgroup,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: groupColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Lab / Theory Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isLab ? AppTheme.labTagColor : AppTheme.theoryTagColor).withAlpha(25),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      isLab ? 'LAB' : 'THEORY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isLab ? AppTheme.labTagColor : AppTheme.theoryTagColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Course Title
              Text(
                session.courseTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.isCompact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Row: Faculty & Room & Time
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Faculty chip
                  if (session.facultyInitial != null && session.facultyInitial!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, size: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            session.facultyInitial!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Room chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: session.room.toUpperCase() == 'ONLINE'
                          ? Colors.purple.withAlpha(30)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          session.room.toUpperCase() == 'ONLINE' ? Icons.videocam : Icons.location_on,
                          size: 11,
                          color: session.room.toUpperCase() == 'ONLINE'
                              ? Colors.purpleAccent
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          session.room,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: session.room.toUpperCase() == 'ONLINE'
                                ? Colors.purple
                                : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time chip
                  Text(
                    session.formattedTimeRange,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

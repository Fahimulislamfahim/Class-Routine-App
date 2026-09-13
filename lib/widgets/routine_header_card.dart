import 'package:flutter/material.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'session_detail_dialog.dart';

class RoutineHeaderCard extends StatelessWidget {
  final RoutineProvider provider;

  const RoutineHeaderCard({super.key, required this.provider});

  void _showOriginalImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 750),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: provider.routineImageBytes != null
                      ? Image.memory(provider.routineImageBytes!, fit: BoxFit.contain)
                      : Image.asset('assets/sample_routine.jpg', fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routine = provider.routine;
    if (routine == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final metadata = routine.metadata;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F2A30), const Color(0xFF1E293B)]
              : [const Color(0xFFE6FFFA), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.primaryTeal.withAlpha(60) : AppTheme.primaryTeal.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: University Department & Meta Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withAlpha(80),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),

              // Title and Department
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.department,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(
                          context,
                          icon: Icons.grid_view_rounded,
                          label: 'Section: ${metadata.section}',
                          color: AppTheme.primaryTeal,
                        ),
                        _buildBadge(
                          context,
                          icon: Icons.layers_outlined,
                          label: 'Batch: ${metadata.batch}',
                          color: AppTheme.accentCyan,
                        ),
                        if (metadata.effectiveDate.isNotEmpty)
                          _buildBadge(
                            context,
                            icon: Icons.calendar_today_outlined,
                            label: 'Effective: ${metadata.effectiveDate}',
                            color: const Color(0xFF8B5CF6),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons for Image inspection and Adding session
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showOriginalImage(context),
                    icon: const Icon(Icons.image_search, size: 16),
                    label: const Text('Compare Image'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: const BorderSide(color: AppTheme.primaryTeal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      SessionDetailDialog.show(context, provider: provider);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Class'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Row 2: Statistics & Export Actions
          Row(
            children: [
              // Stats
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildStatItem(context, 'Total Sessions', '${routine.totalSessions}', Icons.event_note),
                    _buildStatItem(context, 'Theory Classes', '${routine.totalTheories}', Icons.menu_book),
                    _buildStatItem(context, 'Lab Classes', '${routine.totalLabs}', Icons.biotech),
                    _buildStatItem(context, 'Faculty Members', '${routine.uniqueFaculty.length}', Icons.groups),
                  ],
                ),
              ),

              // Export options
              PopupMenuButton<String>(
                tooltip: 'Export Routine',
                onSelected: (val) {
                  if (val == 'ics') {
                    provider.exportICalendar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading iCalendar (.ics) schedule...')),
                    );
                  } else if (val == 'json') {
                    provider.exportJson();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading routine JSON...')),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'ics',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, color: AppTheme.primaryTeal, size: 18),
                        SizedBox(width: 8),
                        Text('Export to Google/Apple Calendar (.ics)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'json',
                    child: Row(
                      children: [
                        Icon(Icons.code, color: Colors.blueAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Export Structured JSON (.json)'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_download_outlined, size: 16, color: isDark ? Colors.white : Colors.black87),
                      const SizedBox(width: 6),
                      Text(
                        'Export',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 16, color: isDark ? Colors.white : Colors.black87),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryTeal),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

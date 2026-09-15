import 'package:flutter/material.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'api_key_dialog.dart';

class AetherExportScreen extends StatelessWidget {
  final RoutineProvider provider;

  const AetherExportScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final routine = provider.routine;
    final metadata = routine?.metadata;
    final sessionCount = routine?.getFilteredSchedule(subgroupFilter: provider.subgroupFilter).length ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cloud_sync, size: 20, color: AppTheme.secondaryContainer),
                    SizedBox(width: 8),
                    Text(
                      'Calendar Sync & Matrix OS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Automated iCal synchronization and multi-device timetable export for DIU ${metadata?.semester ?? "Fall"} ${metadata?.year ?? 2026}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status Capsule
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondaryContainer.withAlpha(80)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryContainer.withAlpha(30),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondaryContainer.withAlpha(30),
                      ),
                      child: const Icon(Icons.event_available, color: AppTheme.secondaryContainer, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enrolled in Group ${provider.subgroupFilter}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$sessionCount classes ready for synchronization',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Ready',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.secondaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'DIRECT CALENDAR EXPORT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 10),

          // 1. Google Calendar / Apple Calendar .ICS
          _buildExportActionCard(
            context: context,
            icon: Icons.calendar_month,
            accentColor: AppTheme.secondaryContainer,
            title: 'Export to Apple / Google Calendar (.ics)',
            description: 'Standard iCalendar feed with 15-minute smart class notifications, room tags, and teacher names.',
            buttonLabel: 'Download .ICS Feed',
            onTap: () {
              provider.exportICalendar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloaded .ics file! Open in Google Calendar or Apple Calendar.'),
                  backgroundColor: AppTheme.surfaceContainerHigh,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // 2. JSON Data Dump
          _buildExportActionCard(
            context: context,
            icon: Icons.data_object,
            accentColor: AppTheme.primary,
            title: 'Export Full Routine JSON',
            description: 'Backup raw structured schedule objects, timetable metadata, and student section configurations.',
            buttonLabel: 'Download JSON',
            onTap: () {
              provider.exportJson();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloaded JSON routine backup.'),
                  backgroundColor: AppTheme.surfaceContainerHigh,
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'AI INTELLIGENCE & CONFIGURATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 10),

          // 3. API Key & Model Settings Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withAlpha(190),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.key, color: AppTheme.tertiary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          provider.hasApiKey ? 'Gemini API Key Connected' : 'No Gemini API Key Configured',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: provider.hasApiKey ? AppTheme.secondaryFixed : AppTheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.tonal(
                      onPressed: () => ApiKeyDialog.show(context, provider),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerHigh,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        provider.hasApiKey ? 'Change Key' : 'Configure',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Active Model: ${provider.selectedModel} • Multimodal image routine OCR enabled',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportActionCard({
    required BuildContext context,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow.withAlpha(190),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withAlpha(30),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor.withAlpha(40),
                foregroundColor: accentColor,
                elevation: 0,
                side: BorderSide(color: accentColor.withAlpha(120)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, size: 16, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: accentColor,
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
}

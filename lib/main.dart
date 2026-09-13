import 'package:flutter/material.dart';
import 'providers/routine_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/api_key_dialog.dart';
import 'widgets/upload_zone.dart';
import 'widgets/routine_header_card.dart';
import 'widgets/subgroup_filter_bar.dart';
import 'widgets/timetable_grid_view.dart';
import 'widgets/timetable_agenda_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = RoutineProvider();
  await provider.init();
  runApp(ClassRoutineApp(provider: provider));
}

class ClassRoutineApp extends StatelessWidget {
  final RoutineProvider provider;

  const ClassRoutineApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'University Class Routine Vision Extractor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: RoutineHomeScreen(provider: provider),
        );
      },
    );
  }
}

class RoutineHomeScreen extends StatelessWidget {
  final RoutineProvider provider;

  const RoutineHomeScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.accentCyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'University Routine Extractor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Multimodal Gemini Vision & Timetable Grid',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Model indicator badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryTeal.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology, size: 14, color: AppTheme.primaryTeal),
                const SizedBox(width: 4),
                Text(
                  provider.selectedModel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // API Key status button
          FilledButton.tonalIcon(
            onPressed: () => ApiKeyDialog.show(context, provider),
            icon: Icon(
              provider.hasApiKey ? Icons.check_circle : Icons.key,
              size: 16,
              color: provider.hasApiKey ? Colors.green : AppTheme.coralAccent,
            ),
            label: Text(
              provider.hasApiKey ? 'API Key Set' : 'Configure API Key',
              style: TextStyle(
                fontSize: 12,
                color: provider.hasApiKey ? (isDark ? Colors.green[300] : Colors.green[800]) : AppTheme.coralAccent,
              ),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),

          // Dark/Light toggle
          IconButton(
            tooltip: provider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            onPressed: () => provider.toggleDarkMode(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            physics: const BouncingScrollPhysics(),
            children: [
              // Image Upload & Model Status Area
              UploadZone(provider: provider),

              // Routine Metadata Card
              if (provider.routine != null) ...[
                RoutineHeaderCard(provider: provider),
                SubgroupFilterBar(provider: provider),

                // Timetable Content (Grid or Agenda)
                if (provider.viewMode == 'grid')
                  TimetableGridView(provider: provider)
                else
                  TimetableAgendaView(provider: provider),
              ],

              // Footer
              const SizedBox(height: 20),
              Center(
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'Built with Flutter & Gemini Multimodal Vision • University Timetable Assistant',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

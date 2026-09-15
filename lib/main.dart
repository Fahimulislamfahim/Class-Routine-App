import 'package:flutter/material.dart';
import 'providers/routine_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/aether_live_hero_capsule.dart';
import 'widgets/aether_weekday_carousel.dart';
import 'widgets/session_card.dart';
import 'widgets/session_detail_dialog.dart';
import 'widgets/aether_vision_scanner_screen.dart';
import 'widgets/aether_matrix_screen.dart';
import 'widgets/aether_export_screen.dart';
import 'widgets/api_key_dialog.dart';

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
          title: 'AetherSchedule: AI Timetable',
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

class RoutineHomeScreen extends StatefulWidget {
  final RoutineProvider provider;

  const RoutineHomeScreen({super.key, required this.provider});

  @override
  State<RoutineHomeScreen> createState() => _RoutineHomeScreenState();
}

class _RoutineHomeScreenState extends State<RoutineHomeScreen> with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isVoiceActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerVoiceSearch() {
    setState(() => _isVoiceActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listening for "Room 106", "AI Lab", or course title...'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.surfaceContainerHigh,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isVoiceActive = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final routine = provider.routine;
    final metadata = routine?.metadata;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. Ambient Background Mesh Gradient Orbs
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryContainer.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryContainer.withAlpha(25),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.tertiaryContainer.withAlpha(20),
              ),
            ),
          ),

          // 2. Main Tab Content
          SafeArea(
            child: Column(
              children: [
                // Top Fixed iOS 26 Glass Header Bar with Dynamic Island
                _buildTopHeaderBar(context, metadata),

                // Active Tab View
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      // Tab 0: Routine (Interactive HUD)
                      _buildRoutineTab(context),

                      // Tab 1: Vision AI Scanner
                      AetherVisionScannerScreen(provider: provider),

                      // Tab 2: Weekly Matrix Grid
                      AetherMatrixScreen(provider: provider),

                      // Tab 3: Calendar Sync & Export
                      AetherExportScreen(provider: provider),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Glass Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildFloatingBottomBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Top Fixed iOS 26 Glass Header Bar
  Widget _buildTopHeaderBar(BuildContext context, dynamic metadata) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Cellular 5G Glass Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest.withAlpha(160),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.signal_cellular_alt, size: 14, color: AppTheme.secondaryContainer),
                const SizedBox(width: 4),
                const Text(
                  '5G',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondaryContainer,
                  ),
                ),
                const Icon(Icons.battery_charging_full, size: 14, color: AppTheme.secondaryFixed),
              ],
            ),
          ),

          // Center: Dynamic Island Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest.withAlpha(210),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(70)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(160),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondaryContainer,
                    boxShadow: [
                      BoxShadow(color: AppTheme.secondaryContainer, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'AI Vision Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh.withAlpha(200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    metadata != null ? 'DIU B${metadata.batch}-${metadata.section}' : 'DIU B44-A',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right: Profile & API Key trigger
          GestureDetector(
            onTap: () => ApiKeyDialog.show(context, widget.provider),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest.withAlpha(180),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.outlineVariant.withAlpha(70)),
              ),
              child: Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                  ),
                  child: const Icon(Icons.person, size: 16, color: AppTheme.onPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 0: Routine Interactive HUD
  Widget _buildRoutineTab(BuildContext context) {
    final provider = widget.provider;
    final routine = provider.routine;
    final metadata = routine?.metadata;

    final filteredSessions = routine?.getFilteredSchedule(
          day: provider.selectedDay,
          subgroupFilter: provider.subgroupFilter,
          search: provider.searchQuery,
        ) ??
        [];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // 1. HUD Ambient Aura Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh.withAlpha(140),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineVariant.withAlpha(50)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryContainer.withAlpha(40),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.secondaryFixed, size: 20),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: AppTheme.secondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Interactive HUD',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryContainer.withAlpha(35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${metadata?.semester ?? "Fall"} \'${metadata?.year.toString().substring(2) ?? "26"}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.secondaryFixed,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'DIU Smart Campus • Academic Track ${provider.subgroupFilter}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Live Mode Action Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh.withAlpha(160),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withAlpha(80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.satellite_alt, size: 14, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'HUD Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Floating Dynamic Live Class Hero Capsule
        AetherLiveHeroCapsule(provider: provider),

        // 3. Search & Voice Glass Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withAlpha(180),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: AppTheme.outline),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  style: const TextStyle(fontSize: 13, color: AppTheme.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Search courses, professors, labs...',
                    hintStyle: TextStyle(fontSize: 13, color: AppTheme.outline),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppTheme.outline),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                ),
              GestureDetector(
                onTap: _triggerVoiceSearch,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVoiceActive
                        ? AppTheme.secondaryContainer
                        : AppTheme.primary.withAlpha(35),
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 16,
                    color: _isVoiceActive ? AppTheme.onSecondary : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Weekday Glass Carousel
        AetherWeekdayCarousel(provider: provider),

        // 5. Segmented Filter Bar (Pills)
        _buildSegmentedFilterPills(provider),

        // 6. Schedule List Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.selectedDay != null ? "${provider.selectedDay}'s Schedule" : "All Scheduled Classes",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${filteredSessions.length} Classes Found',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryFixed,
                ),
              ),
            ],
          ),
        ),

        // 7. Session Cards
        if (filteredSessions.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withAlpha(120),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(40)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_busy, size: 40, color: AppTheme.outlineVariant),
                const SizedBox(height: 12),
                const Text(
                  'No classes scheduled for this filter',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Try selecting a different day or group above.',
                  style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                FilledButton.tonal(
                  onPressed: () {
                    provider.setSelectedDay(null);
                    provider.setSubgroupFilter('ALL');
                  },
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: filteredSessions.map((session) {
                return SessionCard(
                  session: session,
                  onTap: () => SessionDetailDialog.show(context, session: session, provider: provider),
                );
              }).toList(),
            ),
          ),

        // 8. Floating "+ Add Class" pill action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => SessionDetailDialog.show(context, session: null, provider: provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh.withAlpha(220),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.secondaryContainer.withAlpha(140), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryContainer.withAlpha(80),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18, color: AppTheme.secondaryFixed),
                      SizedBox(width: 8),
                      Text(
                        '+ Add Class',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Floating Segmented Filter Pills
  Widget _buildSegmentedFilterPills(RoutineProvider provider) {
    final routine = provider.routine;
    final availableGroups = routine?.availableSubgroups ?? ['A1', 'A2'];

    final pills = [
      {'key': 'ALL', 'label': 'All Classes'},
      ...availableGroups.map((g) => {'key': g, 'label': 'Group $g (Labs+Theory)'}),
      {'key': 'THEORY', 'label': 'Theory'},
      {'key': 'LAB', 'label': 'Labs'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest.withAlpha(180),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant.withAlpha(40)),
        ),
        child: Row(
          children: pills.map((p) {
            final key = p['key']!;
            final label = p['label']!;
            final isSelected = provider.isFilterActive(key);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => provider.setSubgroupFilter(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.secondaryContainer.withAlpha(120),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppTheme.onSecondary : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Floating Glass Bottom Navigation Bar with Elevated Center Scanner Button
  Widget _buildFloatingBottomBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withAlpha(220),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(200),
            blurRadius: 36,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Routine Tab
          _buildNavItem(
            index: 0,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Routine',
          ),

          // 2. Elevated Center FAB: Vision AI Scanner
          GestureDetector(
            onTap: () => setState(() => _currentTabIndex = 1),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentTabIndex == 1
                    ? AppTheme.secondaryContainer
                    : AppTheme.surfaceContainerHigh.withAlpha(230),
                border: Border.all(
                  color: AppTheme.secondaryContainer.withAlpha(_currentTabIndex == 1 ? 255 : 120),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryContainer.withAlpha(_currentTabIndex == 1 ? 160 : 70),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 24,
                color: _currentTabIndex == 1 ? AppTheme.onSecondary : AppTheme.secondaryFixed,
              ),
            ),
          ),

          // 3. Matrix Tab
          _buildNavItem(
            index: 2,
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view,
            label: 'Matrix',
          ),

          // 4. Export Tab
          _buildNavItem(
            index: 3,
            icon: Icons.cloud_sync_outlined,
            activeIcon: Icons.cloud_sync,
            label: 'Export',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppTheme.secondaryContainer.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryContainer.withAlpha(100)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryContainer.withAlpha(60),
                    blurRadius: 12,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? AppTheme.secondaryFixed : AppTheme.outline,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.secondaryFixed : AppTheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';

class SubgroupFilterBar extends StatelessWidget {
  final RoutineProvider provider;

  const SubgroupFilterBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final routine = provider.routine;

    // Dynamically retrieve subgroups from the active routine (e.g. ['A1', 'A2'] or ['D1', 'D2'])
    final availableGroups = routine?.availableSubgroups ?? ['A1', 'A2'];

    final filterOptions = <Map<String, dynamic>>[
      {'key': 'ALL', 'label': 'All Classes', 'icon': Icons.tune},
      ...availableGroups.map((group) {
        return {
          'key': group,
          'label': 'Group $group (Labs + Theory)',
          'icon': Icons.group,
        };
      }),
      {'key': 'THEORY', 'label': 'Theory Only', 'icon': Icons.menu_book},
      {'key': 'LAB', 'label': 'Labs Only', 'icon': Icons.biotech},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
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
          // Filter Chips Row + View Mode Toggle
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((opt) {
                      final key = opt['key'] as String;
                      // Match either exact key, or if filter suffix matches (e.g. 'D1' matches 'A1' on routine change)
                      final isSelected = provider.isFilterActive(key);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Icon(
                            opt['icon'] as IconData,
                            size: 14,
                            color: isSelected ? Colors.white : AppTheme.primaryTeal,
                          ),
                          label: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => provider.setSubgroupFilter(key),
                          selectedColor: AppTheme.primaryTeal,
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryTeal
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // View Mode Segmented Switch
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Weekly Grid View',
                      icon: Icon(
                        Icons.grid_on_rounded,
                        size: 18,
                        color: provider.viewMode == 'grid'
                            ? AppTheme.primaryTeal
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
                      ),
                      onPressed: () => provider.setViewMode('grid'),
                    ),
                    IconButton(
                      tooltip: 'Daily Agenda View',
                      icon: Icon(
                        Icons.view_agenda_rounded,
                        size: 18,
                        color: provider.viewMode == 'agenda'
                            ? AppTheme.primaryTeal
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
                      ),
                      onPressed: () => provider.setViewMode('agenda'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Search Field
          TextField(
            onChanged: (val) => provider.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Search by course code (SE331), title (Software Engineering), faculty (SSA), or room (711B)...',
              hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => provider.setSearchQuery(''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

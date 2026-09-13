import 'package:flutter/material.dart';
import '../models/class_session.dart';
import '../models/routine_model.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';

class SessionDetailDialog extends StatefulWidget {
  final ClassSession? session; // null if creating new session
  final RoutineProvider provider;
  final String? initialDay;
  final String? initialTimeSlot;

  const SessionDetailDialog({
    super.key,
    this.session,
    required this.provider,
    this.initialDay,
    this.initialTimeSlot,
  });

  static Future<void> show(
    BuildContext context, {
    ClassSession? session,
    required RoutineProvider provider,
    String? initialDay,
    String? initialTimeSlot,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SessionDetailDialog(
        session: session,
        provider: provider,
        initialDay: initialDay,
        initialTimeSlot: initialTimeSlot,
      ),
    );
  }

  @override
  State<SessionDetailDialog> createState() => _SessionDetailDialogState();
}

class _SessionDetailDialogState extends State<SessionDetailDialog> {
  late TextEditingController _titleController;
  late TextEditingController _codeController;
  late TextEditingController _facultyController;
  late TextEditingController _roomController;
  late TextEditingController _startController;
  late TextEditingController _endController;

  late String _day;
  late String _type;
  late String _subgroup;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = widget.session;

    String initialStart = '10:00';
    String initialEnd = '11:30';
    if (widget.initialTimeSlot != null) {
      final parts = widget.initialTimeSlot!.split('-');
      if (parts.length == 2) {
        initialStart = parts[0].trim();
        initialEnd = parts[1].trim();
      }
    }

    _titleController = TextEditingController(text: s?.courseTitle ?? '');
    _codeController = TextEditingController(text: s?.courseCode ?? '');
    _facultyController = TextEditingController(text: s?.facultyInitial ?? '');
    _roomController = TextEditingController(text: s?.room ?? '');
    _startController = TextEditingController(text: s?.startTime ?? initialStart);
    _endController = TextEditingController(text: s?.endTime ?? initialEnd);

    _day = s?.day ?? widget.initialDay ?? 'Sunday';
    _type = s?.type ?? 'theory';
    _subgroup = s?.subgroup ?? 'ALL';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _facultyController.dispose();
    _roomController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.session == null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isNew ? Icons.add_circle_outline : Icons.edit_calendar,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isNew ? 'Add Class Session' : 'Edit Class Session',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day & Type Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _day,
                        decoration: const InputDecoration(labelText: 'Day of Week'),
                        items: RoutineModel.weekdays.map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _day = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Class Type'),
                        items: const [
                          DropdownMenuItem(value: 'theory', child: Text('Theory Lecture')),
                          DropdownMenuItem(value: 'lab', child: Text('Lab Session')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subgroup selector
                Builder(
                  builder: (context) {
                    final sec = widget.provider.routine?.metadata.section.trim().toUpperCase() ?? 'A';
                    final availableGroups = widget.provider.routine?.availableSubgroups ?? ['${sec}1', '${sec}2'];
                    final dropdownGroups = {'ALL', ...availableGroups, _subgroup}.toList();

                    return DropdownButtonFormField<String>(
                      initialValue: dropdownGroups.contains(_subgroup) ? _subgroup : 'ALL',
                      decoration: InputDecoration(
                        labelText: 'Subgroup / Section',
                        helperText: 'Select ALL for general lectures, or specific lab group (${availableGroups.join(", ")})',
                      ),
                      items: dropdownGroups.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(g == 'ALL' ? 'ALL (Whole Section)' : 'Group $g Only'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _subgroup = val);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Course Code & Title
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Course Code',
                          hintText: 'SE331',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Course Title',
                          hintText: 'Software Engineering',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Start & End Time
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startController,
                        decoration: const InputDecoration(
                          labelText: 'Start Time (HH:mm)',
                          hintText: '10:00',
                          prefixIcon: Icon(Icons.access_time, size: 18),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endController,
                        decoration: const InputDecoration(
                          labelText: 'End Time (HH:mm)',
                          hintText: '11:30',
                          prefixIcon: Icon(Icons.access_time_filled, size: 18),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Faculty & Room
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _facultyController,
                        decoration: const InputDecoration(
                          labelText: 'Faculty Initial',
                          hintText: 'SSA',
                          prefixIcon: Icon(Icons.person_outline, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(
                          labelText: 'Room',
                          hintText: 'AB3-106 / ONLINE',
                          prefixIcon: Icon(Icons.meeting_room_outlined, size: 18),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (!isNew)
          TextButton.icon(
            onPressed: () {
              widget.provider.deleteSession(widget.session!.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session removed')),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final session = ClassSession(
              id: widget.session?.id,
              day: _day,
              startTime: _startController.text.trim(),
              endTime: _endController.text.trim(),
              courseTitle: _titleController.text.trim(),
              courseCode: _codeController.text.trim().toUpperCase(),
              facultyInitial: _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim(),
              room: _roomController.text.trim(),
              type: _type,
              subgroup: _subgroup,
            );

            if (isNew) {
              widget.provider.addSession(session);
            } else {
              widget.provider.updateSession(session);
            }

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isNew ? 'Session added!' : 'Session updated!'),
                backgroundColor: AppTheme.primaryTeal,
              ),
            );
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
          child: Text(isNew ? 'Add Session' : 'Save Changes'),
        ),
      ],
    );
  }
}

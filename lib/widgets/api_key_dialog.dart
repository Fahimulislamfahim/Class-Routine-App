import 'package:flutter/material.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';

class ApiKeyDialog extends StatefulWidget {
  final RoutineProvider provider;

  const ApiKeyDialog({super.key, required this.provider});

  static Future<void> show(BuildContext context, RoutineProvider provider) {
    return showDialog(
      context: context,
      builder: (ctx) => ApiKeyDialog(provider: provider),
    );
  }

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late TextEditingController _keyController;
  late String _selectedModel;
  bool _obscureKey = true;

  final List<String> _models = [
    'gemini-2.5-flash',
    'gemini-3.7-flash',
    'gemini-2.5-pro',
    'gemini-3.5-flash-lite',
  ];

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.provider.apiKey);
    _selectedModel = widget.provider.selectedModel;
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.key, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 12),
          const Text('Gemini API Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Google Gemini API Key to extract routines from uploaded images using Multimodal Vision.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedModel,
              decoration: const InputDecoration(
                labelText: 'Multimodal Vision Model',
                prefixIcon: Icon(Icons.auto_awesome, size: 20),
              ),
              items: _models.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedModel = val);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryTeal.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your API Key is stored locally in your browser storage and never sent anywhere except Google Generative Language API.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[300] : const Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            widget.provider.setApiKey(_keyController.text);
            widget.provider.setSelectedModel(_selectedModel);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gemini API settings saved successfully.'),
                backgroundColor: AppTheme.primaryTeal,
              ),
            );
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
          icon: const Icon(Icons.save, size: 18),
          label: const Text('Save Settings'),
        ),
      ],
    );
  }
}

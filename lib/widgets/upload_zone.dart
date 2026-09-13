import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'api_key_dialog.dart';

class UploadZone extends StatelessWidget {
  final RoutineProvider provider;

  const UploadZone({super.key, required this.provider});

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();

        final ext = (file.extension ?? 'jpg').toLowerCase();
        final mimeType = ext == 'png'
            ? 'image/png'
            : ext == 'webp'
                ? 'image/webp'
                : 'image/jpeg';

        await provider.extractFromImageBytes(
          bytes: bytes,
          filename: file.name,
          mimeType: mimeType,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // If error occurred, show error banner
          if (provider.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extraction Error',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.errorMessage!,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.red[200] : Colors.red[900]),
                        ),
                      ],
                    ),
                  ),
                  if (!provider.hasApiKey)
                    FilledButton.tonal(
                      onPressed: () => ApiKeyDialog.show(context, provider),
                      child: const Text('Set API Key'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => provider.clearError(),
                  ),
                ],
              ),
            ),

          // Upload Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.isLoading
                    ? AppTheme.primaryTeal
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: provider.isLoading ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 6),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: provider.isLoading
                ? _buildLoadingState(context, isDark)
                : _buildIdleState(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          provider.statusMessage.isNotEmpty
              ? provider.statusMessage
              : 'Analyzing routine image with Gemini Multimodal Vision...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Using ${provider.selectedModel} to structure schedule, times, subgroups, and rooms...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildIdleState(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Upload icon container
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            size: 32,
            color: AppTheme.primaryTeal,
          ),
        ),
        const SizedBox(width: 16),

        // Text explanations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload University Routine Image',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                'Extract classes, lab groups (D1/D2), room numbers, and timings automatically with Gemini Vision.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Buttons
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => provider.loadSampleRoutine(),
              icon: const Icon(Icons.flash_on, size: 16, color: AppTheme.coralAccent),
              label: const Text('Try Demo Routine'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.coralAccent,
                side: const BorderSide(color: AppTheme.coralAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _pickAndUploadImage(context),
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload Routine Image'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

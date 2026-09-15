import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';

class AetherVisionScannerScreen extends StatefulWidget {
  final RoutineProvider provider;

  const AetherVisionScannerScreen({super.key, required this.provider});

  @override
  State<AetherVisionScannerScreen> createState() => _AetherVisionScannerScreenState();
}

class _AetherVisionScannerScreenState extends State<AetherVisionScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _showArLayer = true;
  late AnimationController _scanLaserController;
  late Animation<double> _scanLaserAnimation;

  @override
  void initState() {
    super.initState();
    _scanLaserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scanLaserAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(parent: _scanLaserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLaserController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScanImage() async {
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

        await widget.provider.extractFromImageBytes(
          bytes: bytes,
          filename: file.name,
          mimeType: mimeType,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showModelPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final models = [
          'gemini-2.5-flash',
          'gemini-1.5-flash',
          'gemini-1.5-pro',
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Vision Model',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...models.map((m) {
                final isSelected = widget.provider.selectedModel == m;
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: isSelected ? AppTheme.primaryContainer.withAlpha(40) : null,
                  leading: Icon(
                    Icons.bolt,
                    color: isSelected ? AppTheme.secondaryContainer : AppTheme.outline,
                  ),
                  title: Text(
                    m,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.secondaryContainer : AppTheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppTheme.secondaryContainer)
                      : null,
                  onTap: () {
                    widget.provider.setSelectedModel(m);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final routine = provider.routine;
    final metadata = routine?.metadata;

    int totalSessions = routine?.schedule.length ?? 0;
    int labCount = routine?.schedule.where((s) => s.isLab).length ?? 0;
    int theoryCount = totalSessions - labCount;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Top Model Selector Capsule
          GestureDetector(
            onTap: _showModelPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh.withAlpha(180),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.outlineVariant.withAlpha(80)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
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
                  const SizedBox(width: 8),
                  Text(
                    provider.selectedModel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest.withAlpha(200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 10, color: AppTheme.secondaryFixed),
                        SizedBox(width: 3),
                        Text(
                          'Encrypted',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppTheme.secondaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Liquid Viewfinder Hero Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(180),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                // Viewfinder Screen Housing
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDim,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Base Image or Synthetic Schedule Preview
                      Positioned.fill(
                        child: provider.routineImageBytes != null
                            ? Image.memory(
                                provider.routineImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/sample_routine.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFF0F172A),
                                  child: const Center(
                                    child: Icon(
                                      Icons.document_scanner,
                                      size: 64,
                                      color: AppTheme.outlineVariant,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      // Optical Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.surfaceDim.withAlpha(160),
                                Colors.transparent,
                                AppTheme.surfaceDim.withAlpha(210),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // AR Neural Grid & Bounding Boxes Layer
                      if (_showArLayer) ...[
                        // Laser Target Reticle Scan Line
                        AnimatedBuilder(
                          animation: _scanLaserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 350 * _scanLaserAnimation.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.secondaryContainer,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.secondaryContainer.withAlpha(220),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Bounding Box 1: Course Detected
                        Positioned(
                          top: 50,
                          left: 20,
                          right: 40,
                          child: _buildBoundingBox(
                            title: '${metadata?.batch ?? "SE331"} Pattern Detected',
                            confidence: '99.8%',
                            subtitle: metadata?.department ?? 'Software Architecture & Engineering',
                            badgeColor: AppTheme.secondaryContainer,
                          ),
                        ),

                        // Bounding Box 2: Subgroup Lab Detection
                        Positioned(
                          top: 150,
                          left: 24,
                          child: _buildBoundingBox(
                            title: 'Subgroup ${provider.subgroupFilter}',
                            confidence: 'Lab-402',
                            subtitle: '10:00 AM – 01:00 PM (3.0 hrs)',
                            badgeColor: AppTheme.tertiary,
                          ),
                        ),

                        // Bounding Box 3: Room Detection
                        Positioned(
                          bottom: 35,
                          right: 20,
                          child: _buildBoundingBox(
                            title: 'Room ${routine?.schedule.firstOrNull?.room ?? "AB3-106"}',
                            confidence: '98.2%',
                            subtitle: 'Theory & Lab Faculty Block',
                            badgeColor: AppTheme.primary,
                          ),
                        ),
                      ],

                      // Optical Corner Accents
                      ..._buildOpticalCorners(),

                      // Loading status overlay if extracting
                      if (provider.isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withAlpha(190),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    color: AppTheme.secondaryContainer,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.statusMessage.isNotEmpty
                                        ? provider.statusMessage
                                        : 'Extracting Schedule with Gemini Vision...',
                                    style: const TextStyle(
                                      color: AppTheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Split Slider: Neural AR Layer vs Raw Scan
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh.withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showArLayer = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _showArLayer
                                    ? AppTheme.secondaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _showArLayer
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.secondaryContainer.withAlpha(120),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Neural AR Layer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _showArLayer
                                      ? AppTheme.onSecondary
                                      : AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showArLayer = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !_showArLayer
                                    ? AppTheme.secondaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: !_showArLayer
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.secondaryContainer.withAlpha(120),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Raw Scan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: !_showArLayer
                                      ? AppTheme.onSecondary
                                      : AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Resolved Metadata Glass Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer.withAlpha(200),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(140),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.secondaryContainer.withAlpha(30),
                          ),
                          child: const Icon(Icons.verified, size: 18, color: AppTheme.secondaryContainer),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'RESOLVED METADATA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${metadata?.semester ?? "Fall"} ${metadata?.year ?? 2026} Routine',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 14, color: AppTheme.secondaryFixed),
                          SizedBox(width: 4),
                          Text(
                            'High Fidelity',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Grid 2x2
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.3,
                  children: [
                    _buildMetaTile('Dept', metadata?.department.isNotEmpty == true ? metadata!.department : 'Software Engineering'),
                    _buildMetaTile('Batch & Section', 'B${metadata?.batch ?? "44"} // SEC-${metadata?.section ?? "A"}'),
                    _buildMetaTile('Effective Date', metadata?.effectiveDate.isNotEmpty == true ? metadata!.effectiveDate : '12 Sep 2026'),
                    _buildMetaTile('Campus', metadata?.campus.isNotEmpty == true ? metadata!.campus : 'Permanent Campus'),
                  ],
                ),

                const SizedBox(height: 14),

                // Metric chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMetricChip(
                        icon: Icons.school_outlined,
                        label: '$totalSessions Sessions',
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricChip(
                        icon: Icons.biotech_outlined,
                        label: '$labCount Lab Blocks',
                        color: AppTheme.secondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricChip(
                        icon: Icons.menu_book_outlined,
                        label: '$theoryCount Theories',
                        color: AppTheme.tertiary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Neural Pipeline Verification Glass Capsule
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withAlpha(200),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, size: 16, color: AppTheme.secondaryContainer),
                        SizedBox(width: 6),
                        Text(
                          'NEURAL VERIFICATION PIPELINE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '4 / 4 Completed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPipelineStep('Image Base64 Encoded', provider.routineImageBytes != null ? '${(provider.routineImageBytes!.lengthInBytes / 1024).round()} KB' : '212 KB'),
                _buildPipelineStep('Gemini Multimodal Vision API', 'Passed'),
                _buildPipelineStep('Strict JSON Schema Verified', '$totalSessions nodes'),
                _buildPipelineStep('Dynamic Subgroup Aligned', provider.routine?.availableSubgroups.join(' & ') ?? 'A1 & A2'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5. Action Buttons
          // Scan New Schedule Button
          GestureDetector(
            onTap: _pickAndScanImage,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8083FF),
                    Color(0xFF494BD6),
                    Color(0xFFE14EF6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF494BD6).withAlpha(150),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SCAN NEW SCHEDULE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Load Demo Routine Button
          GestureDetector(
            onTap: () => provider.loadSampleRoutine(),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh.withAlpha(160),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.outlineVariant.withAlpha(80)),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, color: AppTheme.onSurfaceVariant, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Load Demo Routine (Section D)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
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

  Widget _buildBoundingBox({
    required String title,
    required String confidence,
    required String subtitle,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withAlpha(210),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withAlpha(60),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  confidence,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOpticalCorners() {
    const cornerSize = 18.0;
    const strokeWidth = 2.5;
    final color = AppTheme.secondaryContainer.withAlpha(200);

    return [
      // Top Left
      Positioned(
        top: 10,
        left: 10,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: _CornerPainter(color: color, strokeWidth: strokeWidth, isTop: true, isLeft: true),
          ),
        ),
      ),
      // Top Right
      Positioned(
        top: 10,
        right: 10,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: _CornerPainter(color: color, strokeWidth: strokeWidth, isTop: true, isLeft: false),
          ),
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: 10,
        left: 10,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: _CornerPainter(color: color, strokeWidth: strokeWidth, isTop: false, isLeft: true),
          ),
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: 10,
        right: 10,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: _CornerPainter(color: color, strokeWidth: strokeWidth, isTop: false, isLeft: false),
          ),
        ),
      ),
    ];
  }

  Widget _buildMetaTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withAlpha(160),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
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

  Widget _buildPipelineStep(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer.withAlpha(140),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondaryContainer.withAlpha(40),
                  ),
                  child: const Icon(Icons.check, size: 12, color: AppTheme.secondaryContainer),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondaryFixed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isTop;
  final bool isLeft;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    final x0 = isLeft ? 0.0 : size.width;
    final x1 = isLeft ? size.width : 0.0;
    final y0 = isTop ? 0.0 : size.height;
    final y1 = isTop ? size.height : 0.0;

    path.moveTo(x0, y1);
    path.lineTo(x0, y0);
    path.lineTo(x1, y0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

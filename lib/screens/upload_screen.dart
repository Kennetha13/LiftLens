import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../config.dart';
import '../models/analysis_result.dart';
import '../services/gemini_files_service.dart';
import '../services/platform_file_reader.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';
import 'analysis_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  int _selectedExercise = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  PlatformFile? _videoFile;
  bool _isAnalyzing = false;
  String _statusMessage = '';

  final GeminiFilesService _geminiService =
      GeminiFilesService(apiKey: apiKey);

  final List<Map<String, dynamic>> exercises = [
    {'label': 'Squat', 'icon': Icons.accessibility_new_rounded},
    {'label': 'Bench Press', 'icon': Icons.fitness_center_rounded},
    {'label': 'Deadlift', 'icon': Icons.arrow_upward_rounded},
    {'label': 'OHP', 'icon': Icons.upload_rounded},
    {'label': 'Other', 'icon': Icons.add_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 0.4).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _videoMimeType(PlatformFile f) {
    final n = f.name.toLowerCase();
    if (n.endsWith('.webm')) return 'video/webm';
    if (n.endsWith('.mov')) return 'video/quicktime';
    if (n.endsWith('.mkv')) return 'video/x-matroska';
    if (n.endsWith('.mpeg') || n.endsWith('.mpg')) return 'video/mpeg';
    return 'video/mp4';
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: kIsWeb,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = result.files.first;
        _statusMessage = '';
      });
    }
  }

  void _clearVideo() {
    setState(() {
      _videoFile = null;
      _statusMessage = '';
    });
  }

  Future<void> _startAnalysis() async {
    final video = _videoFile;
    if (video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusMessage = 'Reading video file…';
    });

    try {
      final bytes = await loadPlatformFileBytes(video);
      if (bytes == null) {
        throw Exception(
            'Could not read video file. Try picking it again.');
      }

      final rawJson = await _geminiService.uploadProcessAndGenerate(
        bytes: bytes,
        mimeType: _videoMimeType(video),
        displayName: video.name,
        onStatus: (s) {
          if (mounted) setState(() => _statusMessage = s);
        },
      );

      if (!mounted) return;

      AnalysisResult result;
      try {
        result = AnalysisResult.fromGeminiText(rawJson);
      } catch (e) {
        throw Exception(
            'Gemini returned an unexpected format. Try again.\n\nRaw: $rawJson');
      }

      setState(() {
        _isAnalyzing = false;
        _statusMessage = '';
        _videoFile = null;
      });

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _statusMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const AppStatusBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildExerciseSelector(),
                    const SizedBox(height: 20),
                    _buildUploadZone(),
                    const SizedBox(height: 20),
                    _buildTips(),
                    if (_videoFile != null) ...[
                      const SizedBox(height: 20),
                      _buildQueuedItem(),
                    ],
                    const SizedBox(height: 20),
                    _buildAnalyzeCTA(),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Full-screen loading overlay while analyzing
        if (_isAnalyzing) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analyze Lift',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Upload your workout video for AI review',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
          GestureDetector(
            onTap: _videoFile != null ? _clearVideo : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: AppDecorations.glass,
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXERCISE TYPE',
            style: AppTextStyles.sectionLabel
                .copyWith(letterSpacing: 1.5, fontSize: 10)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: exercises.asMap().entries.map((e) {
              final isActive = e.key == _selectedExercise;
              return GestureDetector(
                onTap: () => setState(() => _selectedExercise = e.key),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0x26C8F53A)
                        : const Color(0x0FFFFFFF),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isActive
                          ? const Color(0x80C8F53A)
                          : const Color(0x1AFFFFFF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        e.value['icon'] as IconData,
                        size: 13,
                        color: isActive
                            ? AppColors.accent
                            : Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        e.value['label'] as String,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.accent
                              : Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: _isAnalyzing ? null : _pickVideo,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: _videoFile != null
              ? const Color(0x0DC8F53A)
              : const Color(0x08C8F53A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _videoFile != null
                ? const Color(0x80C8F53A)
                : const Color(0x4DC8F53A),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0x1AC8F53A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0x40C8F53A), width: 1.5),
              ),
              child: Icon(
                _videoFile != null
                    ? Icons.check_circle_rounded
                    : Icons.videocam_rounded,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _videoFile != null ? 'Video selected!' : 'Tap to choose a video',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              _videoFile != null
                  ? _videoFile!.name
                  : 'Supports MP4, MOV, AVI · Max 2 min\nBest results with side or 45° angle view',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _videoFile != null
                      ? AppColors.accent.withOpacity(0.8)
                      : Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  height: 1.6),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _isAnalyzing ? null : _pickVideo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_rounded,
                            color: Color(0xFF0D0D14), size: 15),
                        const SizedBox(width: 8),
                        Text(
                          _videoFile != null ? 'Change Video' : 'Choose Video',
                          style: const TextStyle(
                              color: Color(0xFF0D0D14),
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_videoFile != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isAnalyzing ? null : _clearVideo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: AppDecorations.glass,
                      child: const Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              color: Colors.white54, size: 15),
                          SizedBox(width: 8),
                          Text('Remove',
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTips() {
    final tips = [
      {
        'icon': Icons.videocam_rounded,
        'title': 'Film from the side',
        'desc':
            'A 45° or direct side angle captures form best. Avoid filming only from behind.',
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'title': 'Good lighting matters',
        'desc':
            'Ensure your body is clearly visible — avoid dark or backlit environments.',
      },
      {
        'icon': Icons.person_rounded,
        'title': 'Full body in frame',
        'desc':
            'Make sure your entire body (head to feet) is visible throughout the lift.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TIPS FOR BEST RESULTS', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x0DC8F53A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x1FC8F53A)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0x26C8F53A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tip['icon'] as IconData,
                        color: AppColors.accent, size: 13),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip['title'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(tip['desc'] as String,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildQueuedItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x26C8F53A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.movie_rounded,
                color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _videoFile!.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _videoFile!.size > 0
                      ? '${(_videoFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB'
                      : 'Size unknown',
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) => Opacity(
              opacity: _pulseAnimation.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text('Ready',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAnalyzeCTA() {
    final bool canAnalyze = _videoFile != null && !_isAnalyzing;
    return GestureDetector(
      onTap: canAnalyze ? _startAnalysis : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: canAnalyze ? AppColors.accent : AppColors.accent.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_fix_high_rounded,
                color: Color(0xFF0D0D14), size: 18),
            SizedBox(width: 8),
            Text('Start AI Analysis',
                style: TextStyle(
                    color: Color(0xFF0D0D14),
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.accent,
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Analyzing Your Lift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _statusMessage,
                    key: ValueKey(_statusMessage),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x14C8F53A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33C8F53A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_fix_high_rounded,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'Powered by Gemini',
                        style: TextStyle(
                          color: AppColors.accent.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/analysis_result.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key, this.result, this.videoPath});

  /// The analysis result that drove the Veo generation.
  final AnalysisResult? result;

  /// Absolute path to the Veo-generated MP4 file on device.
  /// When null, shows the demo/placeholder layout.
  final String? videoPath;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initPlayer(widget.videoPath!);
    }
  }

  Future<void> _initPlayer(String videoUrl) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controller = controller;
    await controller.initialize();
    controller.setLooping(true);
    controller.addListener(_onVideoUpdate);
    if (mounted) {
      setState(() => _isInitialized = true);
      controller.play();
      setState(() => _isPlaying = true);
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    if (c.value.isPlaying) {
      c.pause();
      setState(() => _isPlaying = false);
    } else {
      if (c.value.position >= c.value.duration) {
        c.seekTo(Duration.zero);
      }
      c.play();
      setState(() => _isPlaying = true);
    }
  }

  void _setSpeed(double speed) {
    _controller?.setPlaybackSpeed(speed);
    setState(() => _playbackSpeed = speed);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRealVideo = widget.videoPath != null && _isInitialized;
    final result = widget.result;

    final corrections = result?.issues
            .where((i) => i.severity != IssueSeverity.good)
            .toList() ??
        _demoCorrections;

    final strengths = result?.strengths ?? _demoStrengths;
    final exerciseName = result?.exerciseName ?? 'Squat';

    return Column(
      children: [
        const AppStatusBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, exerciseName, hasRealVideo),
                const SizedBox(height: 16),
                _buildVideoPlayer(hasRealVideo),
                const SizedBox(height: 20),
                _buildSpeedSelector(),
                const SizedBox(height: 24),
                _buildCorrectionsSection(corrections),
                const SizedBox(height: 20),
                if (strengths.isNotEmpty) _buildStrengthsSection(strengths),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, String exerciseName, bool hasRealVideo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: AppDecorations.glass,
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$exerciseName Form Fix',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded,
                          color: Colors.white, size: 11),
                      SizedBox(width: 5),
                      Text('Generated by Veo 3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(bool hasRealVideo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Video or placeholder
              hasRealVideo
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : _buildVideoPlaceholder(),

              // Gradient overlay for controls
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x66000000),
                        Color(0xCC000000),
                      ],
                      stops: [0.0, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // Play/Pause tap area
              Positioned.fill(
                child: GestureDetector(
                  onTap: hasRealVideo ? _togglePlay : null,
                  behavior: HitTestBehavior.translucent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: (hasRealVideo && !_isPlaying) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
              ),

              // Controls bar at bottom
              if (hasRealVideo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildControlsBar(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        color: const Color(0xFF0D0D14),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Veo 3 Video',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Text('Generate from the Analysis screen',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsBar() {
    final c = _controller!;
    final position = c.value.position;
    final duration = c.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Custom progress bar (no Flutter Slider = no red square) ──
          LayoutBuilder(builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final frac =
                    (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                c.seekTo(duration * frac);
              },
              onHorizontalDragUpdate: (d) {
                final frac =
                    (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                c.seekTo(duration * frac);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track background
                    Container(
                      height: 3,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Progress fill
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Thumb dot
                    Positioned(
                      left: (progress.clamp(0.0, 1.0) *
                              (constraints.maxWidth - 10))
                          .clamp(0, constraints.maxWidth - 10),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      c.seekTo(Duration.zero);
                      c.play();
                      setState(() => _isPlaying = true);
                    },
                    child: const Icon(Icons.replay_rounded,
                        color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24),
                  ),
                ],
              ),
              Text(_formatDuration(duration),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.5];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text('PLAYBACK SPEED',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0)),
          const SizedBox(width: 16),
          ...speeds.map((s) {
            final isActive = _playbackSpeed == s;
            return GestureDetector(
              onTap: () => _setSpeed(s),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF6366F1)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${s}x',
                    style: TextStyle(
                        color: isActive ? Colors.white : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCorrectionsSection(List<FormIssue> corrections) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.construction_rounded,
                  color: AppColors.purple, size: 14),
              const SizedBox(width: 8),
              const Text('WHAT VEO CORRECTED',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          ...corrections.map((c) {
            final fixText = (c.fix ?? c.description)
                .replaceAll(RegExp(r'^💡 FIX:\s*'), '');
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: AppDecorations.glassCard,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0x26A78BFA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.compare_arrows_rounded,
                        color: AppColors.purple, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(fixText,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 11,
                                height: 1.4)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.accent, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStrengthsSection(List<String> strengths) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
              const SizedBox(width: 8),
              const Text('KEEP DOING THIS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x08C8F53A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x1EC8F53A)),
            ),
            child: Column(
              children: strengths
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(s,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 11,
                                      height: 1.4)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Pop back to Upload screen (pop twice: Video → Analysis → Upload)
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: Color(0xFF0D0D14), size: 18),
                  SizedBox(width: 8),
                  Text('Analyze Another Lift',
                      style: TextStyle(
                          color: Color(0xFF0D0D14),
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded,
                      color: Colors.white.withOpacity(0.5), size: 16),
                  const SizedBox(width: 8),
                  Text('Back to Analysis',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Demo fallbacks when opened from tab bar
  static final _demoCorrections = [
    FormIssue(
      title: 'Knee Alignment',
      severity: IssueSeverity.critical,
      description: 'Knees tracking over toes throughout descent.',
      fix: 'Keep knees pushed out in line with your toes during descent.',
    ),
    FormIssue(
      title: 'Torso Position',
      severity: IssueSeverity.moderate,
      description: 'Chest up, spine neutral at all positions.',
      fix: 'Maintain an upright torso with a neutral spine.',
    ),
    FormIssue(
      title: 'Tempo Control',
      severity: IssueSeverity.moderate,
      description: '3-second eccentric phase demonstrated.',
      fix: 'Control the descent over 3 seconds for maximum tension.',
    ),
  ];

  static const _demoStrengths = [
    'Consistent depth across all reps',
    'Good bracing and breath control',
  ];
}

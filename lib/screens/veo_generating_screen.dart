import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../models/analysis_result.dart';
import '../services/veo_service.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';
import 'video_screen.dart';

/// Dedicated full-screen loading experience for Veo 3 video generation.
/// Stays on screen no matter what — shows progress on success,
/// shows the exact error (with retry) on failure.
class VeoGeneratingScreen extends StatefulWidget {
  const VeoGeneratingScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  State<VeoGeneratingScreen> createState() => _VeoGeneratingScreenState();
}

class _VeoGeneratingScreenState extends State<VeoGeneratingScreen>
    with TickerProviderStateMixin {
  // Animations
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _stepController;
  late Animation<double> _pulseAnim;
  late Animation<double> _rotatAnim;

  // State
  _GenState _state = _GenState.starting;
  String _statusMessage = 'Building your personalized correction prompt…';
  String? _errorMessage;
  int _currentStep = 0;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;

  final VeoService _veoService = VeoService(apiKey: apiKey);

  final _steps = const [
    _Step(icon: Icons.edit_note_rounded, label: 'Building Prompt'),
    _Step(icon: Icons.upload_rounded, label: 'Sending to Veo 3'),
    _Step(icon: Icons.movie_creation_rounded, label: 'Generating Video'),
    _Step(icon: Icons.check_circle_rounded, label: 'Complete'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotatAnim = Tween<double>(begin: 0, end: 1).animate(_rotateController);

    // Start elapsed timer
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    // Kick off generation
    _generate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _stepController.dispose();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _state = _GenState.generating;
      _currentStep = 0;
      _elapsedSeconds = 0;
      _errorMessage = null;
    });

    try {
      final videoPath = await _veoService.generateCorrectionVideo(
        result: widget.result,
        onStatus: _handleStatus,
      );

      if (!mounted) return;
      setState(() {
        _state = _GenState.done;
        _currentStep = 3;
        _statusMessage = 'Video ready!';
      });
      _elapsedTimer?.cancel();

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) =>
              VideoScreen(result: widget.result, videoPath: videoPath),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _elapsedTimer?.cancel();
      setState(() {
        _state = _GenState.error;
        _errorMessage = e.toString();
        _statusMessage = 'Generation failed';
      });
      _pulseController.stop();
      _rotateController.stop();
    }
  }

  void _handleStatus(String status) {
    if (!mounted) return;
    setState(() {
      _statusMessage = status;
      // Advance steps based on status keywords
      if (status.contains('Sending') || status.contains('Veo 3')) {
        _currentStep = 1;
      } else if (status.contains('Generating') || status.contains('elapsed')) {
        _currentStep = 2;
      } else if (status.contains('Saving')) {
        _currentStep = 3;
      }
    });
  }

  String get _elapsedLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppStatusBar(),
          Expanded(
            child: _state == _GenState.error
                ? _buildErrorView()
                : _buildGeneratingView(),
          ),
        ],
      ),
    );
  }

  // ── Generating View ─────────────────────────────────────────────────────────

  Widget _buildGeneratingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedLogo(),
          const SizedBox(height: 32),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildElapsedTime(),
          const SizedBox(height: 32),
          _buildStepIndicator(),
          const SizedBox(height: 32),
          _buildStatusMessage(),
          const SizedBox(height: 48),
          _buildModelBadge(),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _rotatAnim]),
      builder: (_, __) {
        return Transform.scale(
          scale: _state == _GenState.done ? 1.0 : _pulseAnim.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFFA855F7),
                ],
                transform:
                    GradientRotation(_rotatAnim.value * 2 * 3.14159),
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _state == _GenState.done
                  ? Icons.check_rounded
                  : Icons.videocam_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        _state == _GenState.done ? 'Video Ready!' : 'Veo 3 is Working',
        key: ValueKey(_state),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildElapsedTime() {
    if (_state == _GenState.done) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined,
            color: Colors.white.withOpacity(0.3), size: 13),
        const SizedBox(width: 5),
        Text(
          'Elapsed: $_elapsedLabel · usually 1–3 min',
          style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: _steps.asMap().entries.map((e) {
        final idx = e.key;
        final step = e.value;
        final isDone = idx < _currentStep;
        final isActive = idx == _currentStep;
        final isLast = idx == _steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.accent
                            : isActive
                                ? const Color(0xFF6366F1)
                                : Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withOpacity(0.5),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : step.icon,
                        color: isDone
                            ? const Color(0xFF0D0D14)
                            : isActive
                                ? Colors.white
                                : Colors.white24,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDone
                            ? AppColors.accent
                            : isActive
                                ? Colors.white
                                : Colors.white24,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 2,
                  width: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isDone
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(_statusMessage),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.15)),
        ),
        child: Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _state == _GenState.done
                  ? AppColors.accent
                  : const Color(0xFF6366F1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_state == _GenState.done
                          ? AppColors.accent
                          : const Color(0xFF6366F1))
                      .withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('Google Veo 3 · $veoModel',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Error View ───────────────────────────────────────────────────────────────

  Widget _buildErrorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child:
                const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 40),
          ),
          const SizedBox(height: 24),
          const Text('Generation Failed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Veo 3 returned an error. The full response is shown below — '
            'check the Flutter console for even more detail.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
                height: 1.5),
          ),
          const SizedBox(height: 24),

          // Full error message — always visible
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.red.withOpacity(0.2)),
            ),
            child: SelectableText(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.6,
                  fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 32),

          // Retry button
          GestureDetector(
            onTap: () {
              _pulseController.repeat(reverse: true);
              _rotateController.repeat();
              _elapsedTimer?.cancel();
              _elapsedTimer = Timer.periodic(const Duration(seconds: 1),
                  (_) {
                if (mounted) setState(() => _elapsedSeconds++);
              });
              _generate();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Retry with Veo 3',
                      style: TextStyle(
                          color: Colors.white,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded,
                      color: Colors.white54, size: 16),
                  SizedBox(width: 8),
                  Text('Back to Analysis',
                      style: TextStyle(
                          color: Colors.white54,
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
}

enum _GenState { starting, generating, done, error }

class _Step {
  const _Step({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
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
                const SizedBox(height: 20),
                _buildQueuedItem(),
                const SizedBox(height: 20),
                _buildAnalyzeCTA(),
              ],
            ),
          ),
        ),
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
          Container(
            width: 36,
            height: 36,
            decoration: AppDecorations.glass,
            child: const Icon(Icons.close_rounded,
                color: Colors.white54, size: 16),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0x08C8F53A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x4DC8F53A), width: 2),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: -4),
            duration: const Duration(seconds: 3),
            builder: (_, value, child) => child!,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0x1AC8F53A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x40C8F53A), width: 1.5),
              ),
              child: const Icon(Icons.videocam_rounded,
                  color: AppColors.accent, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Drop your video here',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            'Supports MP4, MOV, AVI · Max 2 min\nBest results with side or 45° angle view',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
                height: 1.6),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.photo_library_rounded,
                        color: Color(0xFF0D0D14), size: 15),
                    SizedBox(width: 8),
                    Text('Choose Video',
                        style: TextStyle(
                            color: Color(0xFF0D0D14),
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: AppDecorations.glass,
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        color: Colors.white54, size: 15),
                    SizedBox(width: 8),
                    Text('Record',
                        style: TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=100&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade900,
                      child: const Icon(Icons.image, color: Colors.white24, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('squat_session_march.mp4',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('32 MB · 00:48',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: [
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
                  const Text('Queued',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high_rounded, color: Color(0xFF0D0D14), size: 18),
          SizedBox(width: 8),
          Text('Start AI Analysis',
              style: TextStyle(
                  color: Color(0xFF0D0D14),
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

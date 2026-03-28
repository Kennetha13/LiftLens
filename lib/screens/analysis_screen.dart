import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppStatusBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoPreview(),
                const SizedBox(height: 16),
                _buildScoreSection(),
                const SizedBox(height: 16),
                _buildFormBreakdown(),
                const SizedBox(height: 16),
                _buildIssuesDetected(),
                const SizedBox(height: 16),
                _buildVeoCTA(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=700&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.fitness_center, color: Colors.white24, size: 40),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.35),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Row(
              children: [
                _buildTimestampPill('⚠ 0:12', Colors.red.shade400),
                const SizedBox(width: 6),
                _buildTimestampPill('⚠ 0:31', Colors.red.shade400),
                const SizedBox(width: 6),
                _buildTimestampPill('✓ 0:45', AppColors.accent),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _buildTimestampPill('00:48', Colors.white),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.share_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildScoreSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Back Squat',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x26C8F53A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Intermediate',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.2),
                        const Color(0xFFA855F7).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_fix_high_rounded,
                          color: AppColors.purple, size: 13),
                      SizedBox(width: 6),
                      Text('Analyzed by Gemini',
                          style: TextStyle(
                              color: AppColors.purple,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _ScoreRingPainter(0.85),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('85',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            height: 1.0)),
                    Text('FORM',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBreakdown() {
    final metrics = [
      {'label': 'Depth', 'value': 0.92, 'text': '92%', 'color': AppColors.accent},
      {'label': 'Bar Path', 'value': 0.88, 'text': '88%', 'color': AppColors.accent},
      {'label': 'Knee Tracking', 'value': 0.58, 'text': '58%', 'color': AppColors.red},
      {'label': 'Spine Neutral', 'value': 0.74, 'text': '74%', 'color': AppColors.orange},
      {'label': 'Tempo', 'value': 0.90, 'text': '90%', 'color': AppColors.accent},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glassCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FORM BREAKDOWN', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
            ...metrics.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m['label'] as String,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          Text(m['text'] as String,
                              style: TextStyle(
                                  color: m['color'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: m['value'] as double,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              m['color'] as Color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesDetected() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ISSUES DETECTED', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          _buildIssueCard(
            icon: Icons.warning_amber_rounded,
            iconBg: const Color(0x26FF4B4B),
            iconColor: AppColors.red,
            borderColor: const Color(0x26FF4B4B),
            bgColor: const Color(0x0FFF4B4B),
            title: 'Knee Valgus Collapse',
            tagText: 'Critical',
            tagColor: AppColors.red,
            tagBg: const Color(0x26FF4B4B),
            description:
                'Both knees cave inward during descent, particularly visible at 0:12 and 0:31. This increases ACL and meniscus stress.',
            fix: '💡 FIX: Cue "push knees out" and add band walks to activate glute med. Consider widening stance 5–10°.',
          ),
          const SizedBox(height: 10),
          _buildIssueCard(
            icon: Icons.priority_high_rounded,
            iconBg: const Color(0x26FF9A3C),
            iconColor: AppColors.orange,
            borderColor: const Color(0x26FF9A3C),
            bgColor: const Color(0x0FFF9A3C),
            title: 'Forward Lean',
            tagText: 'Moderate',
            tagColor: AppColors.orange,
            tagBg: const Color(0x26FF9A3C),
            description:
                'Torso angle exceeds 45° forward during descent, shifting load to lower back. May indicate ankle mobility restrictions.',
            fix: '💡 FIX: Add heel elevation or work on ankle dorsiflexion. Box squats can help you reset posture.',
          ),
          const SizedBox(height: 10),
          _buildIssueCard(
            icon: Icons.check_rounded,
            iconBg: const Color(0x26C8F53A),
            iconColor: AppColors.accent,
            borderColor: const Color(0x26C8F53A),
            bgColor: const Color(0x0FC8F53A),
            title: 'Great Depth',
            tagText: 'Excellent',
            tagColor: AppColors.accent,
            tagBg: const Color(0x26C8F53A),
            description:
                'Hip crease consistently breaks parallel. Excellent range of motion maintained throughout all reps. Keep it up!',
            fix: null,
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
    required Color bgColor,
    required String title,
    required String tagText,
    required Color tagColor,
    required Color tagBg,
    required String description,
    String? fix,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tagText,
                          style: TextStyle(
                              color: tagColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        height: 1.5)),
                if (fix != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(fix,
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeoCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0E2E), Color(0xFF0F1A3A)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.movie_rounded,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  const Text('VEO AI VIDEO',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('See Your Ideal Form',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                  'Watch a personalized AI-generated video showing exactly how to fix your squat form.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      height: 1.5)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('View Improvement Video',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  _ScoreRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 8.0;
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);
    final fgPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5707963,
        2 * 3.14159265 * progress,
        false,
        fgPaint);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}

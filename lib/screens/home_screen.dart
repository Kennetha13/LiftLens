import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppStatusBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildQuickStats(),
                const SizedBox(height: 20),
                _buildUploadCTA(context),
                const SizedBox(height: 24),
                _buildRecentAnalyses(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A0A), AppColors.background],
          stops: [0.0, 0.6],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning,',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const Text('Alex 👋',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ],
              ),
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.accent, width: 2),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white54),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeeklyScoreBanner(),
        ],
      ),
    );
  }

  Widget _buildWeeklyScoreBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glass,
      child: Row(
        children: [
          _buildScoreRing(80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Weekly Score',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const SizedBox(width: 8),
                    _buildTag('+12%'),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Your form has improved this week!',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.8,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF9A3C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 2),
              Text('7 DAY',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRing(int score) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(
        painter: _ScoreRingPainter(score / 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$score',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.0)),
              Text('FORM',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label,
      {Color bgColor = const Color(0x1FC8F53A),
      Color textColor = AppColors.accent,
      Color borderColor = const Color(0x40C8F53A)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(Icons.videocam_rounded, '24', 'Videos Analyzed',
              const Color(0x26C8F53A), AppColors.accent),
          const SizedBox(width: 12),
          _buildStatCard(Icons.bolt_rounded, '89%', 'Accuracy Rate',
              const Color(0x26FF9A3C), AppColors.orange),
          const SizedBox(width: 12),
          _buildStatCard(Icons.fitness_center_rounded, '3', 'Exercises',
              const Color(0x269B87FF), const Color(0xFF9B87FF)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color iconBg, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppDecorations.glassCard,
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCTA(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          // Navigation handled by the bottom nav FAB in MainShell
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: Color(0xFF0D0D14), size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Analyze New Lift',
                  style: TextStyle(
                      color: Color(0xFF0D0D14),
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_forward_rounded,
                    color: Color(0x99000000), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnalyses() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Analyses',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              Text('See All',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            imageUrl: 'assets/images/squat.png',
            tag: 'Squat',
            title: 'Back Squat',
            score: 85,
            scoreColor: AppColors.accent,
            description:
                'Knee caving detected on descent. Hip abductor activation needed to correct valgus collapse.',
            isWarning: true,
            tags: ['Knee Valgus', 'Depth: 85%'],
            timeAgo: '2h ago',
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            imageUrl: 'assets/images/bench.png',
            tag: 'Bench Press',
            title: 'Flat Bench Press',
            score: 91,
            scoreColor: AppColors.accent,
            description:
                'Great scapular retraction and bar path. Minor improvement in wrist alignment needed at lockout.',
            isWarning: false,
            tags: ['Good Form', 'Wrist: Minor'],
            timeAgo: 'Yesterday',
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            imageUrl: 'assets/images/deadlift.png',
            tag: 'Deadlift',
            title: 'Conventional Deadlift',
            score: 72,
            scoreColor: AppColors.orange,
            description:
                'Lower back rounding at lockout. Engage lats and brace core before initiating pull. Risk of injury.',
            isWarning: true,
            tags: ['Back Rounding', 'High Priority'],
            timeAgo: '3 days ago',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required String imageUrl,
    required String tag,
    required String title,
    required int score,
    required Color scoreColor,
    required String description,
    required bool isWarning,
    required List<String> tags,
    required String timeAgo,
  }) {
    return Container(
      decoration: AppDecorations.glassCard,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 144,
                  width: double.infinity,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade900,
                      child: const Icon(Icons.image, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xF20D0D14), Colors.transparent],
                        stops: [0.0, 0.6],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildTag(tag),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scoreColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: scoreColor, width: 1.5),
                        ),
                        child: Center(
                          child: Text('$score',
                              style: TextStyle(
                                  color: scoreColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2, right: 8),
                        decoration: BoxDecoration(
                          color: isWarning
                              ? const Color(0x26FF4B4B)
                              : const Color(0x26C8F53A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWarning ? Icons.warning_amber_rounded : Icons.check_rounded,
                          color: isWarning ? AppColors.red : AppColors.accent,
                          size: 11,
                        ),
                      ),
                      Expanded(
                        child: Text(description,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                height: 1.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ...tags.asMap().entries.map((e) => Padding(
                            padding: EdgeInsets.only(
                                right: e.key < tags.length - 1 ? 8 : 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: e.key == 0 && isWarning
                                    ? const Color(0x1FFF4B4B)
                                    : const Color(0x1FFF9A3C),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: e.key == 0 && isWarning
                                        ? const Color(0x40FF4B4B)
                                        : const Color(0x40FF9A3C)),
                              ),
                              child: Text(e.value,
                                  style: TextStyle(
                                      color: e.key == 0 && isWarning
                                          ? AppColors.red
                                          : AppColors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          )),
                      const Spacer(),
                      Text(timeAgo,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    final radius = size.width / 2 - 3;
    const strokeWidth = 6.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
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
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

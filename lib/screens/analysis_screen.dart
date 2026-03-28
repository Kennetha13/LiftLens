import 'package:flutter/material.dart';
import '../config.dart';
import '../models/analysis_result.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';
import 'veo_generating_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, this.result});

  /// When non-null, renders real Gemini output. When null, shows demo data.
  final AnalysisResult? result;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Demo / fallback data ────────────────────────────────────────────────────
  static const _demoExercise = 'Back Squat';
  static const _demoScore = 85;
  static const _demoSummary =
      'Good overall depth and tempo. Two key issues detected that need attention — '
      'knee valgus and forward lean — both correctable with targeted accessory work.';
  static final _demoMetrics = [
    FormMetric(name: 'Depth', score: 92, feedback: 'Hip crease breaks parallel consistently.'),
    FormMetric(name: 'Bar Path', score: 88, feedback: 'Minimal horizontal deviation.'),
    FormMetric(name: 'Knee Tracking', score: 58, feedback: 'Inward collapse visible at descent.'),
    FormMetric(name: 'Spine Neutral', score: 74, feedback: 'Slight forward lean at depth.'),
    FormMetric(name: 'Tempo', score: 90, feedback: 'Controlled eccentric, strong concentric.'),
  ];
  static final _demoIssues = [
    FormIssue(
      title: 'Knee Valgus Collapse',
      severity: IssueSeverity.critical,
      description:
          'Both knees cave inward during descent, particularly visible at 0:12 and 0:31. '
          'This increases ACL and meniscus stress.',
      fix: '💡 FIX: Cue "push knees out" and add band walks to activate glute med. Consider widening stance 5–10°.',
    ),
    FormIssue(
      title: 'Forward Lean',
      severity: IssueSeverity.moderate,
      description:
          'Torso angle exceeds 45° forward during descent, shifting load to lower back.',
      fix: '💡 FIX: Add heel elevation or work on ankle dorsiflexion.',
    ),
    FormIssue(
      title: 'Great Depth',
      severity: IssueSeverity.good,
      description: 'Hip crease consistently breaks parallel.',
      fix: null,
    ),
  ];
  static const _demoStrengths = [
    'Consistent depth across all reps',
    'Good bracing and breath control',
    'Bar path stays vertical',
  ];
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToVeoGeneration() async {
    final result = widget.result;
    if (result == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VeoGeneratingScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final exerciseName = r?.exerciseName ?? _demoExercise;
    final formScore = r?.formScore ?? _demoScore;
    final summary = r?.overallSummary ?? _demoSummary;
    final metrics = r?.metrics ?? _demoMetrics;
    final issues = r?.issues ?? _demoIssues;
    final strengths = r?.strengths ?? _demoStrengths;

    return Column(
      children: [
        const AppStatusBar(),
        _buildHero(context, exerciseName, formScore, r != null),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(summary, strengths, r),
              _buildMetricsTab(metrics),
              _buildIssuesTab(issues),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero(
      BuildContext context, String exerciseName, int formScore, bool isReal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isReal)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: AppDecorations.glass,
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                )
              else
                const SizedBox(width: 36),
              Column(
                children: [
                  Text(exerciseName.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_fix_high_rounded,
                          color: AppColors.purple, size: 12),
                      const SizedBox(width: 6),
                      Text('AI GENERATED ANALYSIS',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                    progress: formScore / 100,
                    color: _getScoreColor(formScore),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$formScore%',
                      style: TextStyle(
                          color: _getScoreColor(formScore),
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          letterSpacing: -1)),
                  Text('FORM SCORE',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.accent;
    if (score >= 60) return AppColors.orange;
    return AppColors.red;
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: const Color(0xFF0D0D14),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        tabs: const [
          Tab(text: 'OVERVIEW'),
          Tab(text: 'METRICS'),
          Tab(text: 'ISSUES'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
      String summary, List<String> strengths, AnalysisResult? result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COACH\'S SUMMARY',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.glassCard,
            child: Text(
              summary,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('KEY STRENGTHS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...strengths.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x0DC8F53A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
          // Veo CTA — only show for real results, not demo
          if (result != null) ...[
            const SizedBox(height: 24),
            _buildVeoCTA(),
          ],
        ],
      ),
    );
  }

  Widget _buildVeoCTA() {
    return GestureDetector(
      onTap: _navigateToVeoGeneration,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.2),
              const Color(0xFFA855F7).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VEO 3 FIX VIDEO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    Text('Generated by Google Veo 3',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Watch an AI-generated instructional video demonstrating exactly how to fix your form issues for this lift.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12,
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Generate My Fix Video',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMetricsTab(List<FormMetric> metrics) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final m = metrics[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  Text('${m.score}%',
                      style: TextStyle(
                          color: _getScoreColor(m.score),
                          fontSize: 13,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: m.score / 100,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_getScoreColor(m.score)),
                  minHeight: 8,
                ),
              ),
              if (m.feedback.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(m.feedback,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11,
                        height: 1.5,
                        fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildIssuesTab(List<FormIssue> issues) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        IconData icon;
        Color color;
        String tag;

        switch (issue.severity) {
          case IssueSeverity.critical:
            icon = Icons.warning_rounded;
            color = AppColors.red;
            tag = 'CRITICAL';
            break;
          case IssueSeverity.moderate:
            icon = Icons.error_outline_rounded;
            color = AppColors.orange;
            tag = 'MODERATE';
            break;
          case IssueSeverity.good:
            icon = Icons.check_circle_outline_rounded;
            color = AppColors.accent;
            tag = 'OPTIMAL';
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(issue.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(issue.description,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            height: 1.6,
                            fontWeight: FontWeight.w500)),
                    if (issue.fix != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(issue.fix!,
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                height: 1.6,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScoreRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
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

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963,
      2 * 3.14159265 * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}

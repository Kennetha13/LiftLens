import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedPeriod = 1;
  final List<String> _periods = ['1W', '1M', '3M', '6M', '1Y'];
  final List<double> _chartData = [0.45, 0.50, 0.55, 0.62, 0.60, 0.70, 0.75, 0.80, 0.78, 0.85];

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
                _buildHeader(),
                const SizedBox(height: 16),
                _buildPeriodSelector(),
                const SizedBox(height: 16),
                _buildScoreChart(),
                const SizedBox(height: 16),
                _buildPerExerciseScores(),
                const SizedBox(height: 20),
                _buildHeatmap(),
                const SizedBox(height: 20),
                _buildAIInsights(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progress',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
              const SizedBox(height: 2),
              Text('Your form improvement over time',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: AppDecorations.glass,
            child: const Icon(Icons.calendar_today_rounded,
                color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _periods.asMap().entries.map((e) {
          final isActive = e.key == _selectedPeriod;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0x26C8F53A) : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: isActive
                    ? Border.all(color: const Color(0x4DC8F53A))
                    : null,
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  color: isActive
                      ? AppColors.accent
                      : Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScoreChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glassCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Form Score Trend',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    const Text('+18% this month',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('All exercises combined',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 10)),
            const SizedBox(height: 16),
            SizedBox(
              height: 112,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _chartData.asMap().entries.map((e) {
                  final isLast = e.key == _chartData.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: e.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isLast
                                  ? [AppColors.accent, AppColors.accentDark]
                                  : [
                                      AppColors.accent.withOpacity(0.5),
                                      AppColors.accent.withOpacity(0.2),
                                    ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            boxShadow: isLast
                                ? [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Feb 18',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 9)),
                Text('Today',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerExerciseScores() {
    final scores = [
      {'icon': Icons.accessibility_new_rounded, 'score': '85', 'label': 'Squat', 'change': '↑ 12', 'color': AppColors.accent, 'iconBg': const Color(0x1AC8F53A)},
      {'icon': Icons.fitness_center_rounded, 'score': '91', 'label': 'Bench', 'change': '↑ 6', 'color': AppColors.accent, 'iconBg': const Color(0x1AC8F53A)},
      {'icon': Icons.arrow_upward_rounded, 'score': '72', 'label': 'Deadlift', 'change': '↑ 3', 'color': AppColors.orange, 'iconBg': const Color(0x1AFF9A3C)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PER-EXERCISE SCORES', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          Row(
            children: scores.map((s) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: s == scores.last ? 0 : 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppDecorations.glassCard,
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: s['iconBg'] as Color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(s['icon'] as IconData,
                                color: s['color'] as Color, size: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(s['score'] as String,
                              style: TextStyle(
                                  color: s['color'] as Color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18)),
                          Text(s['label'] as String,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(s['change'] as String,
                              style: TextStyle(
                                  color: s['color'] as Color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmap() {
    final heatLevels = [
      [0, 1, 0, 2, 3, 0, 1, 2, 0, 4, 1, 0, 4],
      [1, 0, 3, 0, 1, 2, 0, 3, 1, 2, 4, 4, 2],
      [0, 1, 1, 2, 0, 4, 2, 1, 3, 0, 2, 4, 4],
      [2, 0, 0, 1, 2, 1, 4, 0, 2, 3, 1, 3, 3],
      [0, 2, 1, 0, 1, 0, 1, 2, 0, 1, 0, 0, 0],
      [1, 0, 2, 3, 0, 2, 3, 4, 1, 4, 2, 4, 3],
      [0, 1, 0, 0, 3, 1, 3, 0, 2, 2, 4, 3, 0],
    ];

    Color heatColor(int level) {
      switch (level) {
        case 1: return AppColors.accent.withOpacity(0.2);
        case 2: return AppColors.accent.withOpacity(0.45);
        case 3: return AppColors.accent.withOpacity(0.7);
        case 4: return AppColors.accent;
        default: return Colors.white.withOpacity(0.06);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORKOUT ACTIVITY', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.glassCard,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Last 12 Weeks',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: heatColor(i),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )),
                        Text(' More',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(heatLevels[0].length, (col) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Column(
                          children: List.generate(heatLevels.length, (row) {
                            return Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: heatColor(heatLevels[row][col]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    final insights = [
      {
        'icon': Icons.auto_fix_high_rounded,
        'iconBg': const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)]),
        'iconColor': AppColors.purple,
        'borderColor': const Color(0x4D6366F1),
        'title': 'Your bench press is your strongest lift',
        'desc': 'Consistent 90+ scores. Focus your energy on improving the deadlift next session.',
      },
      {
        'icon': Icons.trending_up_rounded,
        'iconBg': null,
        'iconBgSolid': const Color(0x1AC8F53A),
        'iconColor': AppColors.accent,
        'borderColor': const Color(0x33C8F53A),
        'title': 'Squat score improved 18% in 30 days',
        'desc': 'The band walk exercises are working. Keep adding them to your warm-up routine.',
      },
      {
        'icon': Icons.lightbulb_rounded,
        'iconBg': null,
        'iconBgSolid': const Color(0x1AFF9A3C),
        'iconColor': AppColors.orange,
        'borderColor': const Color(0x33FF9A3C),
        'title': 'Upload a deadlift video this week',
        'desc': "You haven't analyzed this lift in 3 days. Consistent tracking leads to faster improvement.",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI INSIGHTS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          ...insights.map((ins) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ins['borderColor'] as Color),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ins['iconBgSolid'] as Color? ?? const Color(0x1AC8F53A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ins['borderColor'] as Color),
                        ),
                        child: Icon(ins['icon'] as IconData,
                            color: ins['iconColor'] as Color, size: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ins['title'] as String,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(ins['desc'] as String,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 11,
                                    height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

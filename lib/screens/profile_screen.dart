import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                _buildProfileHeader(),
                const SizedBox(height: 4),
                _buildStatsGrid(),
                const SizedBox(height: 20),
                _buildLiftProgress(),
                const SizedBox(height: 20),
                _buildBadges(),
                const SizedBox(height: 20),
                _buildRecentHistory(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
              Container(
                width: 36,
                height: 36,
                decoration: AppDecorations.glass,
                child: const Icon(Icons.settings_rounded,
                    color: Colors.white70, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent, width: 2),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: Color(0xFF0D0D14), size: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alex Chen',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
                    const SizedBox(height: 4),
                    Text('@alexlifts · Member since Jan 2024',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x26C8F53A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0x4DC8F53A)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: AppColors.accent, size: 10),
                              SizedBox(width: 4),
                              Text('Pro Member',
                                  style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x1FFF9A3C),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0x4DFF9A3C)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  color: AppColors.orange, size: 10),
                              const SizedBox(width: 4),
                              Text('7 Day Streak',
                                  style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'value': '24', 'label': 'Videos'},
      {'value': '85', 'label': 'Avg Score', 'accent': true},
      {'value': '3', 'label': 'Lifts'},
      {'value': '12', 'label': 'Fixes Made'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final s = e.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: e.key < stats.length - 1 ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: AppDecorations.glassCard,
                child: Column(
                  children: [
                    Text(s['value'] as String,
                        style: TextStyle(
                            color: s['accent'] == true
                                ? AppColors.accent
                                : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(s['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLiftProgress() {
    final lifts = [
      {'name': 'Back Squat', 'change': '↑ 12pts this month', 'score': 85, 'color': AppColors.accent, 'gradient': [AppColors.accent, AppColors.accentDark]},
      {'name': 'Bench Press', 'change': '↑ 6pts this month', 'score': 91, 'color': AppColors.accent, 'gradient': [AppColors.accent, AppColors.accentDark]},
      {'name': 'Deadlift', 'change': '↑ 3pts this month', 'score': 72, 'color': AppColors.orange, 'gradient': [AppColors.orange, AppColors.orangeDark]},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lift Progress',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text('View All',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.glassCard,
            child: Column(
              children: lifts.asMap().entries.map((e) {
                final lift = e.value;
                final gradientColors = lift['gradient'] as List<Color>;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < lifts.length - 1 ? 16 : 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(lift['name'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              Text(lift['change'] as String,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 10)),
                              const SizedBox(width: 8),
                              Text('${lift['score']}',
                                  style: TextStyle(
                                      color: lift['color'] as Color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (lift['score'] as int) / 100,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              gradientColors[0]),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    final badges = [
      {'emoji': '🏆', 'label': 'First Lift', 'earned': true},
      {'emoji': '🔥', 'label': '7 Day Streak', 'earned': true},
      {'emoji': '💪', 'label': 'Form Pro', 'earned': true},
      {'emoji': '🎯', 'label': '90+ Score', 'earned': true},
      {'emoji': '⚡', 'label': '30 Day Streak', 'earned': false},
      {'emoji': '🧠', 'label': 'AI Master', 'earned': false},
      {'emoji': '🚀', 'label': '50 Lifts', 'earned': false},
      {'emoji': '💎', 'label': 'Elite', 'earned': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Badges',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text('4/12 earned',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: badges.map((b) {
              final earned = b['earned'] as bool;
              return Opacity(
                opacity: earned ? 1.0 : 0.5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: earned
                        ? const Color(0x14C8F53A)
                        : const Color(0x08FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: earned
                          ? const Color(0x33C8F53A)
                          : const Color(0x0FFFFFFF),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(b['emoji'] as String,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        b['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: earned
                              ? AppColors.accent
                              : Colors.white.withOpacity(0.3),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    final history = [
      {
        'imageUrl': 'assets/images/squat.png',
        'title': 'Back Squat',
        'subtitle': 'Today · 3 issues found',
        'score': 85,
        'scoreColor': AppColors.accent,
        'scoreBg': const Color(0x26C8F53A),
      },
      {
        'imageUrl': 'assets/images/bench.png',
        'title': 'Bench Press',
        'subtitle': 'Yesterday · 1 issue found',
        'score': 91,
        'scoreColor': AppColors.accent,
        'scoreBg': const Color(0x26C8F53A),
      },
      {
        'imageUrl': 'assets/images/deadlift.png',
        'title': 'Deadlift',
        'subtitle': '3 days ago · 2 issues found',
        'score': 72,
        'scoreColor': AppColors.orange,
        'scoreBg': const Color(0x26FF9A3C),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent History',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text('See All',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...history.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x08FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x0FFFFFFF)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset(
                            h['imageUrl'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade900,
                              child: const Icon(Icons.image, color: Colors.white24, size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h['title'] as String,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(h['subtitle'] as String,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 10)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: h['scoreBg'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${h['score']}',
                            style: TextStyle(
                                color: h['scoreColor'] as Color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800)),
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

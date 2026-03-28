import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/status_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoAnalyze = true;
  bool _generateVeo = true;
  bool _pushNotifications = true;
  bool _streakReminders = true;
  bool _weeklyEmail = false;

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
                _buildProBanner(),
                const SizedBox(height: 20),
                _buildSection('ACCOUNT', _buildAccountRows()),
                const SizedBox(height: 20),
                _buildSection('AI & ANALYSIS', _buildAIRows()),
                const SizedBox(height: 20),
                _buildSection('NOTIFICATIONS', _buildNotificationRows()),
                const SizedBox(height: 20),
                _buildSection('APP PREFERENCES', _buildPrefsRows()),
                const SizedBox(height: 20),
                _buildSection('SUPPORT', _buildSupportRows()),
                const SizedBox(height: 20),
                _buildSignOut(),
                const SizedBox(height: 16),
                Center(
                  child: Text('LiftLens v2.1.0 · Built with Gemini & Veo',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.2), fontSize: 10)),
                ),
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
          const Text('Settings',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          Text('Done',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildProBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A0A), Color(0xFF0F1E1A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentDark],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('PRO',
                            style: TextStyle(
                                color: Color(0xFF0D0D14),
                                fontSize: 10,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      const Text('LiftLens Pro',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Unlimited analyses · Veo videos · Priority AI',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('\$9.99',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18)),
                  Text('/ month',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('Renews Apr 15',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: AppDecorations.glassCard,
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required Widget icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11)),
                ],
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 16),
        ],
      ),
    ).let((row) => Column(
          children: [
            row,
            if (true) ...[
              // separator (handled by not being last)
            ],
          ],
        ));
  }

  Widget _buildIconBox(Color bgColor, Color iconColor, IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 16),
    );
  }

  Widget _buildToggle(bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.accent : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAccountRows() {
    return [
      _buildSettingRowDivided(
        icon: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0x1AC8F53A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=80&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white54, size: 20),
            ),
          ),
        ),
        title: 'Alex Chen',
        subtitle: 'alex.chen@email.com',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26818CF8), const Color(0xFF818CF8), Icons.shield_rounded),
        title: 'Privacy & Security',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26FBB024), const Color(0xFFFBB024), Icons.workspace_premium_rounded),
        title: 'Manage Subscription',
        trailing: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('PRO',
                  style: TextStyle(
                      color: Color(0xFF0D0D14),
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white24, size: 16),
          ],
        ),
        isLast: true,
      ),
    ].whereType<Widget>().toList();
  }

  Widget _buildSettingRowDivided({
    required Widget icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11)),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white24, size: 16),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }

  List<Widget> _buildAIRows() {
    return [
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26A855F7), const Color(0xFFA855F7), Icons.auto_fix_high_rounded),
        title: 'Auto-Analyze on Upload',
        subtitle: 'Start AI review immediately after upload',
        trailing: _buildToggle(
            _autoAnalyze, () => setState(() => _autoAnalyze = !_autoAnalyze)),
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x1AC8F53A), AppColors.accent, Icons.movie_rounded),
        title: 'Generate Veo Videos',
        subtitle: 'Create improvement videos after each analysis',
        trailing: _buildToggle(_generateVeo,
            () => setState(() => _generateVeo = !_generateVeo)),
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x2660A5FA), const Color(0xFF60A5FA), Icons.tune_rounded),
        title: 'Analysis Sensitivity',
        subtitle: 'High — detect subtle form issues',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x1A34D399), const Color(0xFF34D399), Icons.person_rounded),
        title: 'Experience Level',
        subtitle: 'Intermediate',
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildNotificationRows() {
    return [
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26FF9A3C), AppColors.orange, Icons.notifications_rounded),
        title: 'Push Notifications',
        trailing: _buildToggle(_pushNotifications,
            () => setState(() => _pushNotifications = !_pushNotifications)),
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26EF4444), const Color(0xFFEF4444), Icons.local_fire_department_rounded),
        title: 'Streak Reminders',
        subtitle: 'Daily nudge to keep your streak alive',
        trailing: _buildToggle(_streakReminders,
            () => setState(() => _streakReminders = !_streakReminders)),
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26818CF8), const Color(0xFF818CF8), Icons.email_rounded),
        title: 'Weekly Report Email',
        trailing: _buildToggle(
            _weeklyEmail, () => setState(() => _weeklyEmail = !_weeklyEmail)),
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildPrefsRows() {
    return [
      _buildSettingRowDivided(
        icon: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0x990F0F1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(Icons.dark_mode_rounded,
              color: Colors.white70, size: 16),
        ),
        title: 'Appearance',
        subtitle: 'Dark Mode',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x1AC8F53A), AppColors.accent, Icons.straighten_rounded),
        title: 'Units',
        subtitle: 'Metric (kg, cm)',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x2660A5FA), const Color(0xFF60A5FA), Icons.language_rounded),
        title: 'Language',
        subtitle: 'English',
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildSupportRows() {
    return [
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x1A34D399), const Color(0xFF34D399), Icons.help_rounded),
        title: 'Help Center',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26FBB024), const Color(0xFFFBB024), Icons.star_rounded),
        title: 'Rate LiftLens',
      ),
      _buildSettingRowDivided(
        icon: _buildIconBox(const Color(0x26818CF8), const Color(0xFF818CF8), Icons.share_rounded),
        title: 'Share with Friends',
        isLast: true,
      ),
    ];
  }

  Widget _buildSignOut() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 16),
          SizedBox(width: 8),
          Text('Sign Out',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

extension _WidgetLet<T extends Widget> on T {
  W let<W>(W Function(T) block) => block(this);
}

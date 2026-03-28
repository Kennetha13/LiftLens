import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/video_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  if (apiKey.isEmpty) {
    runApp(const _MissingApiKeyApp());
    return;
  }
  runApp(const LiftLensApp());
}

class _MissingApiKeyApp extends StatelessWidget {
  const _MissingApiKeyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.key_off_rounded,
                    color: Colors.white38, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'API Key Missing',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Run the app with your Gemini API key:\n\n'
                  'flutter run \\\n  --dart-define=GEMINI_API_KEY=your_key\n\n'
                  'Get a free key at:\naistudio.google.com/apikey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiftLensApp extends StatelessWidget {
  const LiftLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiftLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Tab bar pages (Home, Progress, Profile)
  // Upload is accessed via FAB, Analysis & Video via navigation
  final List<Widget> _pages = const [
    HomeScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  // Extra pages accessible above the main tab bar
  static const _pageAnalysis = AnalysisScreen();
  static const _pageVideo = VideoScreen();
  static const _pageUpload = UploadScreen();
  static const _pageSettings = SettingsScreen();

  // 0=home 1=progress 2=profile
  // Special: 10=upload, 11=analysis, 12=video, 13=settings
  int _extendedIndex = 0;

  bool get _isExtended => _extendedIndex >= 10;

  Widget get _currentPage {
    switch (_extendedIndex) {
      case 10: return _pageUpload;
      case 11: return _pageAnalysis;
      case 12: return _pageVideo;
      case 13: return _pageSettings;
      default: return _pages[_currentIndex];
    }
  }

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
      _extendedIndex = index;
    });
  }

  void _onFabTap() {
    setState(() {
      _extendedIndex = 10; // Upload
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Main content — Positioned.fill gives it bounded height so
            // SingleChildScrollView inside each screen can actually scroll.
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: _currentPage,
                ),
              ),
            ),

            // Bottom Tab Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildTabBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF20D0D14),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(Icons.home_rounded, 'Home', 0),
              _buildTabItem(Icons.search_rounded, 'Explore', -1),
              _buildFAB(),
              _buildTabItem(Icons.bar_chart_rounded, 'Progress', 1),
              _buildTabItem(Icons.person_rounded, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    // For Explore tab (index == -1), navigate to Analysis page for demo
    final bool isActive = _extendedIndex < 10
        ? _currentIndex == index
        : false;

    return GestureDetector(
      onTap: () {
        if (index == -1) {
          // Explore -> show Analysis page as demo
          setState(() {
            _extendedIndex = 11;
          });
        } else {
          _onTabTap(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.accent : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _onFabTap,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded,
            color: Color(0xFF0D0D14), size: 28),
      ),
    );
  }
}

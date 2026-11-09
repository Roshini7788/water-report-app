import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_screen.dart';
import 'utils/app_colors.dart';
import 'widgets/custom_bottom_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AquaAlertApp());
}

class AquaAlertApp extends StatelessWidget {
  const AquaAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.darkBlue,
          surface: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          iconTheme: IconThemeData(color: AppColors.darkBlue),
          titleTextStyle: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScaffold(),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  // GlobalKeys to access child states when refreshing across tabs
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<MyReportsScreenState> _myReportsKey = GlobalKey<MyReportsScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Trigger reactive reload depending on the chosen tab
    if (index == 0) {
      _homeKey.currentState?.loadDashboardData();
    } else if (index == 2) {
      _myReportsKey.currentState?.loadReports();
    } else if (index == 3) {
      _profileKey.currentState?.loadProfileStats();
    }
  }

  void _onReportSubmitted() {
    // Switch to My Reports tab and trigger refreshes
    _onTabSelected(2);
    _homeKey.currentState?.loadDashboardData();
    _profileKey.currentState?.loadProfileStats();
  }

  void _onDataReset() {
    // Refresh all screens after data reset/clear
    _homeKey.currentState?.loadDashboardData();
    _myReportsKey.currentState?.loadReports();
    _profileKey.currentState?.loadProfileStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            key: _homeKey,
            onNavigateToTab: _onTabSelected,
          ),
          ReportScreen(
            onReportSubmitted: _onReportSubmitted,
          ),
          MyReportsScreen(
            key: _myReportsKey,
            onNavigateToTab: _onTabSelected,
          ),
          ProfileScreen(
            key: _profileKey,
            onDataReset: _onDataReset,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

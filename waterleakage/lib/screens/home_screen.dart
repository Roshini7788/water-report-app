import 'package:flutter/material.dart';
import '../models/leakage_report.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/report_card.dart';
import 'report_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<LeakageReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  /// Exposed method so the parent scaffold can trigger a reload when switching back to Home
  Future<void> loadDashboardData() async {
    setState(() => _isLoading = true);
    final reports = await StorageService.getReports();
    if (mounted) {
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  int get _totalCount => _reports.length;
  int get _pendingCount => _reports.where((r) => r.status == ReportStatus.pending).length;
  int get _resolvedCount => _reports.where((r) => r.status == ReportStatus.resolved).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: loadDashboardData,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Top App Header
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),

                    // Quick Action Hero Banner ("Report Water Leakage")
                    SliverToBoxAdapter(
                      child: _buildReportHeroBanner(),
                    ),

                    // 3 Metric Cards: Total, Pending, Resolved
                    SliverToBoxAdapter(
                      child: _buildSummaryMetrics(),
                    ),

                    // Recent Reports Header & List
                    SliverToBoxAdapter(
                      child: _buildRecentReportsSection(),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Civic header with AquaAlert branding and welcome slogan
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and App Name
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.darkBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AquaAlert',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Civic Water Guard',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Civic Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 15,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Citizen Portal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Slogan
          const Text(
            "Let's Keep Our Streets Leak-Free!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Report burst pipes, road leaks and overflowing valves in real-time.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Prominent Call-to-Action button to report leakage
  Widget _buildReportHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Spotted a Water Leakage?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Take a photo, capture the GPS location, and file a quick local report in less than a minute.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onNavigateToTab(1), // Switch to Report tab
              icon: const Icon(Icons.add_a_photo_rounded, size: 18),
              label: const Text(
                'Report Water Leakage',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Three summary metrics cards
  Widget _buildSummaryMetrics() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Total Reports',
                  count: _totalCount,
                  icon: Icons.folder_copy_rounded,
                  accentColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.white,
                  onTap: () => widget.onNavigateToTab(2), // Switch to My Reports
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardCard(
                  title: 'Pending',
                  count: _pendingCount,
                  icon: Icons.pending_actions_rounded,
                  accentColor: AppColors.statusPending,
                  backgroundColor: AppColors.white,
                  onTap: () => widget.onNavigateToTab(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardCard(
                  title: 'Resolved',
                  count: _resolvedCount,
                  icon: Icons.task_alt_rounded,
                  accentColor: AppColors.statusResolved,
                  backgroundColor: AppColors.white,
                  onTap: () => widget.onNavigateToTab(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Recent Reports preview list
  Widget _buildRecentReportsSection() {
    final recentReports = _reports.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_reports.isNotEmpty)
                TextButton(
                  onPressed: () => widget.onNavigateToTab(2), // Navigate to My Reports
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (recentReports.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentReports.length,
              itemBuilder: (context, index) {
                final report = recentReports[index];
                return ReportCard(
                  report: report,
                  onTap: () async {
                    final bool? changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailsScreen(report: report),
                      ),
                    );
                    if (changed == true) {
                      loadDashboardData();
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primaryBlue,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Water Leakage Reports Yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first citizen guardian to report a water issue in your neighborhood.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

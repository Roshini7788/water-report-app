import 'package:flutter/material.dart';
import '../models/leakage_report.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/report_card.dart';
import 'report_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const MyReportsScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<MyReportsScreen> createState() => MyReportsScreenState();
}

class MyReportsScreenState extends State<MyReportsScreen> {
  List<LeakageReport> _allReports = [];
  bool _isLoading = true;
  String _activeFilter = 'All'; // 'All', 'Pending', 'In Progress', 'Resolved'

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  /// Exposed method so parent scaffold can refresh list when switching tabs
  Future<void> loadReports() async {
    setState(() => _isLoading = true);
    final reports = await StorageService.getReports();
    if (mounted) {
      setState(() {
        _allReports = reports;
        _isLoading = false;
      });
    }
  }

  List<LeakageReport> get _filteredReports {
    if (_activeFilter == 'Pending') {
      return _allReports.where((r) => r.status == ReportStatus.pending).toList();
    } else if (_activeFilter == 'In Progress') {
      return _allReports.where((r) => r.status == ReportStatus.inProgress).toList();
    } else if (_activeFilter == 'Resolved') {
      return _allReports.where((r) => r.status == ReportStatus.resolved).toList();
    }
    return _allReports;
  }

  void _showQuickStatusChangeSheet(LeakageReport report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Status: ${report.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SIMULATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Demonstrate civic tracking progress across different stages:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.hourglass_top_rounded, color: AppColors.statusPending),
                title: const Text('Pending Review'),
                trailing: report.status == ReportStatus.pending
                    ? const Icon(Icons.check, color: AppColors.statusPending)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await StorageService.updateReportStatus(report.id, ReportStatus.pending);
                  loadReports();
                },
              ),
              ListTile(
                leading: const Icon(Icons.engineering_rounded, color: AppColors.statusInProgress),
                title: const Text('In Progress (Field Team Active)'),
                trailing: report.status == ReportStatus.inProgress
                    ? const Icon(Icons.check, color: AppColors.statusInProgress)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await StorageService.updateReportStatus(report.id, ReportStatus.inProgress);
                  loadReports();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_rounded, color: AppColors.statusResolved),
                title: const Text('Resolved & Closed'),
                trailing: report.status == ReportStatus.resolved
                    ? const Icon(Icons.check, color: AppColors.statusResolved)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await StorageService.updateReportStatus(report.id, ReportStatus.resolved);
                  loadReports();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            tooltip: 'Reload reports',
            onPressed: loadReports,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Bar
            _buildFilterPills(),

            // Reports List / Empty State
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: loadReports,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryBlue),
                      )
                    : _filteredReports.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            itemCount: _filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = _filteredReports[index];
                              return Column(
                                children: [
                                  ReportCard(
                                    report: report,
                                    onTap: () async {
                                      final bool? changed = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReportDetailsScreen(report: report),
                                        ),
                                      );
                                      if (changed == true) {
                                        loadReports();
                                      }
                                    },
                                  ),
                                  // Quick status simulation shortcut
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: TextButton.icon(
                                        onPressed: () => _showQuickStatusChangeSheet(report),
                                        icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                                        label: const Text(
                                          'Change Status (Demo)',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primaryBlue,
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => widget.onNavigateToTab(1), // Switch to Report screen
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Report', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All', 'Pending', 'In Progress', 'Resolved'];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _activeFilter == filter;
            int count = 0;
            if (filter == 'All') {
              count = _allReports.length;
            } else if (filter == 'Pending') {
              count = _allReports.where((r) => r.status == ReportStatus.pending).length;
            } else if (filter == 'In Progress') {
              count = _allReports.where((r) => r.status == ReportStatus.inProgress).length;
            } else if (filter == 'Resolved') {
              count = _allReports.where((r) => r.status == ReportStatus.resolved).length;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text('$filter ($count)'),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                ),
                backgroundColor: AppColors.background,
                selectedColor: AppColors.lightBlue,
                checkmarkColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                  ),
                ),
                onSelected: (_) {
                  setState(() => _activeFilter = filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _activeFilter == 'All'
                  ? 'No Reports Submitted'
                  : 'No $_activeFilter Reports Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _activeFilter == 'All'
                  ? 'You haven\'t submitted any water leakage incident reports yet.'
                  : 'There are currently no reports with status "$_activeFilter".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => widget.onNavigateToTab(1), // Switch to Report tab
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Submit a Report Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

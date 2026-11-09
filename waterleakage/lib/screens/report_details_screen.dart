import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/leakage_report.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class ReportDetailsScreen extends StatefulWidget {
  final LeakageReport report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late LeakageReport _currentReport;
  bool _hasModified = false;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  /// Updates status in local storage for demonstration purposes
  Future<void> _updateStatus(ReportStatus newStatus) async {
    final success = await StorageService.updateReportStatus(_currentReport.id, newStatus);
    if (success && mounted) {
      setState(() {
        _currentReport = _currentReport.copyWith(status: newStatus);
        _hasModified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_currentReport.statusLabel} [Simulated Demo]'),
          backgroundColor: _currentReport.statusColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show modal to switch status
  void _showStatusUpdateSheet() {
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
                  const Text(
                    'Simulate Municipal Status',
                    style: TextStyle(
                      fontSize: 18,
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
                      'DEMO MODE',
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
                'Select a workflow status to simulate civic field team actions:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildStatusOption(
                status: ReportStatus.pending,
                title: 'Pending Review',
                subtitle: 'Report submitted and queued for civic assessment.',
                color: AppColors.statusPending,
                icon: Icons.hourglass_top_rounded,
              ),
              _buildStatusOption(
                status: ReportStatus.inProgress,
                title: 'In Progress (Crew Dispatched)',
                subtitle: 'Maintenance unit assigned to inspect and excavate pipe.',
                color: AppColors.statusInProgress,
                icon: Icons.engineering_rounded,
              ),
              _buildStatusOption(
                status: ReportStatus.resolved,
                title: 'Resolved & Fixed',
                subtitle: 'Leakage repaired, pressure tested, and street secured.',
                color: AppColors.statusResolved,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required ReportStatus status,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final bool isSelected = _currentReport.status == status;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : AppColors.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? color : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: isSelected ? Icon(Icons.check_circle_rounded, color: color) : null,
        onTap: () {
          Navigator.pop(context);
          _updateStatus(status);
        },
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report?'),
        content: Text('Are you sure you want to remove report ${_currentReport.id}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteReport(_currentReport.id);
      if (mounted) {
        Navigator.pop(context, true); // Return true to signal deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (didPop) return;
        Navigator.pop(context, _hasModified);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkBlue),
            onPressed: () => Navigator.pop(context, _hasModified),
          ),
          title: Text(
            _currentReport.id,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              tooltip: 'Delete report',
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Header Preview
              _buildPhotoCard(),
              const SizedBox(height: 18),

              // Progress Stepper: Pending -> In Progress -> Resolved
              _buildProgressStepper(),
              const SizedBox(height: 20),

              // Status Change Action Bar (Demo Simulation)
              _buildStatusActionCard(),
              const SizedBox(height: 20),

              // Detailed Attributes Card
              _buildDetailsCard(),
              const SizedBox(height: 20),

              // Description Card
              _buildDescriptionCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    final imagePath = _currentReport.imagePath;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagePath != null && imagePath.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: kIsWeb
                    ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderPhoto())
                    : Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderPhoto()),
              ),
            )
          else
            _buildPlaceholderPhoto(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_currentReport.typeIcon, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _currentReport.leakageType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_damage_rounded, size: 48, color: AppColors.primaryBlue),
          SizedBox(height: 8),
          Text(
            'No Direct Photo Attached',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Standard municipal report format',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _currentReport.statusBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _currentReport.statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _currentReport.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _currentReport.statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _currentReport.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Progress indicator showing: Pending -> In Progress -> Resolved
  Widget _buildProgressStepper() {
    final statusIndex = _currentReport.status.index; // 0: pending, 1: inProgress, 2: resolved

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildStepNode(
                label: 'Pending',
                isCompleted: statusIndex >= 0,
                isActive: statusIndex == 0,
                color: AppColors.statusPending,
                icon: Icons.hourglass_top_rounded,
              ),
              _buildStepConnector(isCompleted: statusIndex >= 1, color: AppColors.statusInProgress),
              _buildStepNode(
                label: 'In Progress',
                isCompleted: statusIndex >= 1,
                isActive: statusIndex == 1,
                color: AppColors.statusInProgress,
                icon: Icons.engineering_rounded,
              ),
              _buildStepConnector(isCompleted: statusIndex >= 2, color: AppColors.statusResolved),
              _buildStepNode(
                label: 'Resolved',
                isCompleted: statusIndex >= 2,
                isActive: statusIndex == 2,
                color: AppColors.statusResolved,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required String label,
    required bool isCompleted,
    required bool isActive,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCompleted ? color : AppColors.borderLight,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? color : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isCompleted, required Color color}) {
    return Container(
      width: 24,
      height: 3,
      color: isCompleted ? color : AppColors.borderLight,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildStatusActionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulate Authority Workflow',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Change status to test civic lifecycle',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showStatusUpdateSheet,
            icon: const Icon(Icons.edit_rounded, size: 14),
            label: const Text('Change (Demo)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.confirmation_number_outlined,
            title: 'Report Reference',
            value: _currentReport.id,
          ),
          const Divider(height: 18, color: AppColors.divider),
          _buildInfoRow(
            icon: Icons.category_outlined,
            title: 'Leakage Type',
            value: _currentReport.leakageType,
          ),
          const Divider(height: 18, color: AppColors.divider),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: _currentReport.location,
          ),
          if (_currentReport.formattedCoordinates != null) ...[
            const Divider(height: 18, color: AppColors.divider),
            _buildInfoRow(
              icon: Icons.gps_fixed_rounded,
              title: 'GPS Coordinates',
              value: _currentReport.formattedCoordinates!,
            ),
          ],
          const Divider(height: 18, color: AppColors.divider),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Submitted On',
            value: _currentReport.formattedDateTime,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Citizen Problem Description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentReport.description.isNotEmpty
                ? _currentReport.description
                : 'No description provided.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

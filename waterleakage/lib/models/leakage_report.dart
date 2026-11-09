import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';

enum ReportStatus {
  pending,
  inProgress,
  resolved,
}

class LeakageReport {
  final String id;
  final String leakageType;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final String? imagePath;
  final DateTime date;
  final ReportStatus status;

  LeakageReport({
    required this.id,
    required this.leakageType,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    this.imagePath,
    required this.date,
    this.status = ReportStatus.pending,
  });

  /// Human-friendly display label for the status
  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
    }
  }

  /// Foreground color for badge and highlights
  Color get statusColor {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.statusPending;
      case ReportStatus.inProgress:
        return AppColors.statusInProgress;
      case ReportStatus.resolved:
        return AppColors.statusResolved;
    }
  }

  /// Soft background color for badge
  Color get statusBgColor {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.statusPendingBg;
      case ReportStatus.inProgress:
        return AppColors.statusInProgressBg;
      case ReportStatus.resolved:
        return AppColors.statusResolvedBg;
    }
  }

  /// Icon representing the status
  IconData get statusIcon {
    switch (status) {
      case ReportStatus.pending:
        return Icons.hourglass_top_rounded;
      case ReportStatus.inProgress:
        return Icons.engineering_rounded;
      case ReportStatus.resolved:
        return Icons.check_circle_rounded;
    }
  }

  /// Icon representing the leakage type
  IconData get typeIcon {
    switch (leakageType.toLowerCase()) {
      case 'pipe leakage':
        return Icons.plumbing_rounded;
      case 'roadside water leakage':
        return Icons.alt_route_rounded;
      case 'overflowing water':
        return Icons.waves_rounded;
      case 'damaged water pipeline':
        return Icons.warning_amber_rounded;
      default:
        return Icons.water_drop_rounded;
    }
  }

  /// Formatted date string for display in cards
  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formatted date and time string for detail view
  String get formattedDateTime {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  /// Formatted GPS coordinates if available
  String? get formattedCoordinates {
    if (latitude != null && longitude != null) {
      final latSuffix = latitude! >= 0 ? 'N' : 'S';
      final lonSuffix = longitude! >= 0 ? 'E' : 'W';
      return '${latitude!.abs().toStringAsFixed(4)}° $latSuffix, ${longitude!.abs().toStringAsFixed(4)}° $lonSuffix';
    }
    return null;
  }

  /// Create a copy with modified fields
  LeakageReport copyWith({
    String? id,
    String? leakageType,
    String? location,
    double? latitude,
    double? longitude,
    String? description,
    String? imagePath,
    DateTime? date,
    ReportStatus? status,
  }) {
    return LeakageReport(
      id: id ?? this.id,
      leakageType: leakageType ?? this.leakageType,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  /// Serialize to Map for SharedPreferences JSON storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leakageType': leakageType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  /// Deserialize from Map
  factory LeakageReport.fromJson(Map<String, dynamic> json) {
    ReportStatus parsedStatus = ReportStatus.pending;
    try {
      parsedStatus = ReportStatus.values.byName(json['status'] ?? 'pending');
    } catch (_) {
      parsedStatus = ReportStatus.pending;
    }

    return LeakageReport(
      id: json['id'] as String,
      leakageType: json['leakageType'] as String? ?? 'Pipe Leakage',
      location: json['location'] as String? ?? 'Unknown Location',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: parsedStatus,
    );
  }
}

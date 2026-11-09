import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leakage_report.dart';

class StorageService {
  static const String _storageKey = 'aqua_alert_reports_v1';
  static const String _initializedKey = 'aqua_alert_has_seeded_sample_data';

  /// Fetch all stored leakage reports.
  /// If this is the first app launch, seeds realistic sample data.
  static Future<List<LeakageReport>> getReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeeded = prefs.getBool(_initializedKey) ?? false;

      if (!hasSeeded) {
        // Pre-populate with realistic citizen reports for demonstration
        final initialReports = _getSeedReports();
        await saveAllReports(initialReports);
        await prefs.setBool(_initializedKey, true);
        return initialReports;
      }

      final String? reportsJsonString = prefs.getString(_storageKey);
      if (reportsJsonString == null || reportsJsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(reportsJsonString) as List<dynamic>;
      final List<LeakageReport> reports = decodedList
          .map((item) => LeakageReport.fromJson(item as Map<String, dynamic>))
          .toList();

      // Return sorted with newest first
      reports.sort((a, b) => b.date.compareTo(a.date));
      return reports;
    } catch (e) {
      debugPrint('Error loading reports from SharedPreferences: $e');
      return [];
    }
  }

  /// Add a newly created report to storage
  static Future<bool> addReport(LeakageReport report) async {
    try {
      final reports = await getReports();
      reports.insert(0, report);
      return await saveAllReports(reports);
    } catch (e) {
      debugPrint('Error adding report: $e');
      return false;
    }
  }

  /// Update the status of an existing report (e.g., for demo progression)
  static Future<bool> updateReportStatus(String reportId, ReportStatus newStatus) async {
    try {
      final reports = await getReports();
      final index = reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        reports[index] = reports[index].copyWith(status: newStatus);
        return await saveAllReports(reports);
      }
      return false;
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return false;
    }
  }

  /// Delete a report from local storage
  static Future<bool> deleteReport(String reportId) async {
    try {
      final reports = await getReports();
      reports.removeWhere((r) => r.id == reportId);
      return await saveAllReports(reports);
    } catch (e) {
      debugPrint('Error deleting report: $e');
      return false;
    }
  }

  /// Saves the full list of reports into SharedPreferences
  static Future<bool> saveAllReports(List<LeakageReport> reports) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = reports.map((r) => r.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving reports to SharedPreferences: $e');
      return false;
    }
  }

  /// Generates a unique, professional civic report ID
  static String generateReportId() {
    final now = DateTime.now();
    final randomDigits = (1000 + (now.millisecond * 9) % 9000).toString();
    return 'AQUA-${now.year}-${now.month.toString().padLeft(2, '0')}$randomDigits';
  }

  /// Resets storage back to initial sample reports (helpful for testing/demos)
  static Future<List<LeakageReport>> resetToSampleData() async {
    final samples = _getSeedReports();
    await saveAllReports(samples);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initializedKey, true);
    return samples;
  }

  /// Clear all stored reports
  static Future<bool> clearAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_storageKey);
  }

  /// Pre-seeded demonstration reports with all 3 statuses
  static List<LeakageReport> _getSeedReports() {
    final now = DateTime.now();
    return [
      LeakageReport(
        id: 'AQUA-2026-0842',
        leakageType: 'Damaged Water Pipeline',
        location: '74 Elm Street, Near Central Library',
        latitude: 37.7749,
        longitude: -122.4194,
        description: 'Main municipal pipeline has burst near the pedestrian crosswalk. Water is spraying onto the pavement with significant runoff.',
        imagePath: null,
        date: now.subtract(const Duration(hours: 3)),
        status: ReportStatus.pending,
      ),
      LeakageReport(
        id: 'AQUA-2026-0719',
        leakageType: 'Roadside Water Leakage',
        location: 'Corner of 4th Avenue & Pine Street',
        latitude: 37.7833,
        longitude: -122.4167,
        description: 'Water has been bubbling up from beneath the asphalt for two days. Road surface is starting to crack and pool.',
        imagePath: null,
        date: now.subtract(const Duration(days: 1, hours: 5)),
        status: ReportStatus.inProgress,
      ),
      LeakageReport(
        id: 'AQUA-2026-0604',
        leakageType: 'Overflowing Water',
        location: 'Riverside Community Park, North Gate',
        latitude: 37.7690,
        longitude: -122.4467,
        description: 'Public utility valve was leaking into the jogging track. Maintenance crew has replaced the pressure valve and secured the casing.',
        imagePath: null,
        date: now.subtract(const Duration(days: 3, hours: 2)),
        status: ReportStatus.resolved,
      ),
    ];
  }
}

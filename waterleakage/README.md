# AquaAlert – Water Leakage Reporting Platform

**AquaAlert** is a citizen-focused, civic-utility mobile application built with **Flutter & Material 3**. It empowers residents to actively identify, photograph, report, and monitor water leakages in streets, residential areas, and public infrastructure.

---

## 📱 Application Overview & Key Features

1. **Screen 1: Home Dashboard (`home_screen.dart`)**
   - AquaAlert civic emblem & branding.
   - Welcome motto: *"Let's Keep Our Streets Leak-Free!"*
   - Prominent **"Report Water Leakage"** call-to-action button.
   - Summary statistics cards: **Total Reports**, **Pending Reports**, **Resolved Reports**.
   - Recent Reports list with quick status tags, date, and navigation to details.

2. **Screen 2: Report Leakage (`report_screen.dart`)**
   - **Photo Upload**: Capture evidence using the camera or select from the photo gallery with live image preview.
   - **Leakage Category**: Pipe Leakage, Roadside Water Leakage, Overflowing Water, Damaged Water Pipeline, or Other.
   - **Location**: Manual address input or instant **GPS Pinpoint** via device location services.
   - **Problem Description**: Multiline details field for clear civic repair descriptions.
   - **Form Validation & Local Persistence**: Generates unique IDs (e.g., `AQUA-2026-XXXX`) and saves locally.

3. **Screen 3: My Reports (`my_reports_screen.dart`)**
   - Complete history of all submitted water leakage incidents.
   - Status badge indicator:
     - 🟠 **Pending** (Orange)
     - 🔵 **In Progress** (Blue)
     - 🟢 **Resolved** (Green)
   - Filter chips to view All, Pending, In Progress, or Resolved reports.
   - **[Demo] Status Simulator**: Allows testers to simulate municipal workflow transitions (`Pending` ➔ `In Progress` ➔ `Resolved`).

4. **Screen 4: Report Details (`report_details_screen.dart`)**
   - Photographic evidence banner with fallback handler.
   - Visual 3-stage progress timeline stepper (`Pending` ➔ `In Progress` ➔ `Resolved`).
   - Incident reference ID, leakage category, landmark address, and GPS coordinates.
   - Submission date, timestamp, and full citizen problem description.
   - Municipal status change simulator sheet.
   - Delete report functionality.

5. **Screen 5: Citizen Profile (`profile_screen.dart`)**
   - User profile identity ("Alex Morgan - Community Water Guardian").
   - Impact metrics (Total submitted, Resolved count, Pending count).
   - "About AquaAlert" mission statement and municipal disclaimer.
   - **Demo Tools**: Reset sample reports and clear local storage.

---

## 📂 Project Structure

```
waterleakage/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml       # Camera, Storage, GPS permissions
│   │   │   └── kotlin/com/aquaalert/waterleakage/MainActivity.kt
│   │   └── build.gradle                  # MinSDK 21, TargetSDK 34
│   ├── build.gradle
│   └── settings.gradle
├── web/
│   └── index.html                        # Web preview configuration
├── lib/
│   ├── main.dart                         # App entrypoint, Material 3 theme & tab navigation scaffold
│   ├── models/
│   │   └── leakage_report.dart           # LeakageReport data model with JSON serialization & status logic
│   ├── screens/
│   │   ├── home_screen.dart              # Screen 1: Dashboard with metrics and recent reports
│   │   ├── report_screen.dart            # Screen 2: Form with photo picker, GPS fetcher, validation
│   │   ├── my_reports_screen.dart        # Screen 3: List of reports with status filter chips & demo switcher
│   │   ├── report_details_screen.dart    # Screen 4: Detailed view with 3-step progress indicator
│   │   └── profile_screen.dart           # Screen 5: Citizen profile, stats, about section, sample data reset
│   ├── widgets/
│   │   ├── dashboard_card.dart           # Summary metric cards (Total, Pending, Resolved)
│   │   ├── report_card.dart              # Reusable civic report card with badge & thumbnails
│   │   └── custom_bottom_navigation.dart # 4-tab bottom navigation bar
│   ├── services/
│   │   ├── storage_service.dart          # SharedPreferences persistence layer with sample data seeding
│   │   └── location_service.dart         # Geolocator integration with permission checking & coordinates
│   └── utils/
│       └── app_colors.dart               # Palette: Primary Blue (#1565C0), Dark Blue (#0D2B45), etc.
├── pubspec.yaml                          # Dependencies
└── README.md                             # Documentation & setup instructions
```

---

## 📦 Package Explanations

| Package | Version | Purpose in AquaAlert |
| :--- | :--- | :--- |
| `flutter` | SDK | Core Flutter framework for cross-platform UI rendering. |
| `image_picker` | `^1.1.2` | Allows citizens to capture photos directly using their device camera or select images from the device gallery. |
| `geolocator` | `^13.0.2` | Accesses device GPS hardware to pinpoint exact latitude and longitude coordinates with permission handling. |
| `shared_preferences` | `^2.3.5` | Provides persistent key-value storage to store submitted reports locally as JSON across application restarts. |
| `intl` | `^0.19.0` | Formats dates, times, and timestamps into readable strings (e.g., `Nov 09, 2026 • 02:30 PM`). |
| `cupertino_icons` | `^1.0.8` | Standard complementary asset icons for clean UI elements. |

---

## 🔍 Core Mechanisms Explained

### 1. How Image Picking Works
In `lib/screens/report_screen.dart`:
```dart
final ImagePicker _picker = ImagePicker();

// Capture from camera:
final XFile? photo = await _picker.pickImage(
  source: ImageSource.camera,
  maxWidth: 1200,
  maxHeight: 1200,
  imageQuality: 85,
);

// Or choose from photo gallery:
final XFile? photo = await _picker.pickImage(
  source: ImageSource.gallery,
);
```
- When an image is picked, its local path `photo.path` is stored in the state.
- The UI previews the image using `Image.file(File(path))` (or `Image.network` on web).
- When submitting the report, the path is serialized in the `LeakageReport` object.

### 2. How GPS Location is Obtained
In `lib/services/location_service.dart`:
1. **Service Check**: Validates if device GPS is switched on using `Geolocator.isLocationServiceEnabled()`.
2. **Permission Check**: Verifies `Geolocator.checkPermission()`. If denied, invokes `Geolocator.requestPermission()`.
3. **Position Query**: Acquires the device location:
   ```dart
   final Position position = await Geolocator.getCurrentPosition(
     locationSettings: const LocationSettings(
       accuracy: LocationAccuracy.high,
       timeLimit: Duration(seconds: 12),
     ),
   );
   ```
4. Coordinates are formatted into human-readable notation (e.g., `37.7749° N, 122.4194° W`) and auto-filled into the location field.

### 3. How Reports are Stored Locally
In `lib/services/storage_service.dart`:
- Reports are represented as typed Dart objects (`LeakageReport`) and converted to/from JSON Maps via `toJson()` and `fromJson()`.
- The list of JSON Maps is serialized as a JSON string and saved under the key `'aqua_alert_reports_v1'` using `SharedPreferences`:
  ```dart
  final prefs = await SharedPreferences.getInstance();
  final String encoded = jsonEncode(reports.map((r) => r.toJson()).toList());
  await prefs.setString('aqua_alert_reports_v1', encoded);
  ```
- **Automatic Seed Data**: On first run (or via the **Reset Samples** button in Profile), realistic demonstration reports are seeded so the dashboard is immediately populated.
- **State Coordination**: When reports are added, modified, or deleted, `StorageService` writes to `SharedPreferences`, and child screens automatically refresh their counters.

---

## 🚀 Commands to Run the Project

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Android Device / Emulator
Ensure your Android emulator or physical device is connected with USB debugging enabled:
```bash
flutter run
```

### 3. Run on Chrome (Web Preview)
AquaAlert is also fully compatible with Chrome:
```bash
flutter run -d chrome
```

### 4. Run on Windows Desktop
```bash
flutter run -d windows
```

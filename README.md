# Derby Disorder: The Chaos Cup - Native Host App

A cross-platform Flutter application for hosting Derby Disorder betting games.

## Platforms Supported

- **Android TV** (primary target) - Optimized for 10-foot UI with D-pad navigation
- **Linux** - GTK-based desktop application
- **macOS** - Native macOS application
- **Windows** - Native Windows application

## Features

- Real-time race visualization with custom 2D graphics
- Socket.io integration for live game updates
- Full game state management (Lobby, Paddock, Wager, Sabotage, Racing, Results)
- Player and race leaderboards
- TV-friendly navigation and controls
- OTA update mechanism support

## Prerequisites

- Flutter SDK 3.5.4 or later
- For Android: Android SDK with API level 21+
- For Linux: GTK 3.0 development libraries
- For macOS: Xcode 14+ with command line tools
- For Windows: Visual Studio 2019+ with C++ desktop development

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run in Development

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d linux
flutter run -d macos
flutter run -d windows
flutter run -d android
```

### 3. Build for Release

```bash
# Android APK (for TV)
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── game_state.dart
│   ├── player.dart
│   ├── participant.dart
│   ├── bet.dart
│   ├── race_snapshot.dart
│   ├── race_result.dart
│   ├── item.dart
│   ├── odds.dart
│   └── room.dart
├── services/
│   ├── socket_service.dart      # Socket.io client
│   ├── api_service.dart         # HTTP API client
│   └── update_service.dart      # OTA updates
├── providers/
│   ├── room_provider.dart       # Room state management
│   └── race_provider.dart       # Race state management
├── widgets/
│   ├── room_code_display.dart
│   ├── phase_indicator.dart
│   ├── player_leaderboard.dart
│   ├── race_leaderboard.dart
│   ├── chaos_meter.dart
│   ├── lobby_screen.dart
│   ├── skip_phase_button.dart
│   ├── race_results_overlay.dart
│   ├── tv_focusable.dart
│   └── update_dialog.dart
├── graphics/
│   ├── race_track_painter.dart  # Custom race track rendering
│   └── race_view.dart           # Race visualization widget
├── screens/
│   └── home_screen.dart         # Main screen
└── utils/
    ├── constants.dart
    ├── theme.dart               # Neon arcade theme
    └── performance.dart         # Performance utilities
```

## Configuration

### Server URL

Update the socket server URL in `lib/utils/constants.dart`:

```dart
static const String defaultSocketUrl = 'http://your-server:3001';
```

### Update Server

Configure OTA updates by setting the update server URL:

```dart
await updateService.setUpdateServerUrl('https://updates.your-domain.com');
```

## TV Navigation

The app supports TV remote navigation:

- **D-pad**: Navigate between UI elements
- **Select/Enter**: Activate focused element
- **Back**: Go back/close dialogs

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Android TV

Ensure your `AndroidManifest.xml` includes:

```xml
<uses-feature android:name="android.software.leanback" android:required="false"/>
<uses-feature android:name="android.hardware.touchscreen" android:required="false"/>

<intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LEANBACK_LAUNCHER"/>
</intent-filter>
```

## License

See the main project README for license information.

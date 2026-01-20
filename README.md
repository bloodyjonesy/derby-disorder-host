# Derby Disorder: The Chaos Cup - Host Application

The **TV/Display Host** application for Derby Disorder - a chaotic multiplayer party betting game. This Flutter app runs on the main display (TV, monitor, projector) and shows the race animations, leaderboards, and game state.

## 🎮 Game Overview

Derby Disorder is a multiplayer party game where players bet on silly races between ridiculous characters. The host app displays:
- Race animations and participant positions
- Player leaderboards and balances
- Betting phases and timers
- Chaos events and special effects
- Tournament standings (v2)

## 📋 Prerequisites

### Flutter SDK
- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher

Install Flutter: https://docs.flutter.dev/get-started/install

### Platform-Specific Requirements

#### Linux
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

#### Windows
- Visual Studio 2022 with "Desktop development with C++" workload
- Windows 10 SDK (10.0.17763.0 or later)

#### macOS
- Xcode 15 or later
- CocoaPods: `sudo gem install cocoapods`

#### Android
- Android Studio with Android SDK
- Android SDK Build-Tools 33.0.0+
- Android NDK (install via Android Studio SDK Manager)

#### iOS/tvOS
- Xcode 15 or later
- CocoaPods: `sudo gem install cocoapods`
- Apple Developer account (for device deployment)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/bloodyjonesy/derby-disorder-host.git
cd derby-disorder-host
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Server URL
Edit `lib/utils/constants.dart` and set your server URL:
```dart
static const String defaultSocketUrl = 'http://YOUR_SERVER_IP:3001';
static const String defaultApiUrl = 'http://YOUR_SERVER_IP:3001';
```

### 4. Run in Development
```bash
# Linux
flutter run -d linux

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Android (with device/emulator connected)
flutter run -d android

# iOS (with device/simulator)
flutter run -d ios
```

## 🏗️ Building for Release

### Linux
```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

Run the app:
```bash
./build/linux/x64/release/bundle/host_native
```

### Windows
```bash
flutter build windows --release
```
Output: `build/windows/x64/runner/Release/`

Run: `host_native.exe`

### macOS
```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/host_native.app`

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires Xcode & Apple Developer account)
```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

### tvOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Change the destination to "Any tvOS Device"
3. Update bundle identifier and provisioning profile for tvOS
4. Build and archive

**Note:** Flutter doesn't officially support tvOS, but the app can be adapted to run on Apple TV with some modifications to the iOS target.

## 📦 Creating Distribution Packages

### Linux AppImage
```bash
# Install appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# Create AppImage (after building)
./appimagetool-x86_64.AppImage build/linux/x64/release/bundle DerbyDisorder-x86_64.AppImage
```

### Windows Installer (MSIX)
```bash
flutter pub run msix:create
```
Add to `pubspec.yaml`:
```yaml
msix_config:
  display_name: Derby Disorder Host
  publisher_display_name: Your Name
  identity_name: com.derbydisorder.host
  msix_version: 1.0.0.0
```

### macOS DMG
```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "Derby Disorder Host" \
  --window-size 600 400 \
  --app-drop-link 400 100 \
  "DerbyDisorder-Host.dmg" \
  "build/macos/Build/Products/Release/host_native.app"
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file (optional):
```
SOCKET_URL=http://your-server:3001
API_URL=http://your-server:3001
```

### Build Flavors
For different server environments:
```bash
# Development
flutter run --dart-define=ENV=dev

# Production
flutter build linux --release --dart-define=ENV=prod
```

## 🎯 Platform-Specific Notes

### Android TV / Fire TV
The app includes TV-optimized navigation with D-pad support:
- Use arrow keys to navigate
- Enter/Select to confirm
- Back to go back

Build for Android TV:
```bash
flutter build apk --release --target-platform android-arm64
```

### Raspberry Pi
For Raspberry Pi 4/5 (ARM64):
```bash
flutter build linux --release
# Copy bundle to Pi and run
```

### Web (Experimental)
```bash
flutter build web --release
```
Output: `build/web/`

**Note:** Web build may have limitations with socket connections depending on server CORS settings.

## 📁 Project Structure

```
lib/
├── graphics/          # Race track rendering
├── models/            # Data models
├── providers/         # State management
├── screens/           # Main screens
├── services/          # API & Socket services
├── utils/             # Constants, theme, helpers
└── widgets/           # Reusable UI components
```

## 🐛 Troubleshooting

### Linux: GTK errors
```bash
export GDK_BACKEND=x11
./host_native
```

### macOS: Code signing issues
```bash
codesign --deep --force --sign - build/macos/Build/Products/Release/host_native.app
```

### Android: Build failures
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Socket connection issues
- Ensure server is running on the correct port
- Check firewall rules
- Verify the server URL in `constants.dart`

## 📄 License

Private - All rights reserved.

## 🔗 Related Repositories

- **Server:** https://github.com/bloodyjonesy/derby-disorder-server
- **Player App:** https://github.com/bloodyjonesy/derby-disorder-player

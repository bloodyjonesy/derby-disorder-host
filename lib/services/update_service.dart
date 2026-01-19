import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Update information from the server
class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool isRequired;
  final DateTime releaseDate;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isRequired,
    required this.releaseDate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      releaseNotes: json['releaseNotes'] as String? ?? '',
      isRequired: json['isRequired'] as bool? ?? false,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
    );
  }
}

/// Service for managing app updates
class UpdateService extends ChangeNotifier {
  static const String _updateUrlKey = 'update_server_url';
  static const String _lastCheckKey = 'last_update_check';
  static const String _skippedVersionKey = 'skipped_version';

  String _updateServerUrl = '';
  String _currentVersion = '1.0.0';
  UpdateInfo? _availableUpdate;
  bool _isChecking = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _error;

  // Getters
  UpdateInfo? get availableUpdate => _availableUpdate;
  bool get hasUpdate => _availableUpdate != null;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get error => _error;

  /// Initialize the update service
  Future<void> initialize({
    required String currentVersion,
    String? updateServerUrl,
  }) async {
    _currentVersion = currentVersion;

    final prefs = await SharedPreferences.getInstance();
    _updateServerUrl =
        updateServerUrl ?? prefs.getString(_updateUrlKey) ?? '';
  }

  /// Set the update server URL
  Future<void> setUpdateServerUrl(String url) async {
    _updateServerUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_updateUrlKey, url);
  }

  /// Check for updates from the server
  Future<UpdateInfo?> checkForUpdates() async {
    if (_updateServerUrl.isEmpty) {
      debugPrint('Update server URL not configured');
      return null;
    }

    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      final platform = _getPlatformName();
      final response = await http.get(
        Uri.parse('$_updateServerUrl/api/updates/check?'
            'platform=$platform&'
            'currentVersion=$_currentVersion'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['hasUpdate'] == true) {
          _availableUpdate = UpdateInfo.fromJson(
            data['update'] as Map<String, dynamic>,
          );

          // Check if user skipped this version
          final prefs = await SharedPreferences.getInstance();
          final skippedVersion = prefs.getString(_skippedVersionKey);
          if (skippedVersion == _availableUpdate!.version &&
              !_availableUpdate!.isRequired) {
            _availableUpdate = null;
          }

          await prefs.setString(
            _lastCheckKey,
            DateTime.now().toIso8601String(),
          );
        } else {
          _availableUpdate = null;
        }
      } else if (response.statusCode == 204) {
        // No update available
        _availableUpdate = null;
      } else {
        throw Exception('Failed to check for updates: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error checking for updates: $e');
    }

    _isChecking = false;
    notifyListeners();
    return _availableUpdate;
  }

  /// Skip the current available update
  Future<void> skipUpdate() async {
    if (_availableUpdate != null && !_availableUpdate!.isRequired) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_skippedVersionKey, _availableUpdate!.version);
      _availableUpdate = null;
      notifyListeners();
    }
  }

  /// Download the update file (for desktop platforms)
  Future<String?> downloadUpdate() async {
    if (_availableUpdate == null) return null;

    _isDownloading = true;
    _downloadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(_availableUpdate!.downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download update: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _getUpdateFileName();
      final file = File('${directory.path}/$fileName');
      final sink = file.openWrite();

      int downloaded = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (contentLength > 0) {
          _downloadProgress = downloaded / contentLength;
          notifyListeners();
        }
      }

      await sink.close();
      client.close();

      _isDownloading = false;
      _downloadProgress = 1.0;
      notifyListeners();

      return file.path;
    } catch (e) {
      _error = e.toString();
      _isDownloading = false;
      notifyListeners();
      debugPrint('Error downloading update: $e');
      return null;
    }
  }

  /// Get the platform name for update checking
  String _getPlatformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    return 'unknown';
  }

  /// Get the appropriate file name for the update
  String _getUpdateFileName() {
    final version = _availableUpdate?.version ?? 'latest';
    if (Platform.isAndroid) return 'derby-disorder-$version.apk';
    if (Platform.isLinux) return 'derby-disorder-$version.AppImage';
    if (Platform.isMacOS) return 'derby-disorder-$version.dmg';
    if (Platform.isWindows) return 'derby-disorder-$version-setup.exe';
    return 'derby-disorder-$version';
  }

  /// Check if we should prompt for update
  Future<bool> shouldCheckForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckStr = prefs.getString(_lastCheckKey);

    if (lastCheckStr == null) return true;

    final lastCheck = DateTime.parse(lastCheckStr);
    final hoursSinceLastCheck = DateTime.now().difference(lastCheck).inHours;

    // Check once per day
    return hoursSinceLastCheck >= 24;
  }
}

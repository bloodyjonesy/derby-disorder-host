import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

/// Provider for managing game settings
class SettingsProvider extends ChangeNotifier {
  GameSettings _settings = const GameSettings();
  bool _isLoaded = false;

  GameSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  // Convenience getters
  bool get isPartyMode => _settings.gameMode == GameMode.party || 
      (_settings.gameMode == GameMode.custom && _hasAnyPartyFeature);
  
  bool get _hasAnyPartyFeature =>
      _settings.enableRivalries ||
      _settings.enableSideBets ||
      _settings.enableDrinkingCards ||
      _settings.enablePunishmentWheel ||
      _settings.enableHotSeat ||
      _settings.enableDrinkTracker;

  // Individual feature checks
  bool get rivalriesEnabled => isPartyMode && _settings.enableRivalries;
  bool get sideBetsEnabled => isPartyMode && _settings.enableSideBets;
  bool get drinkingCardsEnabled => isPartyMode && _settings.enableDrinkingCards;
  bool get punishmentWheelEnabled => isPartyMode && _settings.enablePunishmentWheel;
  bool get hotSeatEnabled => isPartyMode && _settings.enableHotSeat;
  bool get drinkTrackerEnabled => isPartyMode && _settings.enableDrinkTracker;

  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('game_settings');
      if (json != null) {
        _settings = GameSettings.fromJson(jsonDecode(json));
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    _isLoaded = true;
    notifyListeners();
  }

  /// Save settings to storage
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_settings', jsonEncode(_settings.toJson()));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Update settings
  void updateSettings(GameSettings newSettings) {
    _settings = newSettings;
    saveSettings();
    notifyListeners();
  }

  /// Reset to default
  void resetToDefault() {
    _settings = const GameSettings();
    saveSettings();
    notifyListeners();
  }

  /// Set party mode
  void setPartyMode() {
    _settings = GameSettings.partyMode();
    saveSettings();
    notifyListeners();
  }

  /// Set regular mode
  void setRegularMode() {
    _settings = GameSettings.regularMode();
    saveSettings();
    notifyListeners();
  }

  /// Toggle endless mode
  void toggleEndless() {
    _settings = _settings.copyWith(
      maxRaces: _settings.maxRaces == 0 ? 5 : 0,
    );
    saveSettings();
    notifyListeners();
  }
}

/// Application constants
class AppConstants {
  AppConstants._();

  /// Server URL for production
  static const String defaultSocketUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'https://api.ddcc.pw',
  );

  /// Player join URL
  static const String playerJoinUrl = 'ddcc.pw';

  /// Application name
  static const String appName = 'Derby Disorder: The Chaos Cup';

  /// Race track dimensions
  static const double trackRadius = 25.0;
  static const double raceLength = 100.0;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Phase timer defaults
  static const int paddockDuration = 60;
  static const int wagerDuration = 60;
  static const int sabotageDuration = 20;
  static const int resultsDuration = 30;
}

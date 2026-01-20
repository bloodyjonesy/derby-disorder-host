import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Settings screen for configuring game options
class SettingsScreen extends StatefulWidget {
  final GameSettings initialSettings;
  final Function(GameSettings) onSave;
  final VoidCallback onCancel;

  const SettingsScreen({
    super.key,
    required this.initialSettings,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _setGameMode(GameMode mode) {
    setState(() {
      switch (mode) {
        case GameMode.regular:
          _settings = GameSettings.regularMode().copyWith(
            maxRaces: _settings.maxRaces,
            startingBalance: _settings.startingBalance,
          );
          break;
        case GameMode.party:
          _settings = GameSettings.partyMode().copyWith(
            maxRaces: _settings.maxRaces,
            startingBalance: _settings.startingBalance,
          );
          break;
        case GameMode.custom:
          _settings = _settings.copyWith(gameMode: GameMode.custom);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A2E),
            Color(0xFF16213E),
            Color(0xFF0A0A1A),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onCancel,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '⚙️ GAME SETTINGS',
                    style: AppTheme.neonText(
                      color: AppTheme.neonCyan,
                      fontSize: 28,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => widget.onSave(_settings),
                    icon: const Icon(Icons.check),
                    label: const Text('SAVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Mode Selection
                    _buildSection(
                      title: '🎮 GAME MODE',
                      child: Row(
                        children: [
                          _buildModeCard(
                            mode: GameMode.regular,
                            title: 'REGULAR',
                            description: 'Classic racing\nNo drinking',
                            emoji: '🏇',
                            color: AppTheme.neonCyan,
                          ),
                          const SizedBox(width: 16),
                          _buildModeCard(
                            mode: GameMode.party,
                            title: 'PARTY',
                            description: 'Full chaos!\nAll features',
                            emoji: '🎉',
                            color: AppTheme.neonPink,
                          ),
                          const SizedBox(width: 16),
                          _buildModeCard(
                            mode: GameMode.custom,
                            title: 'CUSTOM',
                            description: 'Pick & choose\nfeatures',
                            emoji: '🔧',
                            color: AppTheme.neonYellow,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Race Settings
                    _buildSection(
                      title: '🏁 RACE SETTINGS',
                      child: Column(
                        children: [
                          _buildSliderSetting(
                            label: 'Number of Races',
                            value: _settings.maxRaces.toDouble(),
                            min: 0,
                            max: 20,
                            divisions: 20,
                            displayValue: _settings.maxRaces == 0
                                ? '∞ Endless'
                                : '${_settings.maxRaces} races',
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(maxRaces: v.toInt());
                            }),
                          ),
                          _buildSliderSetting(
                            label: 'Starting Balance',
                            value: _settings.startingBalance.toDouble(),
                            min: 50,
                            max: 500,
                            divisions: 9,
                            displayValue: '\$${_settings.startingBalance}',
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(startingBalance: v.toInt());
                            }),
                          ),
                          _buildSliderSetting(
                            label: 'Participants Per Race',
                            value: _settings.participantsPerRace.toDouble(),
                            min: 4,
                            max: 8,
                            divisions: 4,
                            displayValue: '${_settings.participantsPerRace} racers',
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(participantsPerRace: v.toInt());
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tournament Mode
                    _buildSection(
                      title: '🏆 TOURNAMENT MODE',
                      child: Column(
                        children: [
                          _buildToggle(
                            label: 'Tournament Mode',
                            description: 'Multi-race competition with points & standings',
                            emoji: '🏆',
                            value: _settings.tournamentMode,
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(
                                tournamentMode: v,
                                // Auto-set race count if enabling tournament
                                tournamentRaces: v && _settings.tournamentRaces == 0 
                                    ? 5 
                                    : _settings.tournamentRaces,
                              );
                            }),
                          ),
                          if (_settings.tournamentMode) ...[
                            const SizedBox(height: 16),
                            _buildSliderSetting(
                              label: 'Tournament Races',
                              value: _settings.tournamentRaces.toDouble(),
                              min: 3,
                              max: 10,
                              divisions: 7,
                              displayValue: '${_settings.tournamentRaces} races',
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(tournamentRaces: v.toInt());
                              }),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.neonPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Text('🏅', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tournament Scoring',
                                          style: TextStyle(
                                            color: AppTheme.neonPurple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Win bet: 3 pts • Place bet: 2 pts • Profit bonus: 1 pt per \$50',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Timer Settings
                    _buildSection(
                      title: '⏱️ PHASE TIMERS',
                      child: Column(
                        children: [
                          _buildSliderSetting(
                            label: 'Paddock Phase',
                            value: _settings.paddockDuration.toDouble(),
                            min: 15,
                            max: 60,
                            divisions: 9,
                            displayValue: '${_settings.paddockDuration}s',
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(paddockDuration: v.toInt());
                            }),
                          ),
                          _buildSliderSetting(
                            label: 'Wager Phase',
                            value: _settings.wagerDuration.toDouble(),
                            min: 20,
                            max: 90,
                            divisions: 7,
                            displayValue: '${_settings.wagerDuration}s',
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(wagerDuration: v.toInt());
                            }),
                          ),
                          _buildSliderSetting(
                            label: 'Sabotage Phase',
                            value: _settings.sabotageDuration.toDouble(),
                            min: 15,
                            max: 60,
                            divisions: 9,
                            displayValue: '${_settings.sabotageDuration}s',
                            onChanged: (v) => setState(() {
                              _settings = _settings.copyWith(sabotageDuration: v.toInt());
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Party Features (only show in custom mode)
                    if (_settings.gameMode == GameMode.custom) ...[
                      const SizedBox(height: 32),
                      _buildSection(
                        title: '🍻 PARTY FEATURES',
                        child: Column(
                          children: [
                            _buildToggle(
                              label: 'Player Rivalries',
                              description: 'Featured battles between 2 players each race',
                              emoji: '⚔️',
                              value: _settings.enableRivalries,
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(enableRivalries: v);
                              }),
                            ),
                            _buildToggle(
                              label: 'Side Bets',
                              description: 'Challenge other players with drink bets',
                              emoji: '🎲',
                              value: _settings.enableSideBets,
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(enableSideBets: v);
                              }),
                            ),
                            _buildToggle(
                              label: 'Drinking Cards',
                              description: 'Random rule cards each race',
                              emoji: '🃏',
                              value: _settings.enableDrinkingCards,
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(enableDrinkingCards: v);
                              }),
                            ),
                            _buildToggle(
                              label: 'Punishment Wheel',
                              description: 'Spin the wheel for broke players',
                              emoji: '🎡',
                              value: _settings.enablePunishmentWheel,
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(enablePunishmentWheel: v);
                              }),
                            ),
                            _buildToggle(
                              label: 'Hot Seat Mode',
                              description: 'One player per round must bet on favorite',
                              emoji: '🔥',
                              value: _settings.enableHotSeat,
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(enableHotSeat: v);
                              }),
                            ),
                            _buildToggle(
                              label: 'Drink Tracker',
                              description: 'Track drinks throughout the night',
                              emoji: '📊',
                              value: _settings.enableDrinkTracker,
                              onChanged: (v) => setState(() {
                                _settings = _settings.copyWith(enableDrinkTracker: v);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Show enabled features summary for party mode
                    if (_settings.gameMode == GameMode.party) ...[
                      const SizedBox(height: 32),
                      _buildSection(
                        title: '🍻 PARTY FEATURES ENABLED',
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildFeatureChip('⚔️ Rivalries'),
                            _buildFeatureChip('🎲 Side Bets'),
                            _buildFeatureChip('🃏 Drinking Cards'),
                            _buildFeatureChip('🎡 Punishment Wheel'),
                            _buildFeatureChip('🔥 Hot Seat'),
                            _buildFeatureChip('📊 Drink Tracker'),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.neonText(
            color: AppTheme.neonYellow,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildModeCard({
    required GameMode mode,
    required String title,
    required String description,
    required String emoji,
    required Color color,
  }) {
    final isSelected = _settings.gameMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => _setGameMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: AppTheme.neonCyan,
              inactiveColor: Colors.grey[700],
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              displayValue,
              style: const TextStyle(
                color: AppTheme.neonCyan,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required String description,
    required String emoji,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppTheme.neonGreen.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.neonGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.neonGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

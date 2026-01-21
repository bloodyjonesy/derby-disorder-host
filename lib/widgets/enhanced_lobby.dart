import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'neon_room_code.dart';
import 'player_avatar_card.dart';
import 'glassmorphic_panel.dart';
import 'tv_focusable.dart';

/// An enhanced lobby screen with dramatic animations and improved UI
class EnhancedLobby extends StatefulWidget {
  final String? roomCode;
  final List<Player> players;
  final VoidCallback onCreateRoom;
  final void Function(GameSettings settings) onStartGame;
  final VoidCallback? onOpenSettings;
  final GameSettings? settings;
  final bool isLoading;
  final TournamentState? tournament;
  final int raceNumber;

  const EnhancedLobby({
    super.key,
    this.roomCode,
    required this.players,
    required this.onCreateRoom,
    required this.onStartGame,
    this.onOpenSettings,
    this.settings,
    this.isLoading = false,
    this.tournament,
    this.raceNumber = 0,
  });

  @override
  State<EnhancedLobby> createState() => _EnhancedLobbyState();
}

class _EnhancedLobbyState extends State<EnhancedLobby>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _contentController;
  final FocusNode _createRoomFocusNode = FocusNode();
  final FocusNode _startGameFocusNode = FocusNode();
  final FocusNode _settingsFocusNode = FocusNode();

  bool get isTournamentInProgress =>
      widget.tournament != null && widget.tournament!.isActive;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _contentController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialFocus();
    });
  }

  @override
  void didUpdateWidget(EnhancedLobby oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomCode != widget.roomCode ||
        oldWidget.players.length != widget.players.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestInitialFocus();
      });
    }
  }

  void _requestInitialFocus() {
    if (!mounted) return;

    if (widget.roomCode == null && !widget.isLoading) {
      _createRoomFocusNode.requestFocus();
    } else if (widget.roomCode != null && widget.players.isNotEmpty) {
      _startGameFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _createRoomFocusNode.dispose();
    _startGameFocusNode.dispose();
    _settingsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Stack(
        children: [
          // Animated background
          _buildBackground(),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Title section
                  _buildTitle(),

                  const SizedBox(height: 32),

                  // Content
                  Expanded(
                    child: widget.roomCode == null
                        ? _buildCreateRoomView()
                        : _buildLobbyView(),
                  ),
                ],
              ),
            ),
          ),

          // Settings button
          if (widget.onOpenSettings != null)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: TVFocusable(
                  focusNode: _settingsFocusNode,
                  focusColor: AppTheme.neonCyan,
                  onSelect: widget.onOpenSettings,
                  child: GlassmorphicPanel(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 12,
                    child: Icon(
                      Icons.settings,
                      color: AppTheme.neonCyan,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Base gradient
          Container(
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
          ),

          // Animated grid lines
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),

          // Glow orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonPink.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonCyan.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        final slideOffset = Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _titleController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));

        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _titleController,
            curve: const Interval(0.0, 0.5),
          ),
        );

        return SlideTransition(
          position: slideOffset,
          child: FadeTransition(
            opacity: opacity,
            child: Column(
              children: [
                // Main title with neon glow
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.neonPink,
                      AppTheme.neonCyan,
                      AppTheme.neonPink,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    'DERBY DISORDER',
                    style: AppTheme.neonText(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'THE CHAOS CUP',
                  style: AppTheme.neonText(
                    color: AppTheme.neonCyan,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Game mode indicator
                if (widget.settings != null)
                  _buildGameModeChip(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameModeChip() {
    final mode = widget.settings?.gameMode ?? GameMode.regular;

    Color color;
    String label;
    IconData icon;

    switch (mode) {
      case GameMode.regular:
        color = AppTheme.neonCyan;
        label = 'REGULAR MODE';
        icon = Icons.sports_score;
        break;
      case GameMode.party:
        color = AppTheme.neonPink;
        label = 'PARTY MODE';
        icon = Icons.celebration;
        break;
      case GameMode.custom:
        color = AppTheme.neonYellow;
        label = 'CUSTOM MODE';
        icon = Icons.tune;
        break;
    }

    return GestureDetector(
      onTap: widget.onOpenSettings,
      child: GlassmorphicPanel(
        borderColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 24,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRoomView() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative horse emoji
            const Text(
              '🏇',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 32),

            Text(
              'Ready to race?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a room and invite your friends!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 48),

            if (widget.isLoading)
              const CircularProgressIndicator(color: AppTheme.neonCyan)
            else
              TVFocusable(
                focusNode: _createRoomFocusNode,
                focusColor: AppTheme.neonCyan,
                onSelect: widget.onCreateRoom,
                child: _NeonButton(
                  label: 'CREATE ROOM',
                  icon: Icons.add_circle_outline,
                  color: AppTheme.neonCyan,
                  onPressed: widget.onCreateRoom,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyView() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
      child: Column(
        children: [
          // Room code display
          NeonRoomCode(
            roomCode: widget.roomCode,
            showJoinUrl: true,
            letterSize: 70,
          ),

          const SizedBox(height: 32),

          // Tournament standings (if active)
          if (isTournamentInProgress) ...[
            _buildTournamentBanner(),
            const SizedBox(height: 24),
          ],

          // Players section
          Expanded(
            child: widget.players.isEmpty
                ? _buildWaitingForPlayers()
                : _buildPlayerGrid(),
          ),

          const SizedBox(height: 24),

          // Start button
          if (widget.players.isNotEmpty)
            TVFocusable(
              focusNode: _startGameFocusNode,
              focusColor:
                  isTournamentInProgress ? AppTheme.neonPurple : AppTheme.neonGreen,
              onSelect: widget.settings != null
                  ? () => widget.onStartGame(widget.settings!)
                  : null,
              child: _NeonButton(
                label: isTournamentInProgress ? 'NEXT RACE' : 'START GAME',
                icon: isTournamentInProgress ? Icons.emoji_events : Icons.flag,
                color:
                    isTournamentInProgress ? AppTheme.neonPurple : AppTheme.neonGreen,
                onPressed: widget.settings != null
                    ? () => widget.onStartGame(widget.settings!)
                    : null,
                large: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentBanner() {
    return GlassmorphicPanel(
      borderColor: AppTheme.neonPurple,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOURNAMENT MODE',
                style: AppTheme.neonText(
                  color: AppTheme.neonPurple,
                  fontSize: 16,
                ),
              ),
              Text(
                'Race ${widget.raceNumber} of ${widget.tournament!.totalRaces}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForPlayers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppTheme.neonCyan.withOpacity(0.5),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for players to join...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan the QR code or visit ddcc.pw',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerGrid() {
    // Sort players by balance (highest first) for ranking
    final sortedPlayers = [...widget.players];
    sortedPlayers.sort((a, b) => b.balance.compareTo(a.balance));

    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: widget.players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final rank = sortedPlayers.indexOf(player) + 1;

          return PlayerAvatarCard(
            player: player,
            rank: isTournamentInProgress ? rank : null,
            isViewer: player.isViewer,
            animationDelay: index,
          );
        }).toList(),
      ),
    );
  }
}

/// A styled neon button with glow effects
class _NeonButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool large;

  const _NeonButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
    this.large = false,
  });

  @override
  State<_NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<_NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowValue = _glowController.value;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: widget.large ? 48 : 32,
                vertical: widget.large ? 20 : 16,
              ),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(widget.large ? 16 : 12),
                border: Border.all(
                  color: widget.color.withOpacity(0.5 + glowValue * 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(
                      (_isHovered ? 0.4 : 0.2) + glowValue * 0.2,
                    ),
                    blurRadius: _isHovered ? 25 : 15,
                    spreadRadius: _isHovered ? 3 : 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color,
                    size: widget.large ? 28 : 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: AppTheme.neonText(
                      color: widget.color,
                      fontSize: widget.large ? 24 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for background grid
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Vertical lines
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

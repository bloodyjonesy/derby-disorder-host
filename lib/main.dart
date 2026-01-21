import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/socket_service.dart';
import 'services/api_service.dart';
import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for TV
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Pre-load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(DerbyDisorderApp(settingsProvider: settingsProvider));
}

/// Custom intent for directional navigation
class DirectionalFocusIntent extends Intent {
  const DirectionalFocusIntent(this.direction);
  final TraversalDirection direction;
}

/// Action to handle directional focus
class DirectionalFocusAction extends Action<DirectionalFocusIntent> {
  @override
  Object? invoke(DirectionalFocusIntent intent) {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null) {
      primaryFocus.focusInDirection(intent.direction);
    }
    return null;
  }
}

class DerbyDisorderApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const DerbyDisorderApp({
    super.key,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings provider (pre-loaded)
        ChangeNotifierProvider.value(value: settingsProvider),
        // Party provider
        ChangeNotifierProvider(create: (_) => PartyProvider()),
        // Socket service
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        ),
        // API service
        Provider(
          create: (_) => ApiService(),
        ),
        // Room provider (depends on socket and api services)
        ChangeNotifierProxyProvider2<SocketService, ApiService, RoomProvider>(
          create: (context) => RoomProvider(
            socketService: context.read<SocketService>(),
            apiService: context.read<ApiService>(),
          ),
          update: (context, socket, api, previous) =>
              previous ??
              RoomProvider(
                socketService: socket,
                apiService: api,
              ),
        ),
        // Race provider (depends on socket service)
        ChangeNotifierProxyProvider<SocketService, RaceProvider>(
          create: (context) => RaceProvider(
            socketService: context.read<SocketService>(),
          ),
          update: (context, socket, previous) =>
              previous ?? RaceProvider(socketService: socket),
        ),
      ],
      child: MaterialApp(
        title: 'Derby Disorder: The Chaos Cup',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // Disable system text scaling to ensure consistent UI
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
        home: const TVNavigationWrapper(child: HomeScreen()),
        // Comprehensive shortcuts for TV remote, keyboard, and gamepad
        shortcuts: <ShortcutActivator, Intent>{
          ...WidgetsApp.defaultShortcuts,
          // Select/Enter/OK button
          const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
          // Gamepad A button
          const SingleActivator(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.gameButtonStart): const ActivateIntent(),
          // D-pad navigation
          const SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
          const SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
          const SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
          // WASD navigation
          const SingleActivator(LogicalKeyboardKey.keyW): DirectionalFocusIntent(TraversalDirection.up),
          const SingleActivator(LogicalKeyboardKey.keyS): DirectionalFocusIntent(TraversalDirection.down),
          const SingleActivator(LogicalKeyboardKey.keyA): DirectionalFocusIntent(TraversalDirection.left),
          const SingleActivator(LogicalKeyboardKey.keyD): DirectionalFocusIntent(TraversalDirection.right),
        },
        actions: <Type, Action<Intent>>{
          ...WidgetsApp.defaultActions,
          DirectionalFocusIntent: DirectionalFocusAction(),
        },
      ),
    );
  }
}

/// Wrapper widget to handle TV navigation and focus
class TVNavigationWrapper extends StatelessWidget {
  final Widget child;

  const TVNavigationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          // Additional media remote buttons
          const SingleActivator(LogicalKeyboardKey.mediaPlayPause): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.mediaPlay): const ActivateIntent(),
          // Numpad enter
          const SingleActivator(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DirectionalFocusIntent: DirectionalFocusAction(),
          },
          child: child,
        ),
      ),
    );
  }
}

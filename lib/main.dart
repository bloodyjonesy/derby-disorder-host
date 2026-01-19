import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/socket_service.dart';
import 'services/api_service.dart';
import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for TV
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const DerbyDisorderApp());
}

class DerbyDisorderApp extends StatelessWidget {
  const DerbyDisorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        home: const HomeScreen(),
        // Shortcuts for TV remote and keyboard
        shortcuts: <ShortcutActivator, Intent>{
          ...WidgetsApp.defaultShortcuts,
          const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
      ),
    );
  }
}

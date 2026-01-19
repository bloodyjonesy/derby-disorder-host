import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_native/widgets/room_code_display.dart';
import 'package:host_native/widgets/phase_indicator.dart';
import 'package:host_native/widgets/lobby_screen.dart';
import 'package:host_native/models/models.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('RoomCodeDisplay shows room code', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoomCodeDisplay(roomCode: 'ABC123'),
          ),
        ),
      );

      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('ROOM CODE'), findsOneWidget);
    });

    testWidgets('RoomCodeDisplay is hidden when no code', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoomCodeDisplay(roomCode: null),
          ),
        ),
      );

      expect(find.text('ROOM CODE'), findsNothing);
    });

    testWidgets('PhaseIndicator shows correct phase', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhaseIndicator(
              gameState: GameState.racing,
              timer: 30,
            ),
          ),
        ),
      );

      expect(find.text('THE RACE'), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('LobbyScreen shows create room button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LobbyScreen(
              roomCode: null,
              players: const [],
              onCreateRoom: () {},
              onStartGame: () {},
            ),
          ),
        ),
      );

      expect(find.text('CREATE ROOM'), findsOneWidget);
      expect(find.text('DERBY DISORDER'), findsOneWidget);
      expect(find.text('THE CHAOS CUP'), findsOneWidget);
    });

    testWidgets('LobbyScreen shows start game when players present', (WidgetTester tester) async {
      const testPlayers = [
        Player(
          id: '1',
          name: 'Player 1',
          balance: 100,
          hype: 0,
          socketId: 'socket1',
          isBroke: false,
          isTrashPicker: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LobbyScreen(
              roomCode: 'ABC123',
              players: testPlayers,
              onCreateRoom: () {},
              onStartGame: () {},
            ),
          ),
        ),
      );

      expect(find.text('START GAME'), findsOneWidget);
      expect(find.text('Player 1'), findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:host_native/models/models.dart';

void main() {
  group('GameState', () {
    test('fromString converts correctly', () {
      expect(GameState.fromString('LOBBY'), GameState.lobby);
      expect(GameState.fromString('PADDOCK'), GameState.paddock);
      expect(GameState.fromString('WAGER'), GameState.wager);
      expect(GameState.fromString('SABOTAGE'), GameState.sabotage);
      expect(GameState.fromString('RACING'), GameState.racing);
      expect(GameState.fromString('RESULTS'), GameState.results);
    });

    test('toJson returns correct value', () {
      expect(GameState.lobby.toJson(), 'LOBBY');
      expect(GameState.racing.toJson(), 'RACING');
    });

    test('handles unknown state', () {
      expect(GameState.fromString('UNKNOWN'), GameState.lobby);
    });
  });

  group('Player', () {
    test('fromJson creates player correctly', () {
      final json = {
        'id': 'player1',
        'name': 'TestPlayer',
        'balance': 100,
        'hype': 5,
        'socketId': 'socket123',
        'isBroke': false,
        'isTrashPicker': false,
      };

      final player = Player.fromJson(json);

      expect(player.id, 'player1');
      expect(player.name, 'TestPlayer');
      expect(player.balance, 100);
      expect(player.hype, 5);
      expect(player.socketId, 'socket123');
      expect(player.isBroke, false);
      expect(player.isTrashPicker, false);
    });

    test('toJson produces correct map', () {
      const player = Player(
        id: 'player1',
        name: 'TestPlayer',
        balance: 100,
        hype: 5,
        socketId: 'socket123',
        isBroke: false,
        isTrashPicker: false,
      );

      final json = player.toJson();

      expect(json['id'], 'player1');
      expect(json['name'], 'TestPlayer');
      expect(json['balance'], 100);
    });

    test('copyWith creates new instance with updated values', () {
      const player = Player(
        id: 'player1',
        name: 'TestPlayer',
        balance: 100,
        hype: 5,
        socketId: 'socket123',
        isBroke: false,
        isTrashPicker: false,
      );

      final updated = player.copyWith(balance: 200, isBroke: true);

      expect(updated.balance, 200);
      expect(updated.isBroke, true);
      expect(updated.name, 'TestPlayer');
    });
  });

  group('Participant', () {
    test('fromJson creates participant correctly', () {
      final json = {
        'id': 'part1',
        'name': 'Golden Retriever',
        'type': 'creature',
        'zoomies': 8,
        'chonk': 5,
        'derp': 7,
        'color': '#ff0000',
        'history': [1, 3, 2],
      };

      final participant = Participant.fromJson(json);

      expect(participant.id, 'part1');
      expect(participant.name, 'Golden Retriever');
      expect(participant.type, ParticipantType.creature);
      expect(participant.zoomies, 8);
      expect(participant.chonk, 5);
      expect(participant.derp, 7);
      expect(participant.color, '#ff0000');
      expect(participant.history, [1, 3, 2]);
    });

    test('icon returns correct emoji', () {
      const participant = Participant(
        id: 'part1',
        name: 'A Golden Retriever',
        type: ParticipantType.creature,
        zoomies: 8,
        chonk: 5,
        derp: 7,
        color: '#ff0000',
        history: [],
      );

      expect(participant.icon, '🐕');
    });
  });

  group('Bet', () {
    test('fromJson creates bet correctly', () {
      final json = {
        'playerId': 'player1',
        'participantId': 'part1',
        'betType': 'WIN',
        'amount': 50,
      };

      final bet = Bet.fromJson(json);

      expect(bet.playerId, 'player1');
      expect(bet.participantId, 'part1');
      expect(bet.betType, BetType.win);
      expect(bet.amount, 50);
    });
  });

  group('RaceSnapshot', () {
    test('fromJson creates snapshot correctly', () {
      final json = {
        'tick': 42,
        'positions': {'part1': 45.5, 'part2': 38.2},
        'leader': 'part1',
      };

      final snapshot = RaceSnapshot.fromJson(json);

      expect(snapshot.tick, 42);
      expect(snapshot.positions['part1'], 45.5);
      expect(snapshot.positions['part2'], 38.2);
      expect(snapshot.leader, 'part1');
    });

    test('getPosition returns correct value', () {
      const snapshot = RaceSnapshot(
        tick: 42,
        positions: {'part1': 45.5, 'part2': 38.2},
        leader: 'part1',
      );

      expect(snapshot.getPosition('part1'), 45.5);
      expect(snapshot.getPosition('part2'), 38.2);
      expect(snapshot.getPosition('part3'), 0.0);
    });
  });

  group('RaceResult', () {
    test('winnerId returns first in finishOrder', () {
      const result = RaceResult(
        finishOrder: ['part1', 'part2', 'part3'],
        finalPositions: {'part1': 1, 'part2': 2, 'part3': 3},
      );

      expect(result.winnerId, 'part1');
    });

    test('getPosition returns correct finishing position', () {
      const result = RaceResult(
        finishOrder: ['part1', 'part2', 'part3'],
        finalPositions: {'part1': 1, 'part2': 2, 'part3': 3},
      );

      expect(result.getPosition('part1'), 1);
      expect(result.getPosition('part2'), 2);
      expect(result.getPosition('part4'), null);
    });
  });

  group('Item', () {
    test('ItemType properties are correct', () {
      expect(ItemType.bananaPeel.displayName, 'Banana Peel');
      expect(ItemType.bananaPeel.emoji, '🍌');
      expect(ItemType.rocketBoost.displayName, 'Rocket Boost');
      expect(ItemType.rocketBoost.emoji, '🚀');
    });
  });

  group('Room', () {
    test('fromJson creates room correctly', () {
      final json = {
        'roomCode': 'ABC123',
        'players': [],
        'gameState': 'LOBBY',
        'bets': {},
        'participants': [],
        'items': [],
        'chaosMeter': 25,
        'timer': 60,
      };

      final room = Room.fromJson(json);

      expect(room.roomCode, 'ABC123');
      expect(room.gameState, GameState.lobby);
      expect(room.chaosMeter, 25);
      expect(room.timer, 60);
    });

    test('getParticipant returns correct participant', () {
      final room = Room(
        roomCode: 'ABC123',
        players: const [],
        gameState: GameState.racing,
        bets: const {},
        participants: const [
          Participant(
            id: 'part1',
            name: 'Test',
            type: ParticipantType.creature,
            zoomies: 5,
            chonk: 5,
            derp: 5,
            color: '#ff0000',
            history: [],
          ),
        ],
        items: const [],
        chaosMeter: 0,
      );

      final participant = room.getParticipant('part1');
      expect(participant?.name, 'Test');
      expect(room.getParticipant('part2'), null);
    });
  });
}

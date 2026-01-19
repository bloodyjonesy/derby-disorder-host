import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_native/utils/performance.dart';

void main() {
  group('Throttler', () {
    test('executes first call immediately', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      var callCount = 0;

      throttler.run(() => callCount++);

      expect(callCount, 1);
      throttler.dispose();
    });

    test('throttles subsequent calls', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 50));
      var callCount = 0;

      throttler.run(() => callCount++);
      throttler.run(() => callCount++);
      throttler.run(() => callCount++);

      expect(callCount, 1);

      await Future.delayed(const Duration(milliseconds: 60));

      throttler.run(() => callCount++);
      expect(callCount, 2);

      throttler.dispose();
    });
  });

  group('Debouncer', () {
    test('delays execution', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      var callCount = 0;

      debouncer.run(() => callCount++);
      expect(callCount, 0);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(callCount, 1);

      debouncer.dispose();
    });

    test('cancels previous calls', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      var callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(callCount, 1);

      debouncer.dispose();
    });
  });

  group('ObjectPool', () {
    test('creates new objects when pool is empty', () {
      var createCount = 0;
      final pool = ObjectPool<Map<String, int>>(
        factory: () {
          createCount++;
          return {};
        },
      );

      final obj1 = pool.acquire();
      final obj2 = pool.acquire();

      expect(createCount, 2);
      expect(obj1, isNot(same(obj2)));
    });

    test('reuses released objects', () {
      var createCount = 0;
      final pool = ObjectPool<Map<String, int>>(
        factory: () {
          createCount++;
          return {};
        },
        reset: (obj) => obj.clear(),
      );

      final obj1 = pool.acquire();
      obj1['key'] = 1;
      pool.release(obj1);

      final obj2 = pool.acquire();

      expect(createCount, 1);
      expect(obj2, same(obj1));
      expect(obj2.isEmpty, true);
    });

    test('respects max size', () {
      final pool = ObjectPool<Map<String, int>>(
        factory: () => {},
        maxSize: 2,
      );

      pool.release({});
      pool.release({});
      pool.release({});

      expect(pool.size, 2);
    });
  });

  group('RecyclingList', () {
    test('adds and retrieves items', () {
      final list = RecyclingList<int>();

      list.add(1);
      list.add(2);
      list.add(3);

      expect(list.length, 3);
      expect(list[0], 1);
      expect(list[1], 2);
      expect(list[2], 3);
    });

    test('clears without deallocating', () {
      final list = RecyclingList<int>();

      list.add(1);
      list.add(2);
      list.clear();

      expect(list.length, 0);
      expect(list.isEmpty, true);

      list.add(3);
      expect(list.length, 1);
      expect(list[0], 3);
    });

    test('throws on out of bounds access', () {
      final list = RecyclingList<int>();
      list.add(1);

      expect(() => list[1], throwsRangeError);
    });

    test('values iterator works correctly', () {
      final list = RecyclingList<int>();
      list.add(1);
      list.add(2);
      list.add(3);

      expect(list.values.toList(), [1, 2, 3]);
    });
  });
}

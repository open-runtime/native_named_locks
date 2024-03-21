@TestOn('windows')

import 'package:runtime_native_named_locks/primitives.dart';
import 'package:test/test.dart';

void main() {
  group('WindowsNamedLock', () {
    late NamedLock lock;

    setUp(() {
      lock = NamedLock(name: 'test-named-lock');
    });

    tearDown(() {
      lock.dispose();
    });

    test('acquireLock', () {
      // Test the acquireLock function
      // Add your test assertions here
    });

    test('releaseLock', () {
      // Test the releaseLock function
      // Add your test assertions here
    });

    test('isLockAcquired', () {
      // Test the isLockAcquired function
      // Add your test assertions here
    });

    // Add more tests for other functions in windows_named_lock.dart
  });
}

@TestOn('windows')
import 'package:runtime_native_named_locks/errors.dart';
import 'package:runtime_native_named_locks/primitives.dart';
import 'package:test/test.dart';

void main() {
  group('WindowsNamedLock', () {
    test('should initialize successfully with a valid name', () {
      // Arrange
      const name = 'MyNamedLock';

      // Act
      final lock = NamedLock(name: name);

      // Assert
      expect(lock.name, equals(name));
      expect(lock.handle, isNotNull);
      expect(lock.handle.address, isNonZero);
    });

    test('should throw an exception when initialization fails', () {
      // Anything over 256 characters
      const invalid =
          'hereisarandomstringcontainingexactlythreehundredletterswithnospacesandnospecialcharactersItisquitealongstringisntitIhopetheresnoneedtomakethisanylongerthanitshouldbeTherearequitealotofsentenceslikethisonethatyoucanaddtothisstringwithoutanyspacesaslongasyoudontusepunctuationorspecialcharactersSomeonemightaskwhythisstringexistsandtheanswertothatquestionissimplybecauseitwasrequestedbytheoriginalposter';

      Object? error;
      NamedLock? lock;

      try {
        lock = NamedLock(name: invalid);
      } catch (e) {
        error = e;
        print(e);
      }

      expect(error, isNotNull);
      expect(lock, isNull);

      // Act & Assert
      // expect(
      //   () => NamedLock(name: invalid),
      //   throwsA(isA<Exception>().having(
      //     (e) => e.toString(),
      //     'message',
      //     contains(NamedLockErrors.createFailed.toString()),
      //   )),
      // );
    });
  });

  tearDown(() {
    // lock.dispose();
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
}

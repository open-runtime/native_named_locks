@TestOn('windows')

import 'package:runtime_native_named_locks/named_lock_guard.dart';
import 'package:runtime_native_named_locks/named_locks.dart';
import 'package:runtime_native_named_locks/primitives.dart' show NamedLock;
import 'package:runtime_native_named_locks/src/bindings/windows.dart' show GetLastError;
import 'package:test/test.dart'
    show TestOn, contains, equals, expect, group, isA, isNonZero, isNotNull, isNull, isTrue, tearDown, test, throwsA;
import 'package:windows_foundation/internal.dart' show getRestrictedErrorDescription;

void main() {
  group('WindowsNamedLock', () {
    test('should initialize successfully with a valid name', () {
      // Arrange
      const name = 'MyNamedLock';

      // Act
      final lock = NamedLock(identifier: name);

      // Assert
      // expect(lock.identifier, equals(name));
      // expect(lock.fd, isNotNull);
      // expect(lock.fd.address, isNonZero);
    });

    test('should throw an exception when initialization fails', () {
      // Anything over 256 characters
      const invalid =
          'hereisarandomstringcontainingexactlythreehundredletterswithnospacesandnospecialcharactersItisquitealongstringisntitIhopetheresnoneedtomakethisanylongerthanitshouldbeTherearequitealotofsentenceslikethisonethatyoucanaddtothisstringwithoutanyspacesaslongasyoudontusepunctuationorspecialcharactersSomeonemightaskwhythisstringexistsandtheanswertothatquestionissimplybecauseitwasrequestedbytheoriginalposter';

      Object? error;
      NamedLock? lock;

      try {
        lock = NamedLock(identifier: invalid);

        int native_last_error = GetLastError();
        String? error_message = getRestrictedErrorDescription(native_last_error);

        print(native_last_error);
        print(error_message);

        print(lock.identifier);
        // print(lock.fd.address);
        // print(lock.mutex_handle.address);
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
  }, skip: true);

  group('UnixNamedLock', () {
    final String name = 'testing_of_named_lock';

    test('Basic Named Lock Creation and Functionality', () {
      print("=================================== CREATING NAMED LOCK ==================================== \n");
      final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: name, nameIsUnixPath: true);
      print(reference.target?.identifier);
      expect(reference.target, isNotNull);
      print("[CREATING NAMED LOCK]: SUCCESS \n\n");

      print("=================================== LOCKING ==================================== \n");
      expect(reference.target?.lock(), isTrue);
      print("[LOCKING]: SUCCESS \n\n");

      print("=================================== UNNECESSARY ACQUIRE ==================================== \n");
      expect(reference.target?.acquire(), isTrue);
      print("[UNNECESSARY ACQUIRE]: SUCCESS \n\n");

      print("=================================== UNNECESSARY LOCKING AGAIN ==================================== \n");
      expect(reference.target?.lock(), isTrue);
      print("[UNNECESSARY LOCKING AGAIN]: SUCCESS \n\n");

      print("=================================== UNLOCKING ==================================== \n");
      expect(reference.target?.unlock(), isTrue);
      print("[UNLOCKING AGAIN]: SUCCESS \n\n");

      print("=================================== UNNECESSARY UNLOCKING AGAIN ==================================== \n");
      expect(reference.target?.unlock(), isTrue);
      print("[UNNECESSARY UNLOCKING AGAIN]: SUCCESS \n\n");

      print("=================================== DISPOSING ==================================== \n");
      // Very few cases where you'd want to not delete the lock file...at least one process must delete it if all others are
      // disposing without delete... this is key so that the lock file is not left behind and others can create\acquire the lock
      expect(reference.target?.dispose(), isTrue);
      print("[DISPOSING]: SUCCESS \n\n");
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

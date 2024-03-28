@TestOn('linux || mac-os')
import 'dart:io';

import 'package:runtime_native_named_locks/named_lock_guard.dart' show NamedLockGuard;
import 'package:runtime_native_named_locks/named_locks.dart' show NamedLocks;
import 'package:test/test.dart'
    show
        TestOn,
        TypeMatcher,
        contains,
        equals,
        everyElement,
        expect,
        group,
        isA,
        isNotNull,
        isTrue,
        tearDown,
        test,
        throwsA;

import 'dart:isolate';
import 'dart:async';

void main() {
  const name =
      '/Users/tsavo/Development/Runtime/aot_monorepo/packages/libraries/dart/native_named_locks/test/unix_named_lock_test.lock';

  group('NamedLocks across isolates', () {
    Future<String> spawnHelperIsolate(String lockFilePath) async {
      // The entry point for the isolate
      void isolateEntryPoint(SendPort sendPort) {
        final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: lockFilePath, nameIsUnixPath: true);

        // Attempt to acquire the lock
        final acquired = reference.target?.acquire() ?? false;

        // Simulate some work
        sleep(Duration(milliseconds: 100));

        // Release the lock
        reference.target?.unlock();
        reference.target?.dispose();

        // Signal completion
        sendPort.send(acquired ? 'success' : 'failure');
      }

      // Create a receive port to get messages from the isolate
      final receivePort = ReceivePort();

      // Spawn the isolate
      await Isolate.spawn(isolateEntryPoint, receivePort.sendPort);

      // Wait for the isolate to send its message
      return await receivePort.first as String;
    }

    test('multiple isolates using the same named lock', () async {
      // Spawn the first helper isolate
      final result1 = spawnHelperIsolate(name);

      // Introduce a slight delay to ensure the isolates don't start at the exact same moment
      // await Future.delayed(Duration(milliseconds: 50));

      // Spawn the second helper isolate
      final result2 = spawnHelperIsolate(name);

      // Wait for both isolates to complete their work
      final outcomes = await Future.wait([result1, result2]);

      // Check that both isolates report success
      // This implies that they were both able to acquire and release the lock without interference
      expect(outcomes, everyElement(equals('success')));
    });
  });

  group('UnixNamedLock', () {
    test('Basic Named Lock Creation', () {
      print("=================================== CREATING NAMED LOCK ==================================== \n");
      final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: name, nameIsUnixPath: true);
      print(reference.target?.identifier);
      expect(reference.target, isNotNull);
      print("[CREATING NAMED LOCK]: SUCCESS \n\n");

      print("=================================== UNNECESSARY ACQUIRE ==================================== \n");
      expect(reference.target?.acquire(), isTrue);
      print("[UNNECESSARY ACQUIRE]: SUCCESS \n\n");

      print("=================================== LOCKING ==================================== \n");
      expect(reference.target?.lock(), isTrue);
      print("[LOCKING]: SUCCESS \n\n");

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

      print("=================================== UNNECESSARY DISPOSING AGAIN ==================================== \n");
      expect(
          () => reference.target?.dispose(),
          throwsA(isA<Exception>().having(
              (e) => e.toString(), 'description', contains('Lock has already been disposed by the current process'))));
      print("[UNNECESSARY DISPOSING AGAIN]: SUCCESS \n\n");
    });

    // test('Basic Locking', () {
    //   // print(reference.target?.identifier);
    //   // expect(reference.target?.lock(), isTrue);
    // });
    //
    // test('Basic Unlocking', () {
    //   // print(reference.target?.identifier);
    //   // expect(reference.target?.unlock(), isTrue);
    // });

    //   test('Initialize two unix named locks with the same name', () async {
    //     // var uuid = 'test_lock_edge_cases';
    //     // var lock1 = NamedLocks.create(name: uuid);
    //     // var lock2 = NamedLocks.create(name: uuid);
    //     //
    //     // // Attempt to lock twice and expect the second attempt to fail
    //     // expect(lock1.acquire(), isTrue);
    //     // expect(() => lock1.acquire(), throwsA(isA<NamedLockError>()));
    //     // expect(() => lock2.acquire(), throwsA(isA<NamedLockError>()));
    //     //
    //     // // Dispose the first lock and attempt to acquire with the second
    //     // expect(lock1.dispose(), isTrue);
    //     // expect(lock2.acquire(), isTrue);
    //   });
    //
    //   test('should throw an exception when initialization fails', () {
    //     // Anything over 256 characters
    //     // const invalid =
    //     //     'hereisarandomstringcontainingexactlythreehundredletterswithnospacesandnospecialcharactersItisquitealongstringisntitIhopetheresnoneedtomakethisanylongerthanitshouldbeTherearequitealotofsentenceslikethisonethatyoucanaddtothisstringwithoutanyspacesaslongasyoudontusepunctuationorspecialcharactersSomeonemightaskwhythisstringexistsandtheanswertothatquestionissimplybecauseitwasrequestedbytheoriginalposter';
    //     //
    //     // Object? error;
    //     // NamedLock? lock;
    //     //
    //     // try {
    //     //   lock = NamedLock(identifier: invalid);
    //     //
    //     //   int native_last_error = GetLastError();
    //     //   String? error_message = getRestrictedErrorDescription(native_last_error);
    //     //
    //     //   print(native_last_error);
    //     //   print(error_message);
    //     //
    //     //   print(lock.identifier);
    //     //   // print(lock.fd.address);
    //     //   // print(lock.mutex_handle.address);
    //     // } catch (e) {
    //     //   error = e;
    //     //   print(e);
    //     // }
    //     //
    //     // expect(error, isNotNull);
    //     // expect(lock, isNull);
    //
    //     // Act & Assert
    //     // expect(
    //     //   () => NamedLock(name: invalid),
    //     //   throwsA(isA<Exception>().having(
    //     //     (e) => e.toString(),
    //     //     'message',
    //     //     contains(NamedLockErrors.createFailed.toString()),
    //     //   )),
    //     // );
    //   });
    // });
    //
    // tearDown(() {
    //   // lock.dispose();
    // });
    //
    // test('acquireLock', () {
    //   // Test the acquireLock function
    //   // Add your test assertions here
    // });
    //
    // test('releaseLock', () {
    //   // Test the releaseLock function
    //   // Add your test assertions here
    // });
    //
    // test('isLockAcquired', () {
    //   // Test the isLockAcquired function
    //   // Add your test assertions here
    // });
// }
  });
}

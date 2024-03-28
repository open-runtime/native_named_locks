@TestOn('linux || mac-os')
import 'dart:io';

import 'package:path/path.dart';
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
  // final name = join(Directory.systemTemp.path, '/test.lock');
  // print(name);

  // group('NamedLocks across isolates', () {
  //   Future<String> spawnHelperIsolate(String lockFilePath) async {
  //     // The entry point for the isolate
  //     void isolateEntryPoint(SendPort sendPort) {
  //       final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: lockFilePath, nameIsUnixPath: true);
  //
  //       // Attempt to acquire the lock
  //       final acquired = reference.target?.acquire() ?? false;
  //
  //       // Simulate some work
  //       sleep(Duration(milliseconds: 100));
  //
  //       // Release the lock
  //       reference.target?.unlock();
  //       reference.target?.dispose();
  //
  //       // Signal completion
  //       sendPort.send(acquired ? 'success' : 'failure');
  //     }
  //
  //     // Create a receive port to get messages from the isolate
  //     final receivePort = ReceivePort();
  //
  //     // Spawn the isolate
  //     await Isolate.spawn(isolateEntryPoint, receivePort.sendPort);
  //
  //     // Wait for the isolate to send its message
  //     return await receivePort.first as String;
  //   }
  //
  //   test('multiple isolates using the same named lock', () async {
  //     // Spawn the first helper isolate
  //     final result1 = spawnHelperIsolate(name);
  //
  //     // Introduce a slight delay to ensure the isolates don't start at the exact same moment
  //     // await Future.delayed(Duration(milliseconds: 50));
  //
  //     // Spawn the second helper isolate
  //     final result2 = spawnHelperIsolate(name);
  //
  //     // Wait for both isolates to complete their work
  //     final outcomes = await Future.wait([result1, result2]);
  //
  //     // Check that both isolates report success
  //     // This implies that they were both able to acquire and release the lock without interference
  //     expect(outcomes, everyElement(equals('success')));
  //   });
  // });

  group('UnixNamedLock', () {
    test('Basic Named Lock Creation', () {
      print("=================================== CREATING NAMED LOCK ==================================== \n");
      final WeakReference<NamedLockGuard> reference =
          NamedLocks.create(name: "testing_named_unix_lock", nameIsUnixPath: false);
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

      print("=================================== UNNECESSARY DISPOSING AGAIN ==================================== \n");
      expect(
          () => reference.target?.dispose(),
          throwsA(isA<Exception>().having(
              (e) => e.toString(), 'description', contains('Lock has already been disposed by the current process'))));
      print("[UNNECESSARY DISPOSING AGAIN]: SUCCESS \n\n");
    });
  });
}

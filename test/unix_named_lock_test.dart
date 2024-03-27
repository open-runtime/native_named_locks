@TestOn('linux || mac-os')

import 'package:runtime_native_named_locks/named_lock_guard.dart' show NamedLockGuard;
import 'package:runtime_native_named_locks/named_locks.dart' show NamedLocks;
import 'package:test/test.dart' show TestOn, expect, group, isNotNull, tearDown, test;

void main() {
  group('UnixNamedLock', () {
    test('Basic Named Lock Creation', () {
      const name =
          '/Users/tsavo/Development/Runtime/aot_monorepo/packages/libraries/dart/native_named_locks/test/unix_named_lock_test.lock';

      final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: name, nameIsUnixPath: true);

      expect(reference.target, isNotNull);
      print(reference.target?.identifier);

      print(reference.target?.lock());

      // reference.target?.lock();

      // expect(reference.target?.identifier, equals(name));

      // // Assert
      // expect(lock.identifier, equals(name));
      // expect(lock.fd, isNotNull);
      // expect(lock.fd.address, isNonZero);
    }, tags: ['unix', 'creation']);

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

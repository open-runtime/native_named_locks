@TestOn('windows')
import 'dart:ffi';
import 'dart:io' show sleep;
import 'dart:isolate' show Isolate, ReceivePort, SendPort;
import 'dart:math' show Random;
import 'package:ffi/ffi.dart';

import 'package:win32/src/types.dart' show HANDLE, LPWSTR;
import 'package:win32/win32.dart' show BOOL;

import 'package:path/path.dart' show join;
import 'package:runtime_native_named_locks/src/bindings/windows.dart'
    show CreateMutexW, ReleaseMutex, WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT;
import 'package:test/test.dart' show TestOn, equals, everyElement, expect, group, test;
import 'package:win32/win32.dart' show CloseHandle, GetLastError, INFINITE, WaitForSingleObject;
import 'package:windows_foundation/internal.dart' show getRestrictedErrorDescription;

void main() {
  group('WindowsNamedLock', () {
    test('Initialize & test FFI Bindings', () {
      final identifier = join("Global\\", 'my_named_lock');

      // An LPCWSTR is a 32-bit pointer to a CONSTANT string of 16-bit Unicode characters, which MAY be null-terminated.
      // typedef const wchar_t* LPCWSTR;
      // the equivalent of a char pointer (`const wchar_t*`) in C code.
      // StringUtf16Pointer
      final LPWSTR native_LPCWSTR = identifier.toNativeUtf16(allocator: malloc);

      print(native_LPCWSTR.toDartString());
      // final Uint32 native_BOOL = Uint32.fromBool(initial_owner);

      // BOOL
      // final native_BOOL = initial_owner.toNative();

      // final HString native_string = HString.fromString(identifier);
      // print(native_string.handle);

      // final native_boolean = false();

      // HANDLE CreateMutexW(
      //     [in, optional] LPSECURITY_ATTRIBUTES lpMutexAttributes,
      //     [in]           BOOL                  bInitialOwner,
      //     [in, optional] LPCWSTR               lpName
      // );

      // A BOOL is a 32-bit field that is set to 1 to indicate TRUE, or 0 to indicate FALSE.
      // This type is declared as follows:
      // typedef int BOOL, *PBOOL, *LPBOOL;
      print("\n=================================== CREATE MUTEX W ==================================== \n");
      final int mutex_address = CreateMutexW(nullptr, 0, native_LPCWSTR);
      // If lpName matches the name of an existing event, semaphore, waitable timer, job, or file-mapping object, the function fails and the GetLastError function returns ERROR_INVALID_HANDLE. This occurs because these objects share the same namespace.
      print(mutex_address);

      final MUTEX_HANDLE = Pointer.fromAddress(mutex_address);

      // print(MUTEX_HANDLE.address);

      if (mutex_address == nullptr) {
        print("\n=================================== GET LAST ERROR ==================================== \n");
        int native_last_error = GetLastError();
        print(native_last_error);
        String? error_message = getRestrictedErrorDescription(native_last_error);
        print('Error: ${error_message}');
      }

      print("\n=================================== WAIT FOR SINGLE OBJECT ==================================== \n");

      final result = WaitForSingleObject(MUTEX_HANDLE.address, INFINITE);
      print(result);

      // final RESULT_HANDLE = Pointer.fromAddress(result);

      // print(RESULT_HANDLE.address);

      print('$INFINITE, $WAIT_OBJECT_0, $WAIT_ABANDONED, $WAIT_TIMEOUT');

      print("\n=================================== RELEASE MUTEX ==================================== \n");
      print('ReleaseMutex');
      final released = ReleaseMutex(MUTEX_HANDLE.address);
      print(released);
      print('0 is false and 1 is true, 0 is even and 1 is odd');
      print(released.isOdd);

      print("\n=================================== CLOSE HANDLE ==================================== \n");
      final closed = CloseHandle(MUTEX_HANDLE.address);
      print(closed);
      print('0 is false and 1 is true, 0 is even and 1 is odd');
      print(closed.isOdd);

      print("\n=================================== FREE ==================================== \n");
      malloc.free(native_LPCWSTR);
      // malloc.free(MUTEX_HANDLE);
      // malloc.free(RESULT_HANDLE);
    });

    test('Try to force error on NamedLock name length', () {
      // Anything longer than 260 characters should throw an error
      final too_long_of_a_name = 'abc' * 260;
      final identifier = join("Global\\", too_long_of_a_name);

      final LPWSTR native_LPCWSTR = identifier.toNativeUtf16(allocator: malloc);

      print(native_LPCWSTR.toDartString());

      print(
          "\n=================================== CreateMutexW with too_long_of_a_name  ==================================== \n");
      final int mutex_address = CreateMutexW(nullptr, 0, native_LPCWSTR);
      final MUTEX_HANDLE = Pointer.fromAddress(mutex_address);

      print(mutex_address);
      print(MUTEX_HANDLE == nullptr);
      print(MUTEX_HANDLE.address);
      print(MUTEX_HANDLE.address == nullptr.address);

      print("\n=================================== GET LAST ERROR ==================================== \n");
      int native_last_error = GetLastError();
      print(native_last_error);
      String? error_message = getRestrictedErrorDescription(native_last_error);
      print('Error: ${error_message}');

      print("\n=================================== FREE ==================================== \n");
      malloc.free(native_LPCWSTR);
    });

    test('Try to force error on Create Mutex W', () {
      final identifier = join("Global\\", 'my_named_lock_forced_error');

      // An LPCWSTR is a 32-bit pointer to a CONSTANT string of 16-bit Unicode characters, which MAY be null-terminated.
      // typedef const wchar_t* LPCWSTR;
      // the equivalent of a char pointer (`const wchar_t*`) in C code.
      // StringUtf16Pointer
      final LPWSTR native_LPCWSTR = identifier.toNativeUtf16(allocator: malloc);

      print(native_LPCWSTR.toDartString());

      print("\n=================================== CREATE MUTEX W 1 ==================================== \n");
      final int mutex_address_1 = CreateMutexW(nullptr, 1, native_LPCWSTR);

      print(mutex_address_1);

      final MUTEX_HANDLE = Pointer.fromAddress(mutex_address_1);

      print(MUTEX_HANDLE.address);

      if (mutex_address_1 == nullptr) {
        print("\n=================================== GET LAST ERROR ==================================== \n");
        int native_last_error = GetLastError();
        print(native_last_error);
        String? error_message = getRestrictedErrorDescription(native_last_error);
        print('Error: ${error_message}');
      }

      print("\n=================================== WAIT FOR SINGLE OBJECT ==================================== \n");

      final result = WaitForSingleObject(MUTEX_HANDLE.address, INFINITE);
      print(result);

      // final RESULT_HANDLE = Pointer.fromAddress(result);

      // print(RESULT_HANDLE.address);

      print('$INFINITE, $WAIT_OBJECT_0, $WAIT_ABANDONED, $WAIT_TIMEOUT');

      print("\n=================================== CREATE MUTEX W 2 ==================================== \n");
      final int mutex_address_2 = CreateMutexW(nullptr, 1, native_LPCWSTR);

      print(mutex_address_2);

      final MUTEX_HANDLE_2 = Pointer.fromAddress(mutex_address_2);

      print(MUTEX_HANDLE_2.address);

      if (mutex_address_2 == nullptr) {
        print("\n=================================== GET LAST ERROR ==================================== \n");
        int native_last_error = GetLastError();
        print(native_last_error);
        String? error_message = getRestrictedErrorDescription(native_last_error);
        print('Error: ${error_message}');
      }

      print("\n=================================== RELEASE MUTEXES ==================================== \n");

      malloc.free(native_LPCWSTR);
    });
  });

  group('Test Windows Binding Across Isolates', () {
    // final String name = join(dirname(Frame.caller(0).uri.toFilePath()), 'testing_named_unix_locks.lock');

    Future<String> spawnHelperIsolate(String name, int isolate_id) async {
      // The entry point for the isolate
      void isolateEntryPoint(SendPort sendPort) {
        final LPWSTR native_LPCWSTR = name.toNativeUtf16(allocator: malloc);
        print(
            "\n $isolate_id =================================== CREATE MUTEX W ==================================== \n");
        final int mutex_address = CreateMutexW(nullptr, 0, native_LPCWSTR);
        final MUTEX_HANDLE = Pointer.fromAddress(mutex_address);

        print(mutex_address);
        print(MUTEX_HANDLE == nullptr);
        print(MUTEX_HANDLE.address);
        print(MUTEX_HANDLE.address == nullptr.address);

        bool acquired = true;
        if (mutex_address == nullptr) {
          print(
              "\n $isolate_id =================================== GET LAST ERROR ==================================== \n");
          int native_last_error = GetLastError();
          print('$isolate_id || $native_last_error');
          String? error_message = getRestrictedErrorDescription(native_last_error);
          print('$isolate_id Error: ${error_message}');
          acquired = false;
        }

        // final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: lockFilePath, nameIsUnixPath: true);

        // Attempt to acquire the lock
        // final acquired = reference.target?.acquire() ?? false;

        // Simulate some work
        sleep(Duration(milliseconds: Random().nextInt(500)));

        // Release the lock
        // reference.target?.unlock();
        // reference.target?.dispose()
        int closed = CloseHandle(MUTEX_HANDLE.address);
        print('$isolate_id  && closed": $closed');

        malloc.free(native_LPCWSTR);

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
      final name = 'cross_isolate_windows_lock';
      final identifier = join("Global\\", name);

      // Spawn the first helper isolate
      final result1 = spawnHelperIsolate(identifier, 1);
      final result2 = spawnHelperIsolate(identifier, 2);
      final result3 = spawnHelperIsolate(identifier, 3);
      final result4 = spawnHelperIsolate(identifier, 4);

      // Wait for both isolates to complete their work
      final outcomes = await Future.wait([result1, result2, result3, result4]);

      // Check that both isolates report success
      // This implies that they were both able to acquire and release the lock without interference
      expect(outcomes, everyElement(equals('success')));
    });
  });
}

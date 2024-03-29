@TestOn('windows')

import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:win32/src/types.dart' show HANDLE, LPWSTR;
import 'package:win32/win32.dart' show BOOL;

import 'package:path/path.dart' show join;
import 'package:runtime_native_named_locks/src/bindings/windows.dart'
    show CreateMutexW, ReleaseMutex, WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT;
import 'package:test/test.dart' show TestOn, group, test;
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
      print(mutex_address);

      final MUTEX_HANDLE = Pointer.fromAddress(mutex_address);

      print(MUTEX_HANDLE.address);

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

      final RESULT_HANDLE = Pointer.fromAddress(result);

      print(RESULT_HANDLE.address);

      print('$INFINITE, $WAIT_OBJECT_0, $WAIT_ABANDONED, $WAIT_TIMEOUT');

      print("\n=================================== RELEASE MUTEX ==================================== \n");
      print('ReleaseMutex');
      final released = ReleaseMutex(MUTEX_HANDLE.address);
      print('0 is false and 1 is true, 0 is even and 1 is odd');
      print(released.isOdd);

      print("\n=================================== CLOSE HANDLE ==================================== \n");
      final closed = CloseHandle(MUTEX_HANDLE.address);
      print('0 is false and 1 is true, 0 is even and 1 is odd');
      print(closed.isOdd);

      print("\n=================================== FREE ==================================== \n");
      malloc.free(native_LPCWSTR);
      malloc.free(MUTEX_HANDLE);
      malloc.free(RESULT_HANDLE);
    });
  });
}

@TestOn('linux || mac-os')

// import 'dart:ffi';
// import 'package:ffi/ffi.dart';
//
// import 'package:win32/src/types.dart' show HANDLE, LPWSTR;
// import 'package:win32/win32.dart' show BOOL;
//
// import 'package:path/path.dart' show join;
// import 'package:runtime_native_named_locks/src/bindings/windows.dart'
//     show CreateMutexW, ReleaseMutex, WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT;
import 'dart:ffi' show Pointer;

import "package:ffi/ffi.dart" show StringUtf16Pointer, Utf16, Utf16Pointer;
import 'package:path/path.dart' show dirname, join;
import 'package:runtime_native_named_locks/src/bindings/unix.dart' show sem_open;
import 'package:stack_trace/stack_trace.dart' show Frame;
import 'package:stdlibc/stdlibc.dart' show O_CREAT, errno, strerror;
import 'package:test/test.dart' show TestOn, group, test;
// import 'package:win32/win32.dart' show CloseHandle, GetLastError, INFINITE, WaitForSingleObject;
// import 'package:windows_foundation/internal.dart' show getRestrictedErrorDescription;

void main() {
  group('Unix Semaphores Binding Tests', () {
    test('Initialize & test FFI Bindings', () {
      print("\n=================================== SEM_OPEN ==================================== \n");
      final String name = join(dirname(Frame.caller(0).uri.toFilePath()), 'testing_named_unix_locks.lock');

      Pointer<Utf16> native_name = name.toNativeUtf16();
      print(native_name.toDartString());
      int oflag = O_CREAT; /* O_CREAT = 512 */
      int mode_t = 0777; /* 0644 | 0777 | 0600 */
      int value = 1;
      final semaphore = sem_open(native_name, oflag);
      // , mode_t, value

      print(semaphore);

      int code = errno;

      print("get_sem_open_error string: ${strerror(code)}");
      // print(get_sem_open_error());

      print("\n=================================== WAIT FOR SINGLE OBJECT ==================================== \n");

      print("\n=================================== RELEASE MUTEX ==================================== \n");

      print("\n=================================== CLOSE HANDLE ==================================== \n");

      print("\n=================================== FREE ==================================== \n");
    });
  });
}

import 'dart:ffi' show Pointer, nullptr;
import 'dart:io';

import 'package:ffi/ffi.dart' show StringUtf16Pointer, malloc;
import 'package:path/path.dart' show dirname, join;
import 'package:runtime_native_named_locks/src/bindings/windows.dart'
    show CreateMutexW, WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT;
import 'package:stack_trace/stack_trace.dart';
import 'package:win32/win32.dart' show CloseHandle, GetLastError, INFINITE, LPWSTR, WaitForSingleObject;
import 'package:windows_foundation/internal.dart' show getRestrictedErrorDescription;

main() {
  final String exe = join(dirname(Frame.caller(0).uri.toFilePath()), 'native_create_mutex_w.exe');

  // Run CPP native_create_mutex_w.exe
  // test\native_create_mutex_w.exe
  final Future<Process> started = Process.start(exe, [], mode: ProcessStartMode.detachedWithStdio);

  started.then((Process process) {
    print('Started process: ${process.pid}');
    process.stdout.listen((List<int> event) {
      print('stdout: ${String.fromCharCodes(event)}');
    });
    process.stderr.listen((List<int> event) {
      print('stderr: ${String.fromCharCodes(event)}');
    });
    process.exitCode.then((int code) {
      print('Exit code: $code');
    });
  });

  final name = 'cross_isolate_windows_lock';
  final identifier = join("Global\\", name);

  print(identifier);
  final LPWSTR native_LPCWSTR = name.toNativeUtf16(allocator: malloc);
  print("\n =================================== CREATE MUTEX W ==================================== \n");
  final int mutex_address = CreateMutexW(nullptr, 1, native_LPCWSTR);
  final MUTEX_HANDLE = Pointer.fromAddress(mutex_address);

  print(mutex_address);
  print(MUTEX_HANDLE == nullptr);
  print(MUTEX_HANDLE.address);
  print(MUTEX_HANDLE.address == nullptr.address);

  // if (mutex_address == nullptr) {
  print("\n =================================== GET LAST ERROR ==================================== \n");
  int native_last_error = GetLastError();
  print('$native_last_error');
  String? error_message = getRestrictedErrorDescription(native_last_error);
  print('Error: ${error_message}');
  // acquired = false;
  // }

  final result = WaitForSingleObject(MUTEX_HANDLE.address, INFINITE);
  print('|| $result');

  // final RESULT_HANDLE = Pointer.fromAddress(result);

  // print(RESULT_HANDLE.address);

  print('$INFINITE, $WAIT_OBJECT_0, $WAIT_ABANDONED, $WAIT_TIMEOUT');

  // final WeakReference<NamedLockGuard> reference = NamedLocks.create(name: lockFilePath, nameIsUnixPath: true);

  // Attempt to acquire the lock
  // final acquired = reference.target?.acquire() ?? false;

  // Simulate some work
  // sleep(Duration(milliseconds: Random().nextInt(500)));

  // Release the lock
  // reference.target?.unlock();
  // reference.target?.dispose()
  // int closed = CloseHandle(MUTEX_HANDLE.address);
  // print('$isolate_id  && closed": $closed');

  sleep(Duration(seconds: 30));

  malloc.free(native_LPCWSTR);

  int closed = CloseHandle(MUTEX_HANDLE.address);
  print('closed": $closed');
}

import 'dart:async' show Completer;
import 'dart:ffi' show Allocator, Pointer, Uint16, Uint16Pointer, nullptr;
import 'dart:io' show File, Process, ProcessStartMode, sleep;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' show Utf16, malloc;
import 'package:path/path.dart' show dirname, join;
import 'package:runtime_native_named_locks/src/bindings/windows.dart'
    show CreateMutexW, CreateSemaphoreW, WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT;
import 'package:stack_trace/stack_trace.dart' show Frame;
import 'package:win32/win32.dart'
    show BOOL, CloseHandle, GetLastError, INFINITE, LPWSTR, NULL, TRUE, WaitForSingleObject;
import 'package:windows_foundation/internal.dart' show getRestrictedErrorDescription;

extension StringUtf16Pointer on String {
  Pointer<Utf16> toNativeUtf16() {
    final units = codeUnits;
    final Pointer<Uint16> result = malloc.allocate<Uint16>(units.length + 1);
    final Uint16List nativeString = result.asTypedList(units.length + 1);
    nativeString.setRange(0, units.length, units);
    nativeString[units.length] = 0;
    print("Native String: $nativeString");
    return result.cast();
  }
}

main() async {
  final String exe = join(dirname(Frame.caller(0).uri.toFilePath()), 'native_create_semaphore_w.exe');
  // ensure exe exists
  print('exe exists ${File(exe).existsSync()}');

  final Process process = await Process.start(exe, [], mode: ProcessStartMode.normal);

  print('Started process: ${process.pid}');

  process.stdout.listen((List<int> event) {
    print('process_b stdout: ${String.fromCharCodes(event)}');
  });
  process.stderr.listen((List<int> event) {
    print('process_b stderr: ${String.fromCharCodes(event)}');
  });
  process.exitCode.then((int code) {
    print('process_b Exit code: $code');
  });

  final Process process_b = await Process.start(exe, [], mode: ProcessStartMode.normal);

  print('Started process: ${process_b.pid}');

  final Completer<void> completer = Completer<void>();

  process_b.stdout.listen((List<int> event) {
    if (!completer.isCompleted) completer.complete();
    print('process_b stdout: ${String.fromCharCodes(event)}');
  });
  process_b.stderr.listen((List<int> event) {
    print('process_b stderr: ${String.fromCharCodes(event)}');
  });

  process_b.exitCode.then((int code) {
    print('process_b Exit code: $code');
  });

  final name = 'cross_isolate_windows_lock';
  final identifier = join("Global\\", name);

  await completer.future;

  print(identifier);
  final LPWSTR native_LPCWSTR = name.toNativeUtf16();
  print(native_LPCWSTR.address);

  print("\n =================================== CREATE MUTEX W ==================================== \n");
  final int mutex_address = CreateSemaphoreW(NULL, 1, 1, native_LPCWSTR);
  // final int mutex_address = CreateMutexW(NULL, TRUE, native_LPCWSTR);
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

  print("\n =================================== WAIT FOR SINGLE OBJECT ==================================== \n");
  final result = WaitForSingleObject(MUTEX_HANDLE.address, 0);
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

  // Run CPP native_create_mutex_w.exe
  // test\native_create_mutex_w.exe

  // sleep(Duration(seconds: 30));
  //
  // malloc.free(native_LPCWSTR);
  //
  // int closed = CloseHandle(MUTEX_HANDLE.address);
  // print('closed": $closed');
}

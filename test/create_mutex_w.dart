import 'dart:async' show Completer;
import 'dart:ffi' show Allocator, Pointer, Uint16, Uint16Pointer, nullptr;
import 'dart:io' show File, Process, ProcessStartMode, sleep;
import 'dart:typed_data' show Uint16List;

import 'package:ffi/ffi.dart' show StringUtf16Pointer, Utf16, Utf16Pointer, malloc;
import 'package:path/path.dart' show dirname, join;
import 'package:runtime_native_named_locks/src/bindings/windows.dart'
    show CreateMutexW, CreateSemaphoreW, WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT;
import 'package:stack_trace/stack_trace.dart' show Frame;
import 'package:win32/win32.dart'
    show BOOL, CloseHandle, GetLastError, INFINITE, LPWSTR, NULL, TRUE, WaitForSingleObject;
import 'package:windows_foundation/internal.dart' show getRestrictedErrorDescription;

void printCharacterCodesInHex(String input) {
  final StringBuffer hexCodes = StringBuffer();
  for (int unit in input.codeUnits) {
    hexCodes.write('0x${unit.toRadixString(16).padLeft(4, '0')} ');
  }
  print("Dart string character codes in hex: $hexCodes");
}

// extension StringUtf16Pointer on String {
//   Pointer<Utf16> toNativeUtf16() {
//     final units = codeUnits;
//     final Pointer<Uint16> result = malloc.allocate<Uint16>(units.length + 1);
//     final Uint16List nativeString = result.asTypedList(units.length + 1);
//     nativeString.setRange(0, units.length, units);
//     nativeString[units.length] = 0;
//     print("Native String: $nativeString");
//     print("Character codes in Dart string: ${nativeString.map((unit) => '0x${unit.toRadixString(16)}').join(' ')}");
//
//     return result.cast();
//   }
// }

main() async {
  final String exe = join(dirname(Frame.caller(0).uri.toFilePath()), 'native_create_semaphore_w.exe');
  // ensure exe exists
  print('exe exists ${File(exe).existsSync()}');

  final Process process = await Process.start(exe, [], mode: ProcessStartMode.normal);

  print('Started process: ${process.pid}');

  process.stdout.listen((List<int> event) {
    print('process stdout: ${String.fromCharCodes(event)}');
  });
  process.stderr.listen((List<int> event) {
    print('process stderr: ${String.fromCharCodes(event)}');
  });
  process.exitCode.then((int code) {
    print('process Exit code: $code');
  });

  final Process process_b = await Process.start(exe, [], mode: ProcessStartMode.normal);

  print('Started process_b: ${process_b.pid}');

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

  final name = join("Global\\", 'cross_isolate_windows_lock');

  await completer.future;

  print(name);
  final LPWSTR native_LPCWSTR = name.toNativeUtf16();
  print('address: ${native_LPCWSTR.address}');

  // Print the address of the native string
  print("The address of 'name' is: 0x${native_LPCWSTR.address.toRadixString(16).padLeft(16, '0')}");

  // Print the entire string referred by 'nativeName'
  print("Complete string: ${native_LPCWSTR.toDartString()}");

  // Print each character's Unicode code in 'nativeName' as a list of hex values
  // print("Character codes in Dart string: ${name.codeUnits.map((unit) => '0x${unit.toRadixString(16)}').join(' ')}");

  // Free the allocated memory for the native string

  printCharacterCodesInHex(name);

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

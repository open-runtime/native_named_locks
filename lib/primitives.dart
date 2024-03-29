library;

import 'dart:ffi' show Finalizable, Pointer;
import 'dart:io' show File, Platform, sleep;
import 'package:ffi/ffi.dart' show calloc;
// import 'package:meta/meta.dart';
// import 'package:native_synchronization/primitives.dart' show Mutex;
import 'package:path/path.dart' show absolute, join, normalize, split;
// import 'package:runtime_native_named_locks/errors.dart' show NamedLockError;
import 'package:runtime_native_named_locks/utils.dart';
import 'package:win32/win32.dart';
// import 'src/bindings/windows.dart'
//     show
//         CreateMutexW,
//         ReleaseMutex,
//         WAIT_ABANDONED,
//         WAIT_OBJECT_0,
//         WAIT_TIMEOUT;

import 'package:win32/src/types.dart' show HANDLE;
import 'package:stdlibc/stdlibc.dart'
    show
        FD_CLOEXEC,
        F_GETFL,
        F_SETFD,
        F_SETLK,
        F_UNLCK,
        F_WRLCK,
        Flock,
        O_CREAT,
        O_RDWR,
        SEEK_SET,
        close,
        errno,
        fcntl,
        open,
        strerror;

// import 'package:windows_foundation/internal.dart'
//     show BoolConversions, HString, IPropertyValue, getRestrictedErrorDescription;

part 'unix_named_lock.dart';

part 'windows_named_lock.dart';

// sealed class NamedLockNameType<T> implements Finalizable {
//   NamedLockNameType._();
//
//   factory NamedLockNameType() => Platform.isWindows
//       ? _WindowsNamedLockNameType() as NamedLockNameType<T>
//       : _UnixNamedLockNameType() as NamedLockNameType<T>;
// }

sealed class NamedLock implements Finalizable {
  final String identifier;

  int get address => throw UnimplementedError(
      "Class Property Getter 'address' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  NamedLock._({required String this.identifier});

  factory NamedLock({required String identifier}) =>
      Platform.isWindows ? _WindowsNamedLock(identifier: identifier) : _UnixNamedLock(identifier: identifier);

  bool acquire({int MAX_ATTEMPTS = 100, Duration INTERVAL = const Duration(milliseconds: 50)}) =>
      throw UnimplementedError("Class Member 'bool acquire()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  bool lock() =>
      throw UnimplementedError("Class Member 'void lock()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  bool unlock() =>
      throw UnimplementedError("Class Member 'void unlock()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  bool dispose() =>
      throw UnimplementedError("Class Member 'void dispose()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  String toString() =>
      throw UnimplementedError("Class Member 'toString()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");
}

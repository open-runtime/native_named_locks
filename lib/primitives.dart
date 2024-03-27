library;

import 'dart:ffi' show Finalizable, NativeType, Pointer, nullptr;
import 'dart:io' show File, FileMode, FileSystemException, OSError, Platform;
import 'package:ffi/ffi.dart' show calloc;
import 'package:meta/meta.dart';
import 'package:native_synchronization/primitives.dart' show Mutex;
import 'package:runtime_native_named_locks/errors.dart' show NamedLockError;
import 'src/bindings/windows.dart'
    show
        CloseHandle,
        CreateMutexW,
        GetLastError,
        INFINITE,
        ReleaseMutex,
        WAIT_ABANDONED,
        WAIT_OBJECT_0,
        WAIT_TIMEOUT,
        WaitForSingleObject;

import 'package:win32/src/types.dart' show HANDLE;
import 'package:stdlibc/stdlibc.dart'
    show
        EDEADLK,
        EINTR,
        EWOULDBLOCK,
        F_GETFL,
        F_SETLK,
        F_UNLCK,
        F_WRLCK,
        Flock,
        LOCK_EX,
        LOCK_NB,
        LOCK_UN,
        O_CREAT,
        O_EXCL,
        O_RDWR,
        SEEK_SET,
        close,
        fcntl,
        open;

import 'package:windows_foundation/internal.dart' show HString, getRestrictedErrorDescription;

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

  bool acquire() =>
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

class NamedLockGuard {
  late final bool disposed;

  final String identifier;

  final NamedLock _lock;

  final Mutex mutex = Mutex();

  NamedLockGuard._({required NamedLock lock, required String this.identifier}) : _lock = lock;

  factory NamedLockGuard({required NamedLock lock, required String identifier}) =>
      NamedLockGuard._(lock: lock, identifier: identifier);

  bool acquire() {
    // TODO potentially ensure that the file/global namespace exists before acquiring?
    return mutex.runLocked<bool>(() => _lock.acquire());
  }

  bool lock() {
    // TODO potentially ensure that the file/global namespace exists before locking?
    return mutex.runLocked(() => _lock.lock());
  }

  bool unlock() {
    // TODO potentially ensure that the file/global namespace exists before unlocking?
    return mutex.runLocked(() => _lock.unlock());
  }

  bool dispose() {
    return disposed = mutex.runLocked(() {
      final status = _lock.dispose();
      File(identifier).deleteSync();
      return status;
    });
  }

  String toString() => 'NamedLockGuard(identifier: $identifier)';
}

import 'dart:io' show File;
import 'package:meta/meta.dart';
import 'package:native_synchronization/primitives.dart' show Mutex;
import 'package:runtime_native_named_locks/primitives.dart' show NamedLock;

class NamedLockGuard {
  late final bool disposed;

  @visibleForTesting
  final NamedLock _lock;

  @visibleForTesting
  final Mutex _mutex = Mutex();

  NamedLockGuard._({required NamedLock lock}) : _lock = lock;

  factory NamedLockGuard({required NamedLock lock}) => NamedLockGuard._(lock: lock);

  bool acquire() {
    // TODO potentially ensure that the file/global namespace exists before acquiring?
    return _mutex.runLocked<bool>(() => _lock.acquire());
  }

  bool lock() {
    // TODO potentially ensure that the file/global namespace exists before locking?
    return _mutex.runLocked(() => _lock.lock());
  }

  bool unlock() {
    // TODO potentially ensure that the file/global namespace exists before unlocking?
    return _mutex.runLocked(() => _lock.unlock());
  }

  bool dispose() {
    return disposed = _mutex.runLocked(() {
      final status = _lock.dispose();
      File(_lock.identifier).deleteSync();
      return status;
    });
  }

  String toString() => 'NamedLockGuard(identifier: ${_lock.identifier})';

  get identifier => _lock.identifier;
}

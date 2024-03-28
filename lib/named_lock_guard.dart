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
    // TODO use native shared mmap to share the number of processes waiting on the lock?
    // TODO potentially ensure that the file/global namespace exists before acquiring?
    return _mutex.runLocked<bool>(() => _lock.acquire());
  }

  bool lock() {
    // TODO potentially ensure that the file/global namespace exists before locking?
    return _mutex.runLocked(() => _lock.lock());
  }

  // TODO: Implement a something like an auto dispose? This may cause issues for other locks calling dispose as well as the lock file being deleted and we'd need to handle the deleteSync error if the file doesn't exist
  bool unlock() {
    // TODO potentially ensure that the file/global namespace exists before unlocking?
    return _mutex.runLocked(() => _lock.unlock());
  }

  // Not sure if we should even give people the option to not delete the lock file?
  // TODO: Implement a way to know how many locks are currently held by the process
  bool dispose(/*{bool delete = true}*/) {
    try {
      return disposed = _mutex.runLocked(() {
        final status = _lock.dispose();
        bool deleted = false;

        try {
          deleted = !(File(_lock.identifier)..deleteSync()).existsSync();
        } catch (e) {
          //   Handle delete file error if it was deleted by another process
          if (e.toString().contains("PathNotFoundException: Cannot delete file")) {
            deleted = true;
          }
        }

        return deleted || status;
      });
    } catch (e) {
      if (e.toString().contains("LateInitializationError: Field 'disposed' has already been initialized.")) ;
      throw Exception('Lock has already been disposed by the current process: [IDENTIFIER] ${_lock.identifier}');
    }
  }

  String toString() => 'NamedLockGuard(identifier: ${_lock.identifier})';

  get identifier => _lock.identifier;
}

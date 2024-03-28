import 'dart:collection' show HashMap;
import 'dart:io' show File, Platform;
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:native_synchronization/primitives.dart' show Mutex;
import 'package:path/path.dart' show absolute, current, isAbsolute, join;
import 'package:runtime_native_named_locks/primitives.dart' show NamedLock;

import 'package:runtime_native_named_locks/errors.dart' show NamedLockError;
import 'package:runtime_native_named_locks/named_lock_guard.dart' show NamedLockGuard;

/// Type alias to `Future<T>`.
// typedef AsyncResult<T> = Future<T>;

// final OPENED_RAW_LOCKS = ConditionVariable().wait(.create(());)

/// Cross-process lock that is identified by name.
class NamedLocks {
  // TODO implement way to to keep a lock count across isolates.

  @visibleForTesting
  static final Mutex _OPENED_LOCKS_MUTEX = Mutex();

  @visibleForTesting
  static late final HashMap<String, WeakReference<NamedLockGuard>> _OPENED_LOCKS =
      HashMap<String, WeakReference<NamedLockGuard>>();

  /// Create/open a named lock.
  ///
  /// This will create/open a file and use `flock` on it. The path of
  /// the lock file will be `$TMPDIR/<name>.lock`, or `/tmp/<name>.lock`
  /// if `TMPDIR` environment variable is not set.
  ///
  /// If you want to specify the exact path, then use [NamedLock.withPath] - note .lock will not be appended
  static WeakReference<NamedLockGuard> create({required String name, bool nameIsUnixPath = false}) {
    print(name);

    if (name.isEmpty) {
      throw NamedLockError.emptyName;
    }

    print('$name is valid in a basic sense.');

    late String identifier;

    if (Platform.isWindows) {
      if (name.contains('\0') || name.contains('/') || name.contains('\\')) {
        throw NamedLockError.invalidCharacter;
      }
      identifier = join("Global\\{}", name);
    } else if (Platform.isMacOS || Platform.isLinux) {
      print('We are on a Unix-like system and the name is not a unix path and or the file exists synchronously.');

      identifier = nameIsUnixPath
          ? (isAbsolute(name) ? File(name).path : File.fromUri(Uri.file(name, windows: Platform.isWindows)).path)
          : join(Platform.environment['TMPDIR'] ?? '/tmp', '$name.lock');

      print("We're on a unix-like system and the identifier is $identifier. and the name is $name");
    }

    print("We're about to check if the lock already exists in the opened locks with a mutex.");

    late final bool exists;
    // TODO ensure we actually to fail on existing locks
    try {
      exists = _OPENED_LOCKS_MUTEX.runLocked(() {
        print('We are inside the mutex running as locked checking for contained key: $identifier');
        print(NamedLocks._OPENED_LOCKS.containsKey(identifier));
        return NamedLocks._OPENED_LOCKS.containsKey(identifier);
      });
    } catch (e) {
      print('We failed to check if the lock already exists in the opened locks with a mutex.');
      rethrow;
    }

    // In this instance we are checking if the lock is registered in the process memory. The lock may exist as a file.
    print('Does the lock already exist? $exists');

    !exists || (throw NamedLockError.alreadyExists);

    print('The lock does not already exist in memory and we are good to go with creation.');

    return NamedLocks._create(identifier: identifier);
  }

  @visibleForTesting
  static WeakReference<NamedLockGuard> _create({required String identifier}) {
    return _OPENED_LOCKS_MUTEX.runLocked<WeakReference<NamedLockGuard>>(
        () => _OPENED_LOCKS.putIfAbsent(identifier, () => WeakReference<NamedLockGuard>(
            // File lock is created in the constructor of NamedLock here
            NamedLockGuard(lock: NamedLock(identifier: identifier)))));
  }

  @visibleForTesting
  static NamedLockGuard _get({required String identifier}) {
    final WeakReference<NamedLockGuard>? guard = _OPENED_LOCKS_MUTEX.runLocked<WeakReference<NamedLockGuard>?>(
        () => _OPENED_LOCKS.containsKey(identifier) ? _OPENED_LOCKS[identifier] : null);

    guard ?? (throw NamedLockError.attemptedToAccessUnknownLock);
    guard.target ?? (throw NamedLockError.guardTargetIsNull);

    return guard.target as NamedLockGuard;
  }

  /// Try to lock named lock.
  ///
  /// If it is already locked, an exception will be thrown.
  static NamedLockGuard acquire({required String identifier}) {
    final NamedLockGuard guard = _get(identifier: identifier);

    final acquired = guard.acquire();

    acquired || (throw NamedLockError.lockFailed);

    return guard;
  }

  /// Lock named lock.
  static NamedLockGuard lock({required String identifier}) {
    return _get(identifier: identifier)..lock();
  }

  /// Unlock named lock
  static NamedLockGuard unlock({required String identifier}) {
    return _get(identifier: identifier)..unlock();
  }

  /// disposes named lock & named lock guard and removes it from the opened locks.
  static bool dispose({required String identifier}) {
    final NamedLockGuard guard = _get(identifier: identifier);

    guard.dispose() || (throw NamedLockError.disposeFailed);

    final WeakReference<NamedLockGuard>? removed =
        _OPENED_LOCKS_MUTEX.runLocked<WeakReference<NamedLockGuard>?>(() => _OPENED_LOCKS.remove(identifier));

    return removed?.target?.disposed ?? (throw NamedLockError.disposeFailed);
  }
}

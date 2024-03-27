import 'dart:async' show Future;
import 'dart:collection';
import 'dart:io' show File, Platform;
import 'package:native_synchronization/primitives.dart';
import 'package:path/path.dart' show join;
import 'package:runtime_native_named_locks/primitives.dart';

import 'errors.dart' show NamedLockError;

/// Type alias to `Future<T>`.
// typedef AsyncResult<T> = Future<T>;

// final OPENED_RAW_LOCKS = ConditionVariable().wait(.create(());)

/// Cross-process lock that is identified by name.
class NamedLocks {
  static final Mutex OPENED_LOCKS_MUTEX = Mutex();

  static late final HashMap<String, WeakReference<NamedLockGuard>> _OPENED_LOCKS =
      OPENED_LOCKS_MUTEX.runLocked<HashMap<String, WeakReference<NamedLockGuard>>>(
          () => HashMap<String, WeakReference<NamedLockGuard>>());

  /// Create/open a named lock.
  ///
  /// This will create/open a file and use `flock` on it. The path of
  /// the lock file will be `$TMPDIR/<name>.lock`, or `/tmp/<name>.lock`
  /// if `TMPDIR` environment variable is not set.
  ///
  /// If you want to specify the exact path, then use [NamedLock.withPath] - note .lock will not be appended
  static WeakReference<NamedLockGuard> create({required String name, bool nameIsUnixPath = false}) {
    if (name.isEmpty) {
      throw NamedLockError.emptyName.toString();
    }

    if (name.contains('\0') || name.contains('/') || name.contains('\\')) {
      throw NamedLockError.invalidCharacter;
    }

    late String identifier;

    if (Platform.isWindows) {
      identifier = join("Global\\{}", name);
    } else if (Platform.isMacOS || Platform.isLinux) {
      // TODO ensure this doesnt conflict with creation of the lock file within unix_named_lock.dart
      // If the name is a unix path we check if the file exists and if not we throw an error
      nameIsUnixPath && (File(name).existsSync() || (throw NamedLockError.unixPathForNamedLockUnverified));

      identifier = nameIsUnixPath ? File(name).path : join(Platform.environment['TMPDIR'] ?? '/tmp', '$name.lock');
    }

    // TODO ensure we actually to fail on existing locks
    final bool exists = OPENED_LOCKS_MUTEX.runLocked(() => _OPENED_LOCKS.containsKey(name));
    !exists || (throw NamedLockError.alreadyExists);

    return NamedLocks._create(identifier: identifier);
  }

  static WeakReference<NamedLockGuard> _create({required String identifier}) {
    return OPENED_LOCKS_MUTEX.runLocked<WeakReference<NamedLockGuard>>(() => _OPENED_LOCKS.putIfAbsent(
        identifier,
        () => WeakReference<NamedLockGuard>(
            NamedLockGuard(lock: NamedLock(identifier: identifier), identifier: identifier))));

    // TODO: Implement a mechanism to ensure only one `RawNamedLock` exists
    // for each name in each process, similar to the `OPENED_RAW_LOCKS` in Rust.
    // return RawNamedLock(path);
  }

  static NamedLockGuard _get({required String identifier}) {
    final WeakReference<NamedLockGuard>? guard = OPENED_LOCKS_MUTEX.runLocked<WeakReference<NamedLockGuard>?>(
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
        OPENED_LOCKS_MUTEX.runLocked<WeakReference<NamedLockGuard>?>(() => _OPENED_LOCKS.remove(identifier));

    return removed?.target?.disposed ?? (throw NamedLockError.disposeFailed);
  }
}

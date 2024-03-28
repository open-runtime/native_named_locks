part of 'primitives.dart';

enum LockOperation {
  LOCK_EX,
  LOCK_NB,
  LOCK_UN,
}

class _UnixNamedLock extends NamedLock {
  bool locked = false;
  bool acquired = false;

  late int fd;

  @visibleForTesting
  late final File _file;

  @visibleForTesting
  late Flock? _lock;

  @visibleForTesting
  late Flock? _unlock;

  _UnixNamedLock({required String identifier}) : super._(identifier: identifier) {
    // Should this be done immediately or require the user to call acquire?
    acquired = _acquire();
  }

  @override
  bool acquire({int MAX_ATTEMPTS = 1000, Duration INTERVAL = const Duration(milliseconds: 50)}) {
    !locked && !acquired
        ? _acquire(MAX_ATTEMPTS: MAX_ATTEMPTS, INTERVAL: INTERVAL)
        : print('[WARNING] Process has already acquired NamedLock: $identifier.');
    return acquired && lock();
  }

  bool _acquire({int MAX_ATTEMPTS = 1000, Duration INTERVAL = const Duration(milliseconds: 50)}) {
    // TODO How many attempts should we make to open the file? This is similar to the windows implementation WaitForSingleObject(mutex_handle, 0) where the second parameter is timeout in milliseconds.
    int _fd = -1;
    int _MAX_ATTEMPTS = MAX_ATTEMPTS;

    while (_fd.isNegative && _MAX_ATTEMPTS > 0) {
      try {
        // Attempt to open the file with O_CREAT | O_EXCL | O_RDWR to ensure it doesn't already exist
        // TODO we dont need O_EXCL here, we are just creating the file
        errno = 0;
        _fd = fd = open(identifier, flags: O_CREAT | O_RDWR);
        // We should get a permission denied error if the file already exists
        // and in that case we will need to wait a bit and try again?

        if (fd.isNegative) {
          // Failed to open the file, possibly because it already exists or due to permissions
          print(
              'Failed to open the file exclusively: $fd from `open(identifier, flags: O_CREAT | O_RDWR)`: ${strerror(errno)} blocking execution and retrying in 5 seconds.');

          sleep(INTERVAL);
        } else {
          // We successfully opened the file
          print('Successfully opened the file exclusively: $fd from `open(identifier, flags: O_CREAT | O_RDWR)`.');
        }
      } catch (e) {
        // TODO Polling here? Or just rethrow?
        print(e);
      }

      _MAX_ATTEMPTS-- < 0 &&
          (throw Exception(
              'Failed to open the file exclusively within $MAX_ATTEMPTS: $fd from `open(identifier, flags: O_CREAT | O_RDWR)`: ${strerror(errno)}'));
    }

    // Verifies if the file flags can be retrieved for a given file descriptor and checks that the read/write flag (O_RDWR) is set.
    ((fcntl(fd, F_GETFL) & O_RDWR).isEven) ||
        (throw Exception(
            'Failed to open the file with read/write permissions on the file. From `fcntl(fd, F_GETFL) & O_RDWR)`. [Name]: $identifier [FD]: $fd [Errno]: ${strerror(errno)}'));

    // Sets the FD_CLOEXEC flag on the file descriptor fd. The purpose of setting this flag is to ensure that the file descriptor is automatically closed during an exec operation, preventing the file descriptor from leaking to child processes. The return value of this operation indicates success (0) or failure (-1), not a file descriptor.
    // This is a flag (File Descriptor Close-On-Exec) that can be set on a file descriptor, indicating that the file descriptor should automatically be closed when executing a new program via one of the exec family of functions.
    (fcntl(fd, F_SETFD, FD_CLOEXEC).isEven) ||
        (throw Exception(
            'Failed to set File Descriptor Close-On-Exec flag on the file. From `fcntl(fd, F_SETFD, FD_CLOEXEC)`. [Name]: $identifier [FD]: $fd [Errno]: ${strerror(errno)}'));

    // Set the file path
    _file = File(identifier);

    return true;
  }

  @override
  bool lock() {
    final Flock _lock = Flock(
      l_type: F_WRLCK, // Set the lock type to write lock.
      l_whence: SEEK_SET, // The lock offset is relative to the beginning of the file.
      l_start: 0, // Start of the lock offset.
      l_len: 0, // Length of the lock; 0 means to lock the entire file.
    );

    // Retry logic here with sleep?
    return locked =
        fcntl(fd, F_SETLK, _lock) != -1 || (throw Exception('Failed to lock the file exclusively: ${strerror(errno)}'));

    // return _flock(LockOperation.LOCK_EX);
  }

  @override
  bool unlock() {
    final Flock _lock = Flock(
      l_type: F_UNLCK, // Set the lock type to unlock.
      l_whence: SEEK_SET, // The unlock offset is relative to the beginning of the file.
      l_start: 0, // Start of the unlock offset.
      l_len: 0, // Length of the unlock; 0 means to unlock the entire file.
    );

    locked = !(fcntl(fd, F_SETLK, _lock) != -1 ||
        (throw Exception('Failed to unlock the file exclusively: ${strerror(errno)}')));

    // Retry logic here with sleep? Shouldn't be needed as we are unlocking and we must already have the lock
    return !locked;
  }

  @override
  bool dispose() {
    // Shouldn't ever happen as we will throw in the unlock method if we fail to unlock
    (!locked || unlock()) || (throw Exception('Failed to unlock before disposal: ${strerror(errno)}'));
    close(fd);
    return File(_file.path).existsSync();
  }

  @override
  String toString() => 'NamedLock(name: $identifier)';

  // TODO return the file path as hash code
  @override
  int get address => _file.path.hashCode;
}

//
// bool _open() {
//   // Prepare a lock structure for exclusive write lock
//   _lock = Flock(
//     l_type: F_WRLCK, // Request an exclusive write lock
//     l_whence: SEEK_SET,
//     l_start: 0,
//     l_len: 0, // Lock the entire file
//   );
//
//   // Attempt to set the lock using fcntl -1 is failed
//   if (fcntl(fd, F_SETLK, lock).isNegative) {
//     // Failed to acquire the lock, possibly because the file is locked by another process
//     print("Failed to lock the file exclusively.");
//     close(fd); // Make sure to close the file descriptor if locking fails
//     _lock = null; // Clear the lock structure
//     fd = -1; // Reset the file descriptor
//     return false;
//   }
//
//   !fd.isNegative ||
//       (throw Exception(
//           'Unexpended [UNIX] file handle value, shouldn\'t be negative at this point: ${NamedLockError.createFailed} [Name]: $identifier [FD]: $fd'));
//
//   return true;
// }

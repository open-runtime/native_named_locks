part of 'primitives.dart';

enum LockOperation {
  LOCK_EX,
  LOCK_NB,
  LOCK_UN,
}

// TODO implement mman map to track held locks between processes
class _UnixNamedLock extends NamedLock {
  // Maybe leverage mutexes to protect these?
  bool locked = false;
  bool acquired = false;

  // file descriptor
  late int _fd;

  late final File _file;

  _UnixNamedLock({required String identifier}) : super._(identifier: identifier) {
    // Should this be done immediately or require the user to call acquire?
    acquired = _acquire();
  }

  @override
  bool acquire({int MAX_ATTEMPTS = 100, Duration INTERVAL = const Duration(milliseconds: 50)}) {
    !locked && !acquired
        ? _acquire(MAX_ATTEMPTS: MAX_ATTEMPTS, INTERVAL: INTERVAL)
        : print('[WARNING] Process has already acquired NamedLock: $identifier.');
    return acquired && lock();
  }

  bool _acquire({int MAX_ATTEMPTS = 100, Duration INTERVAL = const Duration(milliseconds: 50)}) {
    // TODO How many attempts should we make to open the file? This is similar to the windows implementation WaitForSingleObject(mutex_handle, 0) where the second parameter is timeout in milliseconds.
    int fd = -1;
    int _MAX_ATTEMPTS = MAX_ATTEMPTS;

    while (fd.isNegative && _MAX_ATTEMPTS > 0) {
      try {
        // Attempt to open the file with O_CREAT | O_EXCL | O_RDWR to ensure it doesn't already exist
        // TODO we dont need O_EXCL here, we are just creating the file
        errno = 0;
        fd = _fd = open(identifier, flags: O_CREAT | O_RDWR);
        // We should get a permission denied error if the file already exists
        // and in that case we will need to wait a bit and try again?

        if (_fd.isNegative) {
          // Failed to open the file, possibly because it already exists or due to permissions
          print(
              'Failed to open the file exclusively: $_fd from `open(identifier, flags: O_CREAT | O_RDWR)`: ${strerror(errno)} blocking execution and retrying in ${INTERVAL.inMilliseconds.toString()} Milliseconds.');

          // TODO Implement backoff logic here and or smart interval i.e. average shared lock duration across processes
          sleep(INTERVAL);
        } else {
          // We successfully opened the file
          print('Successfully opened the file exclusively: $_fd from `open(identifier, flags: O_CREAT | O_RDWR)`.');
        }
      } catch (e) {
        // TODO Polling here? Or just rethrow?
        print(e);
      }

      _MAX_ATTEMPTS-- < 0 &&
          (throw Exception(
              'Failed to open the file exclusively within $MAX_ATTEMPTS: $_fd from `open(identifier, flags: O_CREAT | O_RDWR)`: ${strerror(errno)}'));
    }

    // Verifies if the file flags can be retrieved for a given file descriptor and checks that the read/write flag (O_RDWR) is set.
    ((fcntl(_fd, F_GETFL) & O_RDWR).isEven) ||
        (throw Exception(
            'Failed to open the file with read/write permissions on the file. From `fcntl(fd, F_GETFL) & O_RDWR)`. [Name]: $identifier [FD]: $_fd [Errno]: ${strerror(errno)}'));

    // Sets the FD_CLOEXEC flag on the file descriptor fd. The purpose of setting this flag is to ensure that the file descriptor is automatically closed during an exec operation, preventing the file descriptor from leaking to child processes. The return value of this operation indicates success (0) or failure (-1), not a file descriptor.
    // This is a flag (File Descriptor Close-On-Exec) that can be set on a file descriptor, indicating that the file descriptor should automatically be closed when executing a new program via one of the exec family of functions.
    (fcntl(_fd, F_SETFD, FD_CLOEXEC).isEven) ||
        (throw Exception(
            'Failed to set File Descriptor Close-On-Exec flag on the file. From `fcntl(fd, F_SETFD, FD_CLOEXEC)`. [Name]: $identifier [FD]: $_fd [Errno]: ${strerror(errno)}'));

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
        fcntl(_fd, F_SETLK, _lock) == 0 || (throw Exception('Failed to lock the file exclusively: ${strerror(errno)}'));
  }

  @override
  bool unlock() {
    final Flock _lock = Flock(
      l_type: F_UNLCK, // Set the lock type to unlock.
      l_whence: SEEK_SET, // The unlock offset is relative to the beginning of the file.
      l_start: 0, // Start of the unlock offset.
      l_len: 0, // Length of the unlock; 0 means to unlock the entire file.
    );

    locked = !(fcntl(_fd, F_SETLK, _lock) == 0 ||
        (throw Exception('Failed to unlock the file exclusively: ${strerror(errno)}')));

    // Retry logic here with sleep? Shouldn't be needed as we are unlocking and we must already have the lock
    return !locked;
  }

  @override
  bool dispose() {
    // Shouldn't ever happen as we will throw in the unlock method if we fail to unlock
    (!locked || unlock()) || (throw Exception('Failed to unlock before disposal: ${strerror(errno)}'));
    close(_fd);
    return File(_file.path).existsSync();
  }

  @override
  String toString() => 'NamedLock(name: $identifier)';

  // return the file path as the address, not sure if this is needed?
  @override
  int get address => _file.path.hashCode;
}

bool looksLikeUnixFilePath(String name) {
  return normalize(name).replaceFirst(Platform.pathSeparator, "").contains(Platform.pathSeparator) ||
      split(normalize(name).replaceFirst(Platform.pathSeparator, "")).length > 1;
}

void validateArbitraryUnixLockName(String name) {
  print('validateArbitraryUnixLockName: Validating arbitrary unix lock name: $name');
  // Check if the name starts with a leading slash or contains any slashes
  // return !normalize(name).startsWith(Platform.pathSeparator) && !name.contains('/');
}

void validateFilePathPassedAsUnixLockName(String name) {
  print('validateFilePathPassedAsUnixLockName: Validating file path passed as unix lock name: $name');
  // Check if the name contains multiple path separators
  // return name.split('/').where((element) => element.isNotEmpty).length > 1;
  normalize(name).contains(Platform.pathSeparator) ||
      (throw Exception(
          'Provided named lock name: [$name] is not a valid unix path and was passed with the optional method parameter `bool? nameIsUnixPath` set to true. If you\'d like to use a an arbitrary string as the name of the lock, set the optional method parameter `bool? nameIsUnixPath` to `false` (or simply don\'t pass it) and pass in a valid arbitrary string.'));

  partialPathExistence(absolute(normalize(name))) ||
      (throw Exception(
          'Provided named lock name: [$name] looks like a valid unix path but no path segments i.e. parent directories were found. Try prefixing the path with a home directory, root directory, temp directory, present working directory or pre-existing other parent directory.'));
}

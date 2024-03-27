part of 'primitives.dart';

enum LockOperation {
  LOCK_EX,
  LOCK_NB,
  LOCK_UN,
}

class _UnixNamedLock extends NamedLock {
  late int fd;

  @visibleForTesting
  late final File _file;

  @visibleForTesting
  late Flock? _lock;

  @visibleForTesting
  late Flock? _unlock;

  _UnixNamedLock({required String identifier}) : super._(identifier: identifier) {
    try {
      // Attempt to open the file with O_CREAT | O_EXCL | O_RDWR to ensure it doesn't already exist
      // TODO we dont need O_EXCL here, we are just creating the file
      fd = open(identifier, flags: O_CREAT | O_RDWR);
    } catch (e) {
      // TODO Polling here? Or just rethrow?
      print(e);
    }

    if (fd.isNegative) {
      // Failed to open the file, possibly because it already exists or due to permissions
      print("Failed to open the file exclusively. $fd");
      fd = -1; // Reset the file descriptor
    }

    ((fcntl(fd, F_GETFL) & O_RDWR) > 0) || (throw Exception('Failed to open the file with read/write permissions.'));

    // TODO double check we should do this through stdlibc rather than dart io like below
    // This should fail if the file already exists
    // If the file doesnt exist, create it and open it for writing only in append mode
    // !_file.existsSync()
    //     ? (_file
    //       ..createSync(exclusive: true)
    //       ..openSync(mode: FileMode.writeOnlyAppend))
    //     // otherwise we open it for writing only in append mode
    //     : _file.openSync(mode: FileMode.writeOnlyAppend);
    // _open();
  }

  @override
  bool acquire() {
    // TODO Polling here with poll(fds) from stdlibc.dart?
    return true;
  }

  @override
  bool lock() {
    return _flock(LockOperation.LOCK_EX);
  }

  @override
  bool unlock() {
    return _flock(LockOperation.LOCK_UN);
  }

  @override
  bool dispose() {
    close(fd);
    return File(_file.path).existsSync();
  }

  // Defines a function to lock or unlock a file descriptor using file locking mechanisms.
  bool _flock(LockOperation operation) {
    Flock lock; // Declare a variable to hold the lock configuration.
    late bool locking;
    switch (operation) {
      case LockOperation.LOCK_EX || LockOperation.LOCK_NB:
        // If the operation is to lock exclusively, configure the lock for exclusive write access.
        lock = _lock = Flock(
          l_type: F_WRLCK, // Set the lock type to write lock.
          l_whence: SEEK_SET, // The lock offset is relative to the beginning of the file.
          l_start: 0, // Start of the lock offset.
          l_len: 0, // Length of the lock; 0 means to lock the entire file.
        );

        locking = true;
        break;

      case LockOperation.LOCK_UN:
        // If the operation is to unlock, configure the lock to release.
        lock = _unlock = Flock(
          l_type: F_UNLCK, // Set the lock type to unlock.
          l_whence: SEEK_SET, // The unlock offset is relative to the beginning of the file.
          l_start: 0, // Start of the unlock offset.
          l_len: 0, // Length of the unlock; 0 means to unlock the entire file.
        );

        locking = false;
        break;
    }

    while (true) {
      // Attempt the operation until it succeeds or an unrecoverable error occurs.
      try {
        !fd.isNegative ||
            (throw Exception(
                'Unexpended [UNIX] file handle value, shouldn\'t be negative at this point: ${NamedLockError.createFailed} [Identifier]: $identifier [FD]: $fd'));

        int _fd = fcntl(fd, F_SETLK, lock);

        print(_fd);
        print(locking);
        print(_lock.toString());

        if (_fd.isNegative) {
          // Attempt to set the lock using fcntl. If it returns a negative value, an error occurred.
          final error = OSError(); // Retrieve the last OS error.

          if (error.errorCode == EINTR) {
            // If the error code indicates the operation was interrupted, try again.
            continue;
          } else if (error.errorCode == EWOULDBLOCK) {
            // If the error code indicates the operation would block, throw a FileSystemException.
            throw FileSystemException(
                "${locking ? '[LOCK]' : '[UNLOCK]'} Operation would block: [CODE]: ${error.errorCode} [Identifier]: $identifier [FD]: $fd",
                error.message,
                error);
          } else if (error.errorCode == EDEADLK) {
            // The specified region is being locked by another process. But that process is waiting to lock a region which the current process has locked, so waiting for the lock would result in deadlock. The system does not guarantee that it will detect all such conditions, but it lets you know if it notices one.
            throw FileSystemException(
                "${locking ? '[LOCK]' : '[UNLOCK]'} Operation would result in a deadlock: [CODE]: ${error.errorCode} [Identifier]: $identifier [FD]: $fd",
                error.message,
                error);
          } else {
            print(error.message.toString());
            // For other error codes, throw a FileSystemException indicating failure.
            throw FileSystemException(
                "${locking ? '[LOCK]' : '[UNLOCK]'} Operation failed: [CODE]: ${error.errorCode} [Identifier]: $identifier [FD]: $fd",
                error.message,
                error);
          }
        }

        fd = _fd; // Update the file descriptor with the new value.

        break; // If the operation was successful (no negative return value), exit the loop.
      } on UnsupportedError catch (e) {
        // Catch and rethrow UnsupportedError, which may occur if fcntl is not supported or the arguments are invalid.
        rethrow;
      }
    }

    return true;
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

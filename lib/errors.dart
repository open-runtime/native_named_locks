class NamedLockError extends Error {
  // The error message associated with each enum instance
  final String message;

  // Private constructor
  NamedLockError._(this.message);

  // Static final fields representing each error
  static final NamedLockError invalidCharacter = NamedLockError._("Invalid character in name:");
  static final NamedLockError emptyName = NamedLockError._("Name must not be empty:");
  static final NamedLockError createFailed = NamedLockError._("Failed to create named lock:");
  static final NamedLockError lockFailed = NamedLockError._("Failed to lock named lock:");
  static final NamedLockError unlockFailed = NamedLockError._("Failed to unlock named lock:");
  static final NamedLockError wouldBlock = NamedLockError._("Named lock would block:");
  static final NamedLockError disposeFailed = NamedLockError._("Failed to close and dispose named lock:");
  static final NamedLockError alreadyExists = NamedLockError._("Named lock already exists:");
  static final NamedLockError unixPathForNamedLockUnverified =
      NamedLockError._("Unix path for named lock is unverified and could not be found through File.existsSync():");
  static final NamedLockError attemptedToAccessUnknownLock =
      NamedLockError._("Attempted to access unknown named lock:");

  static final NamedLockError guardTargetIsNull = NamedLockError._("Named lock guard target of NamedLock is null:");

  // Method to return a custom string representation of the class instance, if needed
  @override
  String toString() => 'Error: $message';
}

// Enhanced enum declaration in Dart
enum NamedLockErrors {
  invalidCharacter("Invalid character in name:"),
  emptyName("Name must not be empty:"),
  createFailed("Failed to create named lock:"),
  lockFailed("Failed to lock named lock:"),
  unlockFailed("Failed to unlock named lock:"),
  wouldBlock("Named lock would block:");

  // Constructor with a message for each error
  const NamedLockErrors(this.message);

  // The error message associated with each enum instance
  final String message;

  // Method to return a custom string representation of the enum instance, if needed
  @override
  String toString() => 'Error: $message';
}

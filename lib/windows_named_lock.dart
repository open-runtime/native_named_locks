part of 'primitives.dart';

// class _WindowsNamedLockNameType extends NamedLockNameType<String> {
//   _WindowsNamedLockNameType() : super._();
// }

class _WindowsNamedLock extends NamedLock {
  late final Pointer<HANDLE> handle;

  // Memory Allocation in Bytes
  static const int _allocation = 8;

  late final Pointer<HANDLE> mutex_handle;

  static final _finalizer = Finalizer<Pointer<HANDLE>>((Pointer<HANDLE> ptr) {
    // TODO: Is this proper?
    calloc.free(ptr);
  });

  _WindowsNamedLock({required String identifier}) : super._(identifier: identifier) {
    handle = calloc.allocate(_WindowsNamedLock._allocation);
    // Create the native string
    final native_string = HString.fromString(identifier);

    // Create the named mutex with no security attributes, no initial owner, and a pointer to the name i.e. HSTRING
    mutex_handle = CreateMutexW(nullptr, 0, native_string.handle);

    print('calloc.handle handle address: ${handle.address}');
    print('native_string handle: ${native_string.handle}');
    print('mutex_handle: ${mutex_handle}');

    // Attach this dart instance to the finalizer and associate it with the allocated handle
    _finalizer.attach(this, handle);

    // DO I NEED TO FREE THE HSTRING HERE?
    native_string.free();

    if (mutex_handle == nullptr) {
      int native_last_error = GetLastError();
      String? error_message = getRestrictedErrorDescription(native_last_error);
      throw Exception('${NamedLockError.createFailed} [Code]: ${native_last_error} [Message]: ${error_message}');
    }
  }

  @override
  bool acquire() {
    final awaited = WaitForSingleObject(mutex_handle, 0);
    return (awaited == WAIT_OBJECT_0 || awaited == WAIT_ABANDONED) ||
        (awaited == WAIT_TIMEOUT &&
                (throw Exception('${NamedLockError.wouldBlock} [Name]: $identifier [Result]: ${awaited}')) ||
            (throw Exception('${NamedLockError.lockFailed} [Name]: $identifier [Result]: ${awaited}')));

    // if (result == WAIT_OBJECT_0 || result == WAIT_ABANDONED) {
    //   return true;
    // } else if (result == WAIT_TIMEOUT) {
    //   throw Exception('${NamedLockError.wouldBlock} [Name]: $identifier [Result]: ${result}');
    // } else {
    //   throw Exception('${NamedLockError.lockFailed} [Name]: $identifier [Result]: ${result}');
    // }
  }

  @override
  bool lock() {
    final result = WaitForSingleObject(mutex_handle, INFINITE);

    return (result != WAIT_OBJECT_0 && result != WAIT_ABANDONED) ||
        (throw Exception('${NamedLockError.lockFailed} [Name]: $identifier [Result]: ${result}'));
  }

  @override
  bool unlock() {
    // return 0 or 1 for failure or success
    final int result = ReleaseMutex(mutex_handle);
    // 0 is even and false/failed, 1 is odd and true/succeeded
    return result.isOdd || (throw Exception('${NamedLockError.unlockFailed} [Name]: $identifier [Result]: ${result}'));
  }

  @override
  bool dispose() {
    // return 0 or 1 for failure or success
    final int result = CloseHandle(mutex_handle);
    print('CloseHandle result: $result');
    // 0 is even and false/failed, 1 is odd and true/succeeded
    return result.isOdd || (throw Exception('${NamedLockError.disposeFailed} [Name]: $identifier [Result]: ${result}'));
  }

  @override
  String toString() => 'NamedLock(name: $identifier)';

  @override
  int get address => handle.address;
}

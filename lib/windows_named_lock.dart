part of 'primitives.dart';

class _WindowsNamedLock extends NamedLock<HANDLE, HANDLE> {
  // Memory Allocation in Bytes
  static const int _allocation = 8;

  @override
  late final Pointer<HANDLE> handle;

  @override
  late final Pointer<HANDLE> mutex_handle;

  static final _finalizer = Finalizer<Pointer<HANDLE>>((Pointer<HANDLE> ptr) {
    // TODO: Is this proper?
    calloc.free(ptr);
  });

  _WindowsNamedLock({required String name})
      : handle = calloc.allocate(_WindowsNamedLock._allocation),
        super._(name: name) {
    // Create the native string
    final native_string = HString.fromString(name);

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
      throw Exception('${NamedLockErrors.createFailed} [Code]: ${native_last_error} [Message]: ${error_message}');
    }
  }

  @override
  bool acquire() {
    final result = WaitForSingleObject(mutex_handle, 0);
    if (result == WAIT_OBJECT_0 || result == WAIT_ABANDONED) {
      return true;
    } else if (result == WAIT_TIMEOUT) {
      return false;
    } else {
      throw Exception('Failed to lock named lock');
    }
  }

  @override
  void lock() {
    final result = WaitForSingleObject(mutex_handle, INFINITE);
    if (result != WAIT_OBJECT_0 && result != WAIT_ABANDONED) {
      throw Exception('${NamedLockErrors.lockFailed} [Name]: $name [Result]: ${result}');
    }
  }

  @override
  void unlock() {
    final int result = ReleaseMutex(mutex_handle);
    result.isOdd || (throw Exception('${NamedLockErrors.unlockFailed} [Name]: $name [Result]: ${result}'));
  }

  @override
  void dispose() {
    final int result = CloseHandle(mutex_handle);
    print(result);
    result.isOdd || (throw Exception('${NamedLockErrors.disposeFailed} [Name]: $name [Result]: ${result}'));
  }

  @override
  String toString() => 'NamedLock(name: $name)';

  @override
  int get address => handle.address;
}

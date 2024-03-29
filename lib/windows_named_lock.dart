part of 'primitives.dart';

// class _WindowsNamedLockNameType extends NamedLockNameType<String> {
//   _WindowsNamedLockNameType() : super._();
// }

class _WindowsNamedLock extends NamedLock {
  bool locked = false;
  bool acquired = false;

  // Memory Allocation in Bytes
  static const int _allocation = 8;

  // late final Pointer<HANDLE> handle = calloc.allocate(_WindowsNamedLock._allocation);

  late final HANDLE mutex_handle;

  static final _finalizer = Finalizer<Pointer<HANDLE>>((Pointer<HANDLE> ptr) {
    // TODO: Is this proper?
    calloc.free(ptr);
  });

  // TODO Explicit Initialize/Create functions or?
  _WindowsNamedLock({required String identifier}) : super._(identifier: identifier) {
    throw UnimplementedError();
    // print('calloc.handle address: ${handle.address}');

    // Create the native string
    // final native_string = HString.fromString(identifier);
    // final IPropertyValue native_boolean = false.toPropertyValue();

    // Create the named mutex with no security attributes, no initial owner, and a pointer to the name i.e. HSTRING
    // mutex_handle = CreateMutexW(nullptr, native_boolean.getBoolean(), native_string.handle);

    // print('calloc.handle handle address: ${handle.address}');
    // print('native_string handle: ${native_string.handle}');
    // print('mutex_handle: ${mutex_handle.address}');

    // Attach this dart instance to the finalizer and associate it with the allocated handle
    // _finalizer.attach(this, handle);

    // DO I NEED TO FREE THE HSTRING HERE?
    // native_string.free();

    // if (mutex_handle == nullptr) {
    //   int native_last_error = GetLastError();
    //   String? error_message = getRestrictedErrorDescription(native_last_error);
    //   throw Exception('${NamedLockError.createFailed} [Code]: ${native_last_error} [Message]: ${error_message}');
    // }
  }

  // TODO add interval parameter?
  // TODO make this attempt?
  @override
  bool acquire({int MAX_ATTEMPTS = 100, Duration INTERVAL = const Duration(milliseconds: 50)}) {
    throw UnimplementedError();
    // if (result == WAIT_OBJECT_0 || result == WAIT_ABANDONED) {
    //   return true;
    // } else if (result == WAIT_TIMEOUT) {
    //   throw Exception('${NamedLockError.wouldBlock} [Name]: $identifier [Result]: ${result}');
    // } else {
    //   throw Exception('${NamedLockError.lockFailed} [Name]: $identifier [Result]: ${result}');
    // }
    // return false;
  }

  // TODO make this attempt?
  bool _acquire({int MAX_ATTEMPTS = 100, Duration INTERVAL = const Duration(milliseconds: 50)}) {
    return true;
  }

  _lock() {
    // final awaited = WaitForSingleObject(mutex_handle, 0);
    // return (awaited == WAIT_OBJECT_0 || awaited == WAIT_ABANDONED) ||
    //     (awaited == WAIT_TIMEOUT &&
    //         (throw Exception('${NamedLockError.wouldBlock} [Name]: $identifier [Result]: ${awaited}')) ||
    //         (throw Exception('${NamedLockError.lockFailed} [Name]: $identifier [Result]: ${awaited}')));
  }

  @override
  bool lock() {
    throw UnimplementedError();
    // final result = WaitForSingleObject(mutex_handle, INFINITE);

    // return (result != WAIT_OBJECT_0 && result != WAIT_ABANDONED) ||
    //     (throw Exception('${NamedLockError.lockFailed} [Name]: $identifier [Result]: ${result}'));
  }

  @override
  bool unlock() {
    throw UnimplementedError();
    // return 0 or 1 for failure or success
    // final int result = ReleaseMutex(mutex_handle);
    // 0 is even and false/failed, 1 is odd and true/succeeded
    // return result.isOdd || (throw Exception('${NamedLockError.unlockFailed} [Name]: $identifier [Result]: ${result}'));
  }

  @override
  bool dispose() {
    throw UnimplementedError();
    // // return 0 or 1 for failure or success
    // final int result = CloseHandle(mutex_handle);
    // print('CloseHandle result: $result');
    // // 0 is even and false/failed, 1 is odd and true/succeeded
    // return result.isOdd || (throw Exception('${NamedLockError.disposeFailed} [Name]: $identifier [Result]: ${result}'));
  }

  @override
  String toString() => 'NamedLock(name: $identifier)';

  // @override
  // int get address => handle.address;
}

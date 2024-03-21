part of 'primitives.dart';

class _UnixNamedLock extends NamedLock {
  static const _sizeInBytes = 8; // `sizeof(SRWLOCK)`

  _UnixNamedLock({required String name}) : super._(name: name) {
    throw UnimplementedError();
    // handle = malloc.allocate(_UnixNamedLock._sizeInBytes),
    // _finalizer.attach(this, handle);
  }
}

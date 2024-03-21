part of 'primitives.dart';

class _UnixNamedLock extends NamedLock<NativeType, NativeType> {
  static const _allocation = 8;

  _UnixNamedLock({required String name}) : super._(name: name) {
    throw UnimplementedError();
  }
}

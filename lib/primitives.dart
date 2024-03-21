library;

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart' show calloc;
import 'package:runtime_native_named_locks/errors.dart';
import 'src/bindings/windows.dart';

import 'package:windows_foundation/internal.dart' show HString, getRestrictedErrorDescription;
// import 'package:windows_foundation/windows_foundation.dart';

part 'unix_named_lock.dart';
part 'windows_named_lock.dart';

sealed class NamedLock<H extends NativeType> implements Finalizable {
  final String name;

  late final Pointer<H> handle;

  NamedLock._({required String name}) : this.name = name;

  factory NamedLock({required String name}) => Platform.isWindows ? _WindowsNamedLock(name: name) as NamedLock<H> : _UnixNamedLock(name: name) as NamedLock<H>;

  /// Tries to acquire the lock without blocking.
  ///
  /// Returns `true` if the lock is acquired successfully, `false` if the lock is already held by another thread.
  ///
  /// Throws an `Exception` if an error occurs while trying to acquire the lock.
  bool acquire() => throw UnimplementedError("Class Member 'bool acquire()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  void lock() => throw UnimplementedError("Class Member 'void lock()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  void drop() => throw UnimplementedError("Class Member 'void drop()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  void dispose() => throw UnimplementedError("Class Member 'void _dispose()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  int get _address => throw UnimplementedError();

  String toString() => throw UnimplementedError();
}

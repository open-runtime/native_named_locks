library;

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart' show calloc;
import 'package:runtime_native_named_locks/errors.dart';
import 'src/bindings/windows.dart'
    show
        CloseHandle,
        CreateMutexW,
        GetLastError,
        HANDLE,
        INFINITE,
        ReleaseMutex,
        WAIT_ABANDONED,
        WAIT_OBJECT_0,
        WAIT_TIMEOUT,
        WaitForSingleObject;

import 'package:windows_foundation/internal.dart' show HString, getRestrictedErrorDescription;

part 'unix_named_lock.dart';
part 'windows_named_lock.dart';

sealed class NamedLock<H extends NativeType, M extends NativeType> implements Finalizable {
  final String name;

  late final Pointer<H> handle;

  late final M mutex_handle;

  NamedLock._({required String name}) : this.name = name;

  factory NamedLock({required String name}) => Platform.isWindows
      ? _WindowsNamedLock(name: name) as NamedLock<H, M>
      : _UnixNamedLock(name: name) as NamedLock<H, M>;

  bool acquire() =>
      throw UnimplementedError("Class Member 'bool acquire()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  void lock() =>
      throw UnimplementedError("Class Member 'void lock()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  void unlock() =>
      throw UnimplementedError("Class Member 'void lock()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  void dispose() =>
      throw UnimplementedError("Class Member 'void _dispose()' in Sealed Abstract Class 'NamedLock' is Unimplemented.");

  int get address => throw UnimplementedError();

  String toString() => throw UnimplementedError();
}

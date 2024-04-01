// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi' show Int32, IntPtr, Native, Pointer, Uint32, Void, nullptr;
import 'package:ffi/ffi.dart';
import 'package:win32/src/types.dart' show DWORD, DWORDLONG, HANDLE, LONG32, LPWSTR;
import 'package:win32/win32.dart' show BOOL, SECURITY_ATTRIBUTES;

final DWORD WAIT_ABANDONED = 0x00000080 as DWORD;
// or DWORD
final DWORD WAIT_OBJECT_0 = 0x00000000 as DWORD;

final DWORD WAIT_TIMEOUT = 0x00000102 as DWORD;

/// Dart FFI for Windows [CreateMutexW]
///
/// https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexw
///
///
///  ```cpp
///
///   HANDLE CreateMutexW(
///     [in, optional] LPSECURITY_ATTRIBUTES lpMutexAttributes,
///     [in]           BOOL                  bInitialOwner,
///     [in, optional] LPCWSTR               lpName
///   );
///
/// ```
/// Creates or opens a named or unnamed mutex object.
///
/// Returns a [HANDLE] to the newly created mutex object.
/// [lpMutexAttributes] (optional): A pointer to a [SECURITY_ATTRIBUTES] structure.
/// If [nullptr], the handle cannot be inherited by child processes.
///
/// [SECURITY_ATTRIBUTES] Windows Documentation can be found here: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa379560(v=vs.85)
///
/// [bInitialOwner] A boolean value indicating whether the calling thread obtains
/// initial ownership of the mutex object. If [true] and the caller created the mutex,
/// the calling thread obtains initial ownership.
///
/// [lpName] (optional): A pointer to a null-terminated string that specifies the name
/// of the mutex object. If [nullptr], the mutex object is created without a name.
///
/// If [lpName] matches the name of an existing named mutex object, the function requests
/// the [MUTEX_ALL_ACCESS] access right, and [bInitialOwner] is ignored.
///
/// If [lpName] matches the name of an existing event, semaphore, waitable timer, job,
/// or file-mapping object, the function fails and [GetLastError] returns [ERROR_INVALID_HANDLE].
///
/// The returned handle has the [MUTEX_ALL_ACCESS] access right and can be used in any
/// function that requires a handle to a mutex object, provided that the caller has been
/// granted access.
///
/// If the mutex is a named mutex and the object existed before the function call, the
/// return value is a handle to the existing object, and [GetLastError] returns
/// [ERROR_ALREADY_EXISTS].
///
/// Multiple processes can call [CreateMutex] to create the same named mutex. The first
/// process actually creates the mutex, and subsequent processes with sufficient access
/// rights simply open a handle to the existing mutex.
///
/// [lpMutexAttributes] A pointer to a [SECURITY_ATTRIBUTES] structure.

// LPWSTR should okay as both LPWSTR & LPCWSTR are Pointer<Utf16> from the dart side
// Pointer<SECURITY_ATTRIBUTES>
// Pointer<Utf16>
@Native<HANDLE Function(IntPtr lpSecurityAttributes, BOOL bInitialOwner, Pointer<Utf16> lpName)>()
external int CreateMutexW(int lpSecurityAttributes, int bInitialOwner, Pointer<Utf16> lpName);

/// Dart FFI for Windows [ReleaseMutex]
///
/// https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-releasemutex
///
/// ```cpp
///
///   BOOL ReleaseMutex(
///     [in] HANDLE hMutex
///   );
///
/// ```
///
/// Releases ownership of the specified mutex object.
///
/// [hMutex] A handle to the mutex object. The [CreateMutex] or [OpenMutex] function returns this handle.
///
/// Returns a non-zero value if the function succeeds, or zero if the function fails.
/// To get extended error information, call [GetLastError].
///
/// Remarks:
///
/// The [ReleaseMutex] function fails if the calling thread does not own the mutex object.
///
/// A thread obtains ownership of a mutex either by creating it with the [bInitialOwner] parameter
/// set to [TRUE] or by specifying its handle in a call to one of the wait functions.
///
/// When the thread no longer needs to own the mutex object, it calls the [ReleaseMutex] function
/// so that another thread can acquire ownership.
///
/// A thread can specify a mutex that it already owns in a call to one of the wait functions
/// without blocking its execution. This prevents a thread from deadlocking itself while waiting
/// for a mutex that it already owns. However, to release its ownership, the thread must call
/// [ReleaseMutex] one time for each time that it obtained ownership (either through [CreateMutex]
/// or a wait function).
@Native<BOOL Function(HANDLE hMutex)>()
external int ReleaseMutex(int hMutex);

/// Waits until the specified object is in the signaled state or the
/// time-out interval elapses.
///
/// ```c
/// DWORD WaitForSingleObject(
///   HANDLE hHandle,
///   DWORD  dwMilliseconds
/// );
/// ```
/// {@category kernel32}
// int WaitForSingleObject(int hHandle, int dwMilliseconds) => _WaitForSingleObject(hHandle, dwMilliseconds);
//
// final _WaitForSingleObject = _kernel32.lookupFunction<Uint32 Function(IntPtr hHandle, Uint32 dwMilliseconds),
//     int Function(int hHandle, int dwMilliseconds)>('WaitForSingleObject');

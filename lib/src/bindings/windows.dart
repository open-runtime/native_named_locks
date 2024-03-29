// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi' show Native, Pointer, Void, nullptr;
import 'package:ffi/ffi.dart' show Utf16;
import 'package:win32/src/types.dart' show HANDLE, LPWSTR;
import 'package:win32/win32.dart' show BOOL;
// import 'package:windows_foundation/internal.dart' show IPropertyValue;
// /Users/tsavo/.pub-cache/hosted/pub.dev/win32-5.3.0/lib/src/types.dart

// final class HANDLE extends Opaque {}

const WAIT_ABANDONED = 0x00000080;
const WAIT_OBJECT_0 = 0x00000000;
const WAIT_TIMEOUT = 0x00000102;

// const INFINITE = 0xFFFFFFFF;

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
@Native<HANDLE Function(Pointer<Void>, BOOL, LPWSTR)>()
external int CreateMutexW(Pointer<Void> lpMutexAttributes, int bInitialOwner, LPWSTR lpName);

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

/// Dart FFI for Windows [WaitForSingleObject]
///
/// https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject
///
/// ```cpp
///
///   DWORD WaitForSingleObject(
///     [in] HANDLE hHandle,
///     [in] DWORD  dwMilliseconds
///   );
///
/// ```
///
/// Waits until the specified object is in the signaled state or the time-out interval elapses.
///
/// To enter an alertable wait state, use the [WaitForSingleObjectEx] function.
/// To wait for multiple objects, use [WaitForMultipleObjects].
///
/// [hHandle] A handle to the object. For a list of the object types whose handles can be
/// specified, see the Remarks section. If this handle is closed while the wait is still
/// pending, the function's behavior is undefined. The handle must have the [SYNCHRONIZE]
/// access right. For more information, see Standard Access Rights.
///
/// [dwMilliseconds] The time-out interval, in milliseconds. If a nonzero value is specified,
/// the function waits until the object is signaled or the interval elapses. If [dwMilliseconds]
/// is zero, the function does not enter a wait state if the object is not signaled; it always
/// returns immediately. If [dwMilliseconds] is [INFINITE], the function will return only when
/// the object is signaled.
///
/// Returns a [DWORD] value indicating the result of the wait operation.

// Not needed as it exists in the win32 package
// @Native<Uint32 Function(Pointer<HANDLE>, Uint32)>()
// external int WaitForSingleObject(Pointer<HANDLE> hHandle, int dwMilliseconds);

/// Dart FFI for Windows [CloseHandle]
///
/// https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
///
/// ```cpp
///
/// BOOL CloseHandle(
///   [in] HANDLE hObject
/// );
///
/// ```
///
/// Closes an open object handle.
///
/// [hObject] A valid handle to an open object.
///
/// Returns a non-zero value if the function succeeds, or zero if the function fails.
/// To get extended error information, call [GetLastError].
///
/// Remarks:
///
/// The [CloseHandle] function closes handles to various objects, such as files, events,
/// processes, threads, and more. Refer to the official documentation for a complete list
/// of supported objects.
///
/// After calling the functions that create these objects, [CloseHandle] should be used
/// when the object is no longer needed. The documentation for each creator function
/// indicates how to properly close the handle and what happens to pending operations.
///
/// In general, an application should call [CloseHandle] once for each handle it opens.
/// It is usually not necessary to call [CloseHandle] if a function using the handle fails
/// with [ERROR_INVALID_HANDLE], as this typically indicates that the handle is already
/// invalidated. However, some functions may use [ERROR_INVALID_HANDLE] to indicate that
/// the object itself is no longer valid, in which case the application should close the
/// handle.
///
/// If a handle is associated with a transaction, all transacted handles should be closed
/// before committing the transaction.
///
/// Closing a thread handle does not terminate the associated thread or remove the thread
/// object. Similarly, closing a process handle does not terminate the associated process
/// or remove the process object. Proper cleanup requires terminating the thread/process
/// and closing all related handles.
///
/// Do not use [CloseHandle] to close a socket. Instead, use the [closesocket] function.
///
/// Do not use [CloseHandle] to close a handle to an open registry key. Instead, use the
/// [RegCloseKey] function.
// @Native<Int32 Function(Pointer<HANDLE>)>()
// external int CloseHandle(Pointer<HANDLE> hObject);

/// Dart FFI for Windows [GetLastError]
///
/// https://learn.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror
///
///   ```cpp
///
///     _Post_equals_last_error_ DWORD GetLastError();
///
///   ```
///
/// Retrieves the calling thread's last-error code value.
///
/// The last-error code is maintained on a per-thread basis. Multiple threads do not
/// overwrite each other's last-error code.
///
/// Returns the calling thread's last-error code.
///
/// The Return Value section of the documentation for each function that sets the last-error
/// code notes the conditions under which the function sets the last-error code. Most functions
/// that set the thread's last-error code set it when they fail. However, some functions also
/// set the last-error code when they succeed. If the function is not documented to set the
/// last-error code, the value returned by this function is simply the most recent last-error
/// code to have been set; some functions set the last-error code to 0 on success and others
/// do not.
///
/// See System Error Codes Here: https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes
// @Native<Int32 Function()>()
// external int GetLastError();

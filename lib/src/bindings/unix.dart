// import 'dart:ffi';
//
// import 'package:ffi/ffi.dart';
// import 'package:stdlibc/stdlibc.dart'
//     show EACCES, EEXIST, EINTR, EINVAL, EMFILE, ENAMETOOLONG, ENFILE, ENOENT, ENOSPC, ENOSYS, strerror;
//
// import 'package:stdlibc/stdlibc.dart' as stdlibc show errno;
//
// // Assuming the existence of these classes for semaphores
// final class sem_t extends Opaque {}
//
// final class shm_fd extends Opaque {}
//
// // final class mode_t extends Opaque {}
//
// // Define bindings for semaphore functions using @Native
// @Native<Int Function(Pointer<sem_t>, Int8, Int8)>()
// external int sem_init(Pointer<sem_t> semaphore, int pshared, int value);
//
// // @Native<Int Function(Pointer<sem_t>)>()
// // external int sem_wait(Pointer<sem_t> semaphore);
//
// @Native<Int Function(Pointer<sem_t>)>()
// external int sem_post(Pointer<sem_t> semaphore);
//
// // @Native<Int Function(Pointer<sem_t>)>()
// // external int sem_destroy(Pointer<sem_t> semaphore);
// // Int8? mode, Uint8? value
// // int? mode, int? value
//
// // @Native<>()
// // external int mode_t;
//
// @Native<Pointer<sem_t> Function(Pointer<Utf16>, Int8 oflag, Uint16 mode_t, Uint8 value)>()
// external Pointer<sem_t> sem_open(Pointer<Utf16> name, int oflag, int? mode_t, int? value);
//
// // @Native<Pointer<shm_fd> Function(Pointer<Utf16>, Int8 oflag, Uint8 mode, Uint8 value)>()
// // external Pointer<shm_fd> shm_open(Pointer<Utf16> name, int oflag, int? mode, int? value);
//
// @Native<Int Function(Pointer<sem_t>)>()
// external int sem_close(Pointer<sem_t> semaphore);
// //
// @Native<Int Function(Pointer<Utf16>)>()
// external int sem_unlink(Pointer<Utf16> name);
//
// // @Native<Int Function(Pointer<sem_t>, Pointer<Int>)>()
// // external int sem_getvalue(Pointer<sem_t> semaphore, Pointer<Int> value);
//
// @Native<Int Function(Pointer<sem_t>)>()
// external int sem_trywait(Pointer<sem_t> semaphore);
//
// String get_sem_open_error() {
//   int code = stdlibc.errno;
//
//   print("get_sem_open_error string: ${strerror(code)}");
//
//   if (code == EACCES) {
//     return ("Permission denied. ErrorCode: EACCES [$EACCES] VerifiedErrorNumber: [$code]");
//   }
//   if (code == EEXIST) {
//     return ("Named semaphore already exists. ErrorCode: EEXIST [$EEXIST] VerifiedErrorNumber: [$code]");
//   }
//   if (code == EINTR) {
//     return ("Operation interrupted by a signal. ErrorCode: EINTR [$EINTR] VerifiedErrorNumber: [$code]");
//   }
//   if (code == EINVAL) {
//     return ("Invalid name, or value exceeds SEM_VALUE_MAX. ErrorCode: EINVAL [$EINVAL] VerifiedErrorNumber: [$code]");
//   }
//   if (code == EMFILE) {
//     return ("Too many file descriptors in use by this process. ErrorCode: EMFILE [$EMFILE] VerifiedErrorNumber: [$code]");
//   }
//   if (code == ENAMETOOLONG) {
//     return ("Name string exceeds PATH_MAX, or a pathname component is too long. ErrorCode: ENAMETOOLONG [$ENAMETOOLONG] VerifiedErrorNumber: [$code]");
//   }
//   if (code == ENFILE) {
//     return ("Too many semaphores open in the system. ErrorCode: ENFILE [$ENFILE] VerifiedErrorNumber: [$code]");
//   }
//   if (code == ENOENT) {
//     return ("Named semaphore does not exist. ErrorCode: ENOENT [$ENOENT] VerifiedErrorNumber: [$code]");
//   }
//   if (code == ENOSPC) {
//     return ("Insufficient space for the new named semaphore. ErrorCode: ENOSPC [$ENOSPC] VerifiedErrorNumber: [$code]");
//   }
//
//   if (code == ENOSYS) {
//     return ("Function not supported by this implementation. ErrorCode: ENOSYS [$ENOSYS] VerifiedErrorNumber: [$code]");
//   }
//
//   return ("Unknown error. $code");
// }
//
// String get_sem_post_error() {
//   int code = stdlibc.errno;
//   print("get_sem_post_error string: ${strerror(code)}");
//
//   if (code == EACCES) {
//     return ("Permission denied. ErrorCode: EACCES [$EACCES] VerifiedErrorNumber: [$code]");
//   }
//
//   if (code == EINVAL) {
//     return ("The sem passed to sem_post does not refer to a valid semaphore. ErrorCode: EINVAL [$EINVAL] VerifiedErrorNumber: [$code]");
//   }
//
//   if (code == ENOSYS) {
//     return ("sem_post Function not supported by this platform/implementation. ErrorCode: ENOSYS [$ENOSYS] VerifiedErrorNumber: [$code]");
//   }
//
//   return ("Unknown error. $code");
// }
//
// String get_sem_unlink_error() {
//   int code = stdlibc.errno;
//   print("get_sem_unlink_error string: ${strerror(code)}");
//
//   if (code == EACCES) {
//     return ("Permission is denied to unlink the named semaphore. ErrorCode: EACCES [$EACCES] VerifiedErrorNumber: [$code]");
//   }
//
//   if (code == ENAMETOOLONG) {
//     return ("The length of the name string exceeds {NAME_MAX} while {POSIX_NO_TRUNC} is in effect. ErrorCode: ENOENT [$ENOENT] VerifiedErrorNumber: [$code]");
//   }
//
//   if (code == ENOENT) {
//     return ("The named semaphore does not exist. ErrorCode: ENOENT [$ENOENT] VerifiedErrorNumber: [$code]");
//   }
//
//   if (code == ENOSYS) {
//     return ("sem_unlink Function not supported by this platform/implementation. ErrorCode: ENOSYS [$ENOSYS] VerifiedErrorNumber: [$code]");
//   }
//
//   return ("Unknown error. $code");
// }

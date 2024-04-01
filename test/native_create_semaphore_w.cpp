#include <windows.h>
#include <iostream>

int main() {
    LPCWSTR name = L"Global\\cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_cross_isolate_windows_lock_"; // Name of the semaphore object
    HANDLE semaphoreHandle;

    // Try to create a semaphore object
    semaphoreHandle = CreateSemaphoreW(NULL, 1, 1, name); // Initial count=1, Maximum count=1

    // Check if the semaphore was created successfully
    if (semaphoreHandle == NULL) {
        std::wcout << L"From CPP CreateSemaphoreW failed with error: " << GetLastError() << std::endl;
    } else {
        if (GetLastError() == ERROR_ALREADY_EXISTS) {
            // If the semaphore already exists
            std::wcout << L"From CPP Semaphore already exists." << std::endl;
        } else {
            // If the semaphore was created successfully
            std::wcout << L"From CPP Semaphore created successfully." << std::endl;
        }

        // Try to lock the semaphore
        DWORD dwWaitResult = WaitForSingleObject(semaphoreHandle, 5000); // Wait for 5 seconds
        std::wcout << L"From CPP WaitForSingleObject returned: " << dwWaitResult << std::endl;

        switch (dwWaitResult) {
            // The thread got semaphore ownership
            case WAIT_OBJECT_0:
                std::wcout << L"From CPP Semaphore locked successfully." << std::endl;
                // Perform your thread's tasks here.

                // Wait for 30 seconds
                Sleep(30000); // Sleep takes milliseconds as argument

                // Release the semaphore when done
                if (!ReleaseSemaphore(semaphoreHandle, 1, NULL)) {
                    // Handle error.
                    std::wcout << L"From CPP Error releasing semaphore." << std::endl;
                }
                break;

            // The thread got ownership of an abandoned semaphore
            // The semaphore is in an indeterminate state
            case WAIT_ABANDONED:
                std::wcout << L"From CPP Semaphore was abandoned." << std::endl;
                break;
        }
    }

    // Wait for 30 seconds
    Sleep(30000); // Sleep takes milliseconds as argument

    // Close the semaphore handle
    if (semaphoreHandle) {
        BOOL closeResult = CloseHandle(semaphoreHandle);
        if (closeResult) {
            std::wcout << L"From CPP Semaphore handle closed successfully." << std::endl;
        } else {
            std::wcout << L"From CPP CloseHandle failed with error: " << GetLastError() << std::endl;
        }
    }

    return 0;
}

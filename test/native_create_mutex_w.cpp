#include <windows.h>
#include <iostream>

int main() {
    LPCWSTR mutexName = L"Global\\cross_isolate_windows_lock"; // Name of the mutex object
    HANDLE mutexHandle;

    // Try to create a mutex object
    mutexHandle = CreateMutexW(NULL, TRUE, mutexName);

    // Check if the mutex was created successfully
    if (mutexHandle == NULL) {
        std::wcout << L"From CPP CreateMutexW failed with error: " << GetLastError() << std::endl;
    } else {
        if (GetLastError() == ERROR_ALREADY_EXISTS) {
            // If the mutex already exists
            std::wcout << L"From CPP Mutex already exists." << std::endl;
        } else {
            // If the mutex was created successfully
            std::wcout << L"From CPP Mutex created successfully." << std::endl;
        }

        // Try to lock the mutex
        DWORD dwWaitResult = WaitForSingleObject(mutexHandle, INFINITE); // Wait indefinitely

        switch (dwWaitResult) {
            // The thread got mutex ownership
            case WAIT_OBJECT_0:
                std::wcout << L"From CPP Mutex locked successfully." << std::endl;
                // Perform your thread's tasks here.

                // Wait for 1 minute
                Sleep(60000); // Sleep takes milliseconds as argument

                // Release the mutex when done
                if (!ReleaseMutex(mutexHandle)) {
                    // Handle error.
                    std::wcout << L"From CPP Error releasing mutex." << std::endl;
                }
                break;

            // The thread got ownership of an abandoned mutex
            // The mutex is in an indeterminate state
            case WAIT_ABANDONED:
                std::wcout << L"From CPP Mutex was abandoned." << std::endl;
                break;
        }
    }


    // Wait for 1 minute
    Sleep(60000); // Sleep takes milliseconds as argument

    // Close the mutex handle
    if (mutexHandle) {
        BOOL closeResult = CloseHandle(mutexHandle);
        if (closeResult) {
            std::wcout << L"From CPP Mutex handle closed successfully." << std::endl;
        } else {
            std::wcout << L"From CPP CloseHandle failed with error: " << GetLastError() << std::endl;
        }
    }

    return 0;
}
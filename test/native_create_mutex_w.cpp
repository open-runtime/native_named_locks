#include <windows.h>
#include <iostream>


void printCharacterCodesInHex(const std::wstring& input) {
    std::wstringstream hexCodes;
    for (wchar_t ch : input) {
        if (ch == L'\0') {
            hexCodes << L"NULL ";
        } else {
            hexCodes << L"0x" << std::hex << std::setw(4) << std::setfill(L'0') << static_cast<int>(ch) << L" ";
        }
    }
    std::wcout << L"C++ string character codes in hex: " << hexCodes.str() << std::endl;
}

int main() {
    LPCWSTR name = L"Global\\cross_isolate_windows_lock\0"; // Name of the semaphore object

    // Print the address of 'name'
    std::wcout << L"The address of 'name' is: "
               << std::hex << std::setw(16) << std::setfill(L'0')
               << reinterpret_cast<const void*>(name) << std::endl;

    // Print the entire string referred by 'name'
    std::wcout << L"Complete string: " << name << std::endl;

    std::wostringstream woss;

    // Append each character's Unicode code in 'name' to the stringstream as a list of hex values
    for (int i = 0; name[i] != L'\0'; ++i) {
        woss << std::hex << std::showbase << static_cast<int>(name[i]) << L' ';
    }

    // Print the character codes in 'name'
    std::wcout << L"Character codes in LPCWSTR string: " << woss.str() << std::endl;

    // Create a wstring that includes the null terminator
    std::wstring nameWithNullTerminator(name);
    nameWithNullTerminator.push_back(L'\0');  // Explicitly add the null terminator

    printCharacterCodesInHex(nameWithNullTerminator);

    printCharacterCodesInHex(name);

   // Check if the name length exceeds MAX_PATH
    if (wcslen(name) >= MAX_PATH) {
        std::wcout << L"Error: Semaphore name exceeds the maximum allowed length of " << MAX_PATH << L" characters." << std::endl;
        return 1; // Exit with an error code
    }

    HANDLE mutexHandle;

//    std::wcout << L"From CPP Starting the program. & CreateMutexW" << std::endl;
    // Try to create a mutex object
    mutexHandle = CreateMutexW(NULL, TRUE, name);

//    std::wcout << L"CreateMutexW:" << mutexHandle << std::endl;

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

//        std::wcout << L"Running WaitForSingleObject:" << std::endl;

        // Try to lock the mutex
        DWORD dwWaitResult = WaitForSingleObject(mutexHandle, 5000); // Wait for 5 seconds
        std::wcout << L"From CPP WaitForSingleObject returned: " << dwWaitResult << std::endl;

        switch (dwWaitResult) {
            // The thread got mutex ownership
            case WAIT_OBJECT_0:
                std::wcout << L"From CPP Mutex locked successfully." << std::endl;
                // Perform your thread's tasks here.

                // Wait for 5 seconds
                Sleep(5000); // Sleep takes milliseconds as argument

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


    // Wait for 30 seconds
    Sleep(30000); // Sleep takes milliseconds as argument

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
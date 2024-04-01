#include <windows.h>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <string>

void printCharacterCodesInHex(const std::wstring& input) {
    std::wstringstream hexCodes;
    for (wchar_t ch : input) {
        hexCodes << L"0x" << std::hex << std::setw(4) << std::setfill(L'0') << static_cast<int>(ch) << L" ";
    }
    std::wcout << L"C++ string character codes in hex: " << hexCodes.str() << std::endl;
}

int main() {
    LPCWSTR name = L"Global\\cross_isolate_windows_lock"; // Name of the semaphore object

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


    printCharacterCodesInHex(name);

   // Check if the name length exceeds MAX_PATH
    if (wcslen(name) >= MAX_PATH) {
        std::wcout << L"Error: Semaphore name exceeds the maximum allowed length of " << MAX_PATH << L" characters." << std::endl;
        return 1; // Exit with an error code
    }

    HANDLE semaphoreHandle;

    // Try to create a semaphore object
    semaphoreHandle = CreateSemaphoreW(NULL, 1, 1, name); // Initial count=1, Maximum count=1

    // Check if the semaphore was created successfully
    if (semaphoreHandle == NULL) {
        std::wcout << L"From CPP CreateSemaphoreW failed with error: " << GetLastError() << std::endl;
    } else {
        if (GetLastError() == ERROR_ALREADY_EXISTS) {
            // If the semaphore already exists
            std::wcout << L"From CPP Semaphore already exists:" << ERROR_ALREADY_EXISTS << std::endl;
            std::wcout << L"GetLastError:" << GetLastError() << std::endl;
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

//                // Wait for 30 seconds
//                Sleep(30000); // Sleep takes milliseconds as argument
//
//                // Release the semaphore when done
//                if (!ReleaseSemaphore(semaphoreHandle, 1, NULL)) {
//                    // Handle error.
//                    std::wcout << L"From CPP Error releasing semaphore." << std::endl;
//                }
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
//        if (closeResult) {
//            std::wcout << L"From CPP Semaphore handle closed successfully." << std::endl;
//        } else {
//            std::wcout << L"From CPP CloseHandle failed with error: " << GetLastError() << std::endl;
//        }
    }

    return 0;
}

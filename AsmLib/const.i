
	IFND CONSTS
		CONSTS=1
		
		EXEC_BASE=4				; Base address for Exec library
		EXEC_Forbid=-132		; Stop Multitasking()
		EXEC_Permit=-138		; Start Multitasking()
		EXEC_OpenLib=-552		; Open Library(a1=name,d0=version -> d0=base)
		EXEC_CloseLib=-414		; Close Library(a1=base)
		EXEC_AllocMem=-198		; Allocate Memory(d0=size,d1=type -> d0=buffer)
		EXEC_FreeMem=-210		; Free Memory(a1=buffer,d0=size)
		EXEC_ALLOC_TYPE_CHIP=$10002				; Chip + Clear Type
		EXEC_ALLOC_TYPE_FAST=$10004				; Fast + Clear Type
		EXEC_ALLOC_TYPE_FAST_ELSE_CHIP=$10000	; (Fast + clear) or (Chip + Clear)
		
		DOS_OpenFile=-30		; Open a file(d1=name,d2=mode -> d0=file)
		DOS_CloseFile=-36		; Close a file(d1=file)
		DOS_ReadFile=-42		; Load a file(d1=file,d2=buffer,d3=length)
		DOS_SeekFile=-66		; Seek a file(d1=file,d2=position,d3=mode)
		
		DOS_ACCESS_EXISTING=1005	; R/W Access on existing file, seek start position
		DOS_ACCESS_CREATE=1006		; R/W Access on new file, delete previous file if exists
		DOS_SEEK_MODE_START=-1		; Relative to Beginning of file
		DOS_SEEK_MODE_CURRENT=0		; Relative to Current file position
		DOS_SEEK_MODE_END=1			; Relative to End of file
		
	ENDC

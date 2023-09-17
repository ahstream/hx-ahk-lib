CHROME_EXE_PATH := "C:\Program Files\Google\Chrome\Application\chrome.exe"
CHROME_PROCESS_KEY := "Application\chrome.exe"

CLOSE_AND_MINIMIZE_URL := "chrome-extension://ceegpiflkjflcklliibajfhlgoljefio/bookmark.html?cmd=close-tabs-minimize-window"
CLOSE_URL := "chrome-extension://ceegpiflkjflcklliibajfhlgoljefio/bookmark.html?cmd=close-window"

; ----- LOCATION HELPERS --------------------------------------------------------

GotoLocation(url, winId) {
	clipboard := url
	ActivateAndWaitForWin(winId)
	Sleep 250
	SendInput ^ t ^ v { enter }
	Sleep 250
	return
}

GotoLocationInBrowserInstances(url, processName) {
	WinGet, Windows, List
		Loop, %Windows% {
			isSourceWin := false
			winId := "ahk_id " . Windows%A_Index%
			WinGetTitle, thatTitle,	%winId%
			if (thatTitle == "")
				; not a valid window, skip!
				continue
			if IsDevToolsWin(thatTitle)
				continue ; not a valid window, skip!
			WinGet,	path,	ProcessPath,%winId%
			StrReplace(path, processName, "", count)
			if (count != 1)
				; not a valid process, skip!
				continue
			GotoLocation(url, winId)
			Sleep 10
			}
}

; ----- WINDOW HELPERS --------------------------------------------------------

GetWinTitle() {
	WinGetTitle, srcWinTitle, A
		return srcWinTitle
}

ActivateAndWaitForWin(winId) {
	Loop {
		WinActivate, %winId%
			WinWaitActive, %winId%, , 1
		if (ErrorLevel == 0) {
			return
		}
	}
}

IsDevToolsWin(title) {
	return InStr(title, "DevTools")
}

CountWindows(processName) {
	ct := 0
	WinGet, Windows, List
		Loop, %Windows% {
			winId := "ahk_id " . Windows%A_Index%
			WinGetTitle, thatTitle,	%winId%
			if (thatTitle == "")
				; not a valid window, skip!
				continue
			if IsDevToolsWin(thatTitle)
				continue ; not a valid window, skip!
			WinGet,	path,	ProcessPath, %winId%
			StrReplace(path, processName, "", count)
			if (count != 1)
				; not a valid process, skip!
				continue
			ct := ct + 1
		}
	return ct
}

WakeUpWindows(processName) {
	WinGet, Windows, List
		Loop, %Windows% {
			winId := "ahk_id " . Windows%A_Index%
			WinGetTitle, thatTitle,	%winId%
			if (thatTitle == "")
				continue
			WinGet,	path,	ProcessPath, %winId%
			StrReplace(path, processName, "", count)
			if (count != 1)
				; not a valid process, skip!
				continue
			WinActivate, %winId%
				Sleep 50
		}
}

; ----- MISC HELPERS ----------------------------------------------------------

StartBrowsers(instances, starterUrl) {
	global CHROME_EXE_PATH

	for index, instance in instances {
		Run, %CHROME_EXE_PATH% --new-tab --profile-directory="%instance%" %starterUrl%
			Sleep 1500
	}
}

GetSource(byref location, byRef winTitle, byRef selectedText, byRef winId) {
	selectedText := GetSelectedText()
	location := GetLocation()
	winTitle := GetWinTitle()
	WinGet, winid ,, A
}

GetLocation() {
	clipboard := ""
	Send, ^l
		Sleep 200
	Send, ^c
		Sleep 200
	return clipboard
}

GetSelectedText() {
	tmp = %ClipboardAll% ; save clipboard
	Clipboard := "" ; clear clipboard
	Send, ^c ; simulate Ctrl+C (=selection in clipboard)
	ClipWait, 0, 1 ; wait until clipboard contains data
	selection = %Clipboard% ; save the content of the clipboard
	Clipboard = %tmp% ; restore old content of the clipboard
	return selection
}

PaseRetweetMsg() {
	RetweetMsgs := Array("Check this out!", "Look here...", "This might be something!", "This is cool!", "Yes!!", "Let's go!", "Awsome", "This one!", "LFG", "GMI")
	Random, index, 1, 10
	msg := RetweetMsgs[index]
	SendInput %msg%
	sleep 50
	SendInput ^ { Enter }
}

ProcessExist(PIDorName := "") {
	Process Exist, %PIDorName%
	return ErrorLevel
}

SubArray(arr, fromPos, toPos) {
	newArr := []
	for index, element in arr {
		if (index >= fromPos and index <= toPos) {
			newArr.Push(element)
		}
	}
	return newArr
}

SortArray(arr, options="") {
	; specify only "Flip" in the options to reverse otherwise unordered array items
	; Source: https://www.autohotkey.com/board/topic/93570-sortarray/
	if	!IsObject(arr)
		return	0
	new :=	[]
	if	(options="Flip") {
		While	(i :=	arr.MaxIndex()-A_Index+1)
			new.Insert(arr[i])
		return	new
	}
	For each, item in arr
		list .=	item "`n"
	list :=	Trim(list,"`n")
	Sort, list, %options%
	Loop, parse, list, `n, `r
		new.Insert(A_LoopField)
	return	new
}

MultiLineInputBox(Text:="", Default:="", Caption:="Multi Line Input Box"){
	static
	ButtonOK:=ButtonCancel:= false
	if !MultiLineInputBoxGui{
		Gui, MultiLineInputBox: add, Text, r1 w600 , % Text
		Gui, MultiLineInputBox: add, Edit, r10 w600 vMultiLineInputBox, % Default
		Gui, MultiLineInputBox: add, Button, w60 gMultiLineInputBoxOK , &OK
		Gui, MultiLineInputBox: add, Button, w60 x+10 gMultiLineInputBoxCancel, &Cancel
		MultiLineInputBoxGui := true
	}
	GuiControl,MultiLineInputBox:, MultiLineInputBox, % Default
	Gui, MultiLineInputBox: Show,, % Caption
	SendMessage, 0xB1, 0, -1, Edit1, A
	while !(ButtonOK||ButtonCancel)
		continue
	if ButtonCancel
		return
	Gui, MultiLineInputBox: Submit, NoHide
	Gui, MultiLineInputBox: Cancel
	return MultiLineInputBox
	;----------------------
	MultiLineInputBoxOK:
		ButtonOK:= true
	return
	;----------------------
	MultiLineInputBoxGuiEscape:
	MultiLineInputBoxCancel:
		ButtonCancel:= true
		Gui, MultiLineInputBox: Cancel
	return
}

CloseAndMinimizeCurrentWindow() {
	global CLOSE_AND_MINIMIZE_URL
	GotoLinkInCurrentWindow(CLOSE_AND_MINIMIZE_URL)
}

CloseCurrentWindow() {
	global CLOSE_URL
	GotoLinkInCurrentWindow(CLOSE_URL)
}

GotoLinkInCurrentWindow(url) {
	lastClipboard := clipboard
	clipboard := url
	SendInput ^t^v{enter}
	Sleep 250
	clipboard := lastClipboard
}
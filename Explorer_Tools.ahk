; =======================================================================
; MODULE: Windows Explorer File Attribute Tools
; =======================================================================

SetSelectedFileAttribute(action) {
    hwnd := WinExist("A")
    
    ; Confirm execution target safety boundaries
    if !WinActive("ahk_class CabinetWClass") && !WinActive("ahk_class ExploreWClass") {
        ShowOSD("Not in Explorer")
        return
    }
    
    selectedFiles := GetExplorerSelectedFiles(hwnd)
    if (selectedFiles.Length == 0) {
        ShowOSD("No file selected")
        return
    }
    
    ; Apply systemic alterations to items in array target
    for filePath in selectedFiles {
        try {
            if (action == "hidden") {
                FileSetAttrib("+H", filePath)
                ShowOSD("HIDDEN")
            } else if (action == "regular") {
                FileSetAttrib("-H", filePath)
                ShowOSD("REGULAR")
            }
        } catch {
            ShowOSD("Access Denied")
        }
    }
}

; Safe Windows COM hook query to find exact matching workspace items
GetExplorerSelectedFiles(hwnd) {
    filePaths := []
    try {
        for window in ComObject("Shell.Application").Windows {
            if (window.hwnd == hwnd) {
                for item in window.document.SelectedItems {
                    filePaths.Push(item.Path)
                }
                break
            }
        }
    }
    return filePaths
}
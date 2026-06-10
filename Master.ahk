#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Global Page State ---
Global CurrentPage := 1  ; 1 = Volume Control, 2 = Home Assistant, 3 = File Attributes
Global PageNames   := ["Volume Control", "Home Assistant Scenes", "Explorer Attributes"]
Global IdleTimeout := -2500 ; Time in milliseconds before auto-reverting to Page 1

; --- Unified Shared On-Screen Display (OSD) ---
Global OsdGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
OsdGui.BackColor := "111111"
OsdGui.SetFont("s32 cWhite bold", "Segoe UI")
Global OsdText := OsdGui.Add("Text", "w550 Center", "Page: Volume")
WinSetTransparent(210, OsdGui)

ShowOSD(msg) {
    OsdText.Value := msg
    yPos := A_ScreenHeight / 2 - 150
    OsdGui.Show("NoActivate xCenter y" yPos)
    SetTimer(HideOSD, -2000)
}

HideOSD() {
    OsdGui.Hide()
}

; --- Auto-Revert Logic ---
ResetToDefaultPage() {
    Global CurrentPage
    if (CurrentPage != 1) {
        CurrentPage := 1
        ShowOSD("Page: Volume Control")
    }
}

RefreshTimeout() {
    if (CurrentPage != 1) {
        SetTimer(ResetToDefaultPage, IdleTimeout)
    }
}

; --- Include Sub-Modules ---
#Include ADI2_Volume.ahk
#Include HASS_Tools.ahk
#Include Explorer_Tools.ahk

; --- Core Page Switcher ---
XButton2 & MButton:: {
    Global CurrentPage
    CurrentPage := (CurrentPage >= PageNames.Length) ? 1 : CurrentPage + 1
    ShowOSD("Page: " . PageNames[CurrentPage])
    
    if (CurrentPage != 1) {
        SetTimer(ResetToDefaultPage, IdleTimeout)
    } else {
        SetTimer(ResetToDefaultPage, 0)
    }
}

; Preserve original standalone Side Button click function
$XButton2::Send("{XButton2}")

; =======================================================================
; CONDITIONAL HOTKEYS (Context Routing)
; =======================================================================

; --- PAGE 1: RME Volume Actions ---
#HotIf CurrentPage == 1
XButton2 & WheelUp::ChangeVolume(Step_dB)
XButton2 & WheelDown::ChangeVolume(-Step_dB)

; --- PAGE 2: Home Assistant Scene Switcher ---
#HotIf CurrentPage == 2
XButton2 & WheelUp:: {
    CycleHassScene(-1) ; Scroll up -> previous scene
    RefreshTimeout()
}
XButton2 & WheelDown:: {
    CycleHassScene(1)  ; Scroll down -> next scene
    RefreshTimeout()
}

; --- PAGE 3: Explorer File Attribute Actions ---
#HotIf CurrentPage == 3
XButton2 & WheelUp:: {
    SetSelectedFileAttribute("regular")
    RefreshTimeout()
}
XButton2 & WheelDown:: {
    SetSelectedFileAttribute("hidden")
    RefreshTimeout()
}

#HotIf ; Clear context guard
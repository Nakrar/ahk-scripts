#Requires AutoHotkey v2.0

; ==========================================
; RME ADI-2 DAC fs - MIDI Volume Controller
; ==========================================

; 1. PATH TO SENDMIDI (Update to your exact path)
Global SendMidiExe := "C:\Path\To\sendmidi.exe"

; 2. MIDI DEVICE NAME (Update to your exact device name)
Global MidiDeviceName := "ADI-2 DAC Midi Port 1" 

; 3. TARGET PARAMETER
; "1B" = Line Out (Main Speakers)
; "4B" = Phones (Headphones)
Global TargetParam := "1B" 

; 4. VOLUME SETTINGS
Global Step_dB := 1.0     ; dB to change per keystroke (e.g., 0.5 or 1.0)
Global Max_dB  := 6.0     ; Maximum hardware volume limit
Global Min_dB  := -114.5  ; Minimum hardware volume (Mute)

; Files to remember volume across PC reboots
Global StateFile := A_ScriptDir . "\rme_volume_state.txt"
Global MuteFile  := A_ScriptDir . "\rme_mute_state.txt"

; ==========================================
; HOTKEYS
; ==========================================

; Side Forward + Wheel Up -> Volume Up
XButton2 & WheelUp::ChangeVolume(Step_dB)

; Side Forward + Wheel Down -> Volume Down
XButton2 & WheelDown::ChangeVolume(-Step_dB)

; Side Forward + Middle Button Click -> Toggle Mute
XButton2 & MButton::ToggleMute()

; Keep the Side Forward button's original function when clicked alone
$XButton2::Send("{XButton2}")

; ==========================================
; OSD (ON-SCREEN DISPLAY) SETUP
; ==========================================
; Create a borderless, unclickable, always-on-top window
Global OsdGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
OsdGui.BackColor := "111111" ; Dark grey/black background
OsdGui.SetFont("s32 cWhite bold", "Segoe UI") ; Size 32, White, Segoe UI font

; Add text element to the GUI
Global OsdText := OsdGui.Add("Text", "w300 Center", "-35.0 dB")

; Make the entire GUI slightly transparent (0 = invisible, 255 = solid)
WinSetTransparent(210, OsdGui)

; ==========================================
; FUNCTIONS
; ==========================================

ChangeVolume(delta_dB) {
    if FileExist(MuteFile) {
        FileDelete(MuteFile)
    }

    current_dB := -35.0
    if FileExist(StateFile) {
        try current_dB := Float(FileRead(StateFile))
    }
    
    new_dB := current_dB + delta_dB
    if (new_dB > Max_dB)
        new_dB := Max_dB
    if (new_dB < Min_dB)
        new_dB := Min_dB
        
    SaveState(StateFile, new_dB)
    SendMidiVolume(new_dB)
    
    ; Show OSD formatted to 1 decimal place (e.g., "-15.0 dB")
    ShowOSD(Format("{:.1f} dB", new_dB))
}

ToggleMute() {
    current_dB := -35.0
    if FileExist(StateFile) {
        try current_dB := Float(FileRead(StateFile))
    }

    if FileExist(MuteFile) {
        FileDelete(MuteFile)
        SendMidiVolume(current_dB)
        ShowOSD(Format("{:.1f} dB", current_dB))
    } else {
        FileAppend("muted", MuteFile)
        SendMidiVolume(Min_dB)
        ShowOSD("MUTED")
    }
}

SendMidiVolume(dB_val) {
    val := Round((dB_val * 10) + 4096)
    msb := val // 128
    lsb := Mod(val, 128)
    hexMsb := Format("{:02X}", msb)
    hexLsb := Format("{:02X}", lsb)
    
    cmd := Format('"{1}" dev "{2}" syx hex 00 20 0D 71 02 {3} {4} {5}', SendMidiExe, MidiDeviceName, TargetParam, hexMsb, hexLsb)
    Run(cmd, , "Hide")
}

SaveState(filePath, val) {
    if FileExist(filePath)
        FileDelete(filePath)
    FileAppend(String(val), filePath)
}

ShowOSD(msg) {
    ; Update the text
    OsdText.Value := msg
    
    ; Calculate position (bottom center of the primary screen)
    yPos := A_ScreenHeight / 2 - 150
    
    ; Show GUI without stealing focus (NoActivate)
    OsdGui.Show("NoActivate xCenter y" yPos)
    
    ; Set a timer to hide the GUI after 2000 milliseconds (2 seconds)
    ; The negative sign means it runs only once and stops
    SetTimer(HideOSD, -2000)
}

HideOSD() {
    OsdGui.Hide()
}

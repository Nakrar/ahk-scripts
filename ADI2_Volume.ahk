; =======================================================================
; MODULE: RME ADI-2 DAC fs - MIDI Volume Controller
; =======================================================================

; --- System Configuration ---
Global SendMidiExe    := "C:\Soft\sendmidi-windows-1.3.1\sendmidi.exe"
Global MidiDeviceName := "ADI-2 DAC Midi Port 1"
Global TargetParam    := "1B" ; "1B" = Line Out, "4B" = Phones

; --- Volume Boundaries & Settings ---
Global Step_dB   := 1.0     
Global Max_dB    := 6.0     
Global Min_dB    := -114.5  
Global StateFile := A_ScriptDir . "\rme_volume_state.txt"

; --- Core Audio Modification Logic ---
ChangeVolume(delta_dB) {
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
    ShowOSD(Format("{:.1f} dB", new_dB))
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
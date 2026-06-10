; =======================================================================
; MODULE: Home Assistant API Scene Controller (Delayed Execution)
; =======================================================================

Global SecretsFile := A_ScriptDir . "\secrets.ini"
Global DebugLog    := A_ScriptDir . "\hass_debug.log"
Global HassURL     := IniRead(SecretsFile, "HASS", "URL", "ERROR")
Global HassToken   := IniRead(SecretsFile, "HASS", "Token", "ERROR")

; --- UI/Cycle Arrays ---
Global UpScenes := [
    {Id: "scene.light_all_on_warm", Name: "HASS: All On Warm"},
    {Id: "scene.light_bright",      Name: "HASS: Bright"},
    {Id: "scene.light_movie",       Name: "HASS: Movie"}
]
Global DownScenes := [
    {Id: "none",       Name: "{No Action}"},
    {Id: "scene.away", Name: "HASS: Away"}
]
Global CurrentUpIdx := 1, CurrentDownIdx := 1

; --- Logic to Trigger Call After Delay ---
CycleHassScene(direction) {
    ; You must list all global variables you intend to modify here
    Global CurrentUpIdx, CurrentDownIdx 
    
    if (direction == -1) {
        CurrentUpIdx := (CurrentUpIdx >= UpScenes.Length) ? 1 : CurrentUpIdx + 1
        ShowOSD(UpScenes[CurrentUpIdx].Name)
        SetTimer(ExecuteHassCall, -2000) 
    } else {
        CurrentDownIdx := (CurrentDownIdx >= DownScenes.Length) ? 1 : CurrentDownIdx + 1
        ShowOSD(DownScenes[DownScenes.Length].Name) ; Note: This line uses DownScenes now
        SetTimer(ExecuteHassCall, -2000) 
    }
}
ExecuteHassCall() {
    ; Determine which index is currently "active" based on which was last updated
    ; For this simple toggle, we check if the DownScene is "none"
    Target := (CurrentDownIdx != 1) ? DownScenes[CurrentDownIdx] : UpScenes[CurrentUpIdx]
    
    if (Target.Id != "none") {
        SendHassSceneRequest(Target.Id)
    } else {
        WriteLog("Skipped: No Action selected.")
    }
}

SendHassSceneRequest(sceneEntityId) {
    WriteLog("Attempting to fire: " . sceneEntityId)
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", HassURL . "/api/services/scene/turn_on", true)
        whr.SetRequestHeader("Authorization", "Bearer " . HassToken)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send('{"entity_id": "' . sceneEntityId . '"}')
        WriteLog("Success: Command sent to " . sceneEntityId)
    } catch Error as err {
        WriteLog("Error: " . err.Message)
        ShowOSD("HASS Conn Error")
    }
}

WriteLog(msg) {
    FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") . " - " . msg . "`n", DebugLog)
}
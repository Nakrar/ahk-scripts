# ahk-scripts
autohotkey (AHK) scripts

## ADI2_Volume.ahk

A lightweight volume controller for the **RME ADI-2 DAC fs** on Windows. 

This AutoHotkey v2 script allows you to control the internal hardware volume of your ADI-2 DAC using custom keyboard shortcuts. By sending raw **MIDI SysEx (System Exclusive)** commands directly to the device, this script completely bypasses the Windows software mixer. It is the perfect setup for audiophiles using **ASIO** or **WASAPI Exclusive** modes who still want the convenience of media keys.

Includes a **On-Screen Display (OSD)** to view your current dB level in real-time.

### Prerequisites

1. **RME ADI-2 DAC fs** running updated Firmware.
2. **AutoHotkey v2:** [autohotkey.com](https://www.autohotkey.com/).
3. **SendMIDI:** A free command-line tool by *gbevin*. Download the Windows release from the[SendMIDI GitHub page](https://github.com/gbevin/SendMIDI/releases).

### Hardware Setup
By default, the ADI-2 DAC ignores MIDI commands. To enable this on the physical device:
1. Press the **SETUP** button on your ADI-2 DAC.
2. Navigate to **Options** -> **Remap Keys/Diag**.
3. Scroll down to **MIDI Control** and set it to **ON**.

### Installation & Usage

#### 1. Find Your Exact MIDI Device Name
Before running the script, you need to find out what Windows named your DAC's MIDI port.
1. Open Windows **Command Prompt** (`cmd`).
2. Drag and drop your downloaded `sendmidi.exe` into the terminal, type a space, and type `list`.
   *(Example: `C:\Soft\sendmidi\sendmidi.exe list`)*
3. Hit Enter. You will see a list of MIDI devices.
4. Copy the exact name of your DAC (e.g., `ADI-2 DAC Midi Port 1`).

#### 2. Configure the Script
1. Open `ADI2_Volume.ahk` in any text editor (Notepad, VS Code, etc.).
2. Update the following variables at the top of the script:
   ```autohotkey
   ; 1. Point this to exactly where you saved sendmidi.exe
   Global SendMidiExe := "C:\Path\To\sendmidi.exe"

   ; 2. Paste the exact name you copied from the command prompt
   Global MidiDeviceName := "ADI-2 DAC Midi Port 1" 

   ; 3. Choose your target output
   ; "1B" = Line Out (Main Speakers) | "4B" = Phones (Headphones)
   Global TargetParam := "1B"

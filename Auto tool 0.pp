SetCurrentTool(0)
PlateThicknes = GetOEMDRO (1224)
If GetOemLED(28)<>0 Then
DoOEMButton (136)
Message "Tool Offsets were turned off"
'Exit Sub 'ERROR! exit the macro
End If
CurrentFeed = GetOemDRO(818) 'Get the current feedrate to return to later
CurrentAbsInc = GetOemLED(48) 'Get the current G90/G91 state
CurrentGmode = GetOemDRO(819) 'Get the current G0/G1 state

If GetOemLed (825)=0 Then 'Check to see if the probe is already grounded or faulty
DoOEMButton (1010) 'zero the Z axis so the probe move will start from here
Code "G4 P3" ' this delay gives me time to get from computer to hold probe in place
Code "G90 G31Z-4. F16" 'probing move, can set the feed rate here as well as how far to move
While IsMoving() 'wait while it happens
Wend
ZProbePos = GetVar(2002) 'get the exact point the probe was hit
Code "G0 Z" &ZProbePos 'go back to that point, always a very small amount of overrun
While IsMoving ()
Wend
Call SetDro (2, PlateThicknes) ' change to your plate thickness and then adjust for final accuracy
Sleep 200 'Pause for Dro to update.
Code "G1 Z1. F16" 'put the Z retract height you want here, must be greater than the touch plate thickness
While IsMoving ()
Wend
Code "(Z axis is now zeroed)" 'puts this message in the status bar
Code "F" &CurrentFeed 'Returns to prior feed rate
Else
Code "(Z-Plate is grounded, check connection and try again)" 'this goes in the status bar if applicable
End If
If CurrentAbsInc = 0 Then 'if G91 was in effect before then return to it
Code "G91"
End If
If CurrentGMode = 0 Then 'if G0 was in effect before then return to it
Code "G0"
End If   


'This subroutine is used to 0 Z axis using a tool with tool offset. 
'Tool in spindle must have a tool offset assigned and it must be set to the current tool


'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
'Preamble
'X-axis is not referenced
	If GetOEMLED(807) Then
		MsgBox ("X-axis no reference -> abort !!")
		DoButton(3)
		Exit Sub
	End If
	
	'Y-axis is not referenced
	If GetOEMLED(808) Then
		MsgBox ("Y-axis no reference -> abort !!")
		DoButton(3)
		Exit Sub
	End If

	'Z-axis is not referenced
	If GetOEMLED(809) Then
		MsgBox ("Z-axis no reference -> abort !!")
		DoButton(3)
		Exit Sub
	End If
If GetOemLED(16)<>0 Then 'Checks for machine coordinates
MsgBox "Please change to working coordinates"
Exit Sub 'ERROR! exit the macro
End If
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CurrentTool = GetCurrentTool()       'Gets current tool, if this is not the tool in the spindle, you will need to "reset" to abort.
CurrentOffset = GetToolParam(CurrentTool,2)
MsgBox ("Confirm current tool is " & CurrentTool) 'Confirm tool matches tool in the spindle or abort 
PlateThickness = GetOEMDRO (1224) 'Variable entered in the ATC page. Used to set touch plate thicknesses)
If GetOemLED(28) = 0 Then 	'See if tool offset is on or off (needs to be on) 
DoOEMButton (136)			' If off turns tool offsets on
Message "Tool Offsets were turned On"
End If
CurrentFeed = GetOemDRO(818) 'Get the current feedrate to return to later
CurrentAbsInc = GetOemLED(48) 'Get the current G90/G91 state
CurrentGmode = GetOemDRO(819) 'Get the current G0/G1 state

If GetOemLed (825)=0 Then 'Check to see if the probe is already grounded or faulty
DoOEMButton (1010) 'zero the Z axis so the probe move will start from here
Code "G4 P3" ' Delay in seconds to get from computer to hold probe in place if required.
Code "G90 G31Z-4. F16" 'probing move, can set the feed rate here as well as how far to move
While IsMoving() 'wait while it happens
Wend
ZProbePos = GetVar(2002) 'get the exact point the probe was hit
Code "G0 Z" & (ZProbePos - CurrentOffset)  'Goes to touch point then adjusts for tool offset.
While IsMoving ()
Wend
Call SetDro (2, PlateThickness) ' Sets the DRO to plate thickness and then adjust for final accuracy
Sleep 200 'Pause for Dro to update.
Code "G1 Z 1.0 F16" 'put the Z retract height you want here, must be greater than the touch plate thickness
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


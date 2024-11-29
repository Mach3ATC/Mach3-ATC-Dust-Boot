'This subroutine uses the tool setter to set the offsets in the Mach3 tool table. This is used in conjuction with the 
'the ATC page, in particular ToolZeroLength which is the lenght of the master tool.
' Prior to using the offsets for individual tools, the master tool (tool 0) must be set first, the value is automatically
' placed in the ToolZeroLength DRO on the ATC page and is used to calculate the offset in the tool tables
Sub Main()
'XXXXXXXXXXXXXXX preamble checks XXXXXXXXXXXXXXXX
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
If GetOemLED(825)<>0 Then
MsgBox "Z-Plate Grounded. Confirm Input pins correct and try again"
Exit Sub 'ERROR! exit the macro
End If
If GetOemLED(28)<>0 Then   "Checks if too offests are on if on turns them off.
DoOEMButton (136)
Message "Tool Offsets were turned off"
'Exit Sub 'ERROR! exit the macro
End If

'XXXXXXXXXXXXXXX preamble checks finished XXXXXXXXXXXXXXXX
'XXXXXXXXXXXXXXX Variables XXXXXXXXXXXXXXXX
CurrentFeed = GetOemDRO(818) 'Get the current feedrate to return to later
CurrentAbsInc = GetOemLED(48) 'Get the current G90/G91 state
CurrentGmode = GetOemDRO(819) 'Get the current G0/G1 state
CurrentToolNum = GetCurrentTool() 'Gets selected tool should be the same number in the current tool DRO.
SetterXPos = GetOemDRO(1229)		'X-M.C.(Machine Coordinates) of the fixed touch plate (from the tool set position DRO on ATC page) 
SetterYPos = GetOemDRO(1230)		'Y-M.C. of the fixed touch plate (from the tool set position DRO) 
ZProbeStart = GetOemDRO(1231) 	'Z-M.C. Height above fixed touch plate, where the probing starts (from the tool set position DRO) 
ToolZeroLength = GetOemDRO(1232) 	'Tool length of tool 0 (using asma method (this is applied to the offsets in offsettable. ) 
ZProbeMax = -4 				'Z-M.C. The probe is supposed to touch, before this depth is reached.  
ZRetract = .025 				'Must be a positive value! Number of units to retract the Z-axis between 1. 
ProbeFeed1 = 15					'Feed at the first probe run 
ProbeFeed2 = 1					'Feed at the second probe run, to get a more precise measurement 
CurrentFeedRate = GetOEMDRO(818)'


'XXXXXXXXXXXXXXX Variables end XXXXXXXXXXXXXXXX
'XXXXXXXXXXXXXXX Tool postion move XXXXXXXXXXXXXXXX
MsgBox ("Current Tool Num - " & CurrentToolNum) 			'Confirm correct tool number
Code "G0 G53 Z" & ZProbeStart 								'Move tool to Z position set in Tool setter position DRO
While IsMoving 
Wend 	'Wait for movement to complete 
'Sleep(100) 
Code "G53 X" & SetterXPos & " Y" & SetterYPos 						'Move tool over the touch plate location, Location is setable from ATC page 
While IsMoving 
Wend 
'Sleep(250) 
DoOEMButton (1010)					' Zero's Z work DRO
Sleep(1000)
'---Get in position and zero z-axis---
'---First probe run---
Code "G01 F" & ProbeFeed1 							'Change the feedrate to feedrate 1 from the variables. 
Code "G90 G31 Z" & ZProbeMax 						'G31 will probe at 1st feed rate. ProbeMax is the farthest Z will travel and will trip at that point.
While IsMoving()									'Wait for probing to finish.
Wend 												'End of while loop
Sleep (250)
ProbeDist = GetVar(2002) 								'Read the z-axis value of probe touch point or trip point if probe max was reached 
Message ("GetVar 2002 - "& ProbeDist)					'Status Message that gives the the touch off distance (GetVar 2002 for first touch off)
 Sleep (250)
'---2.nd probe run with reduced speed-- 
Code "G0 Z" & ProbeDist + ZRetract 					'Retracts  Z axis by the "ZRetract" distance from vaiables before starting 2nd probe. 
Code "G01 F" & ProbeFeed2 							'Slows feed down for more accurate touch off Change the feed rate to feedrate 2 from the variables. 
Code "G31 Z" & ZProbeMax							'G31 will probe at 2nd feed rate. ProbeMax is the farthest Z will travel and will trip at that point.
While IsMoving()									'Wait for probing to finish.
Wend 	
Sleep(500) 
ProbeDist2 = GetVar(2002) 							'Read the z-axis value of probe touch point for 2nd touch off. 
Message ("GetVar 2002 - "& ProbeDist2) 				'Status Message that gives the the touch off distance (GetVar 2002 for 2nd touch off)
'Sleep(500)
SetToolParam(CurrentToolNum,2,-(ToolZeroLength-ProbeDist2)) ' This changes values in the tool table. 
'It sets the designated tool number with the calculated tool offset length (which is parameter 2) 
'The value set (Tool offset) the is  ToolZeroLength(tool 0) - the 2nd prob length. 
															' 
'Sleep(500)								
DoOEMButton(316) 				' Save values in Tool Table database 
Sleep (500)								' Wait for tool table to update 
Code "G00 G53 Z" & ZProbeStart 	                    ' Move spindle almost tc top 
ToolOffsetZ = GetToolParam(CurrentToolNum, 2)
MsgBox ("Tool Offset Complete -"& ToolOffsetZ)	'Message box that gives the the Tool Offset distance entered in the Tool Table 	
If CurrentToolNum = 0 Then						'The master tool is tool 0. The master tool lenght is required to caclulate the offsets for the other tools. 
setOEMDRO (1232, ProbeDist2) 					'If probing for the the master length (tool 0), the 2nd prob distance will be added to the ATC DRO "zero Tool Length" 
End If
End Sub	
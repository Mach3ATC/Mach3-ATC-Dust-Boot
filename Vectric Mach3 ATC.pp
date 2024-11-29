+ =======================================
+ ---
+ Version 1
+   Tony     15/11/2005 Written
+   Tony     06/01/2006 Added ATC option
+   Tony     14/05/2006 Fixed G20 inch in header
+   Tony     24/07/2006 Added G2 & G3 Arc support + removed (( ))
+   Tony     18/06/2007 Replaced the Tool comment
+   Mark     14/08/2008 Added G1 to Feed moves, added New_Segment
+   Removed 2nd G20 in header.
+   Mark     28/08/2009 Added G91.1 to force use of incremental arcs
+   Added Substitution, File & Toolpath Notes.
+   Mark     30/11/2009 Added TOOLPATHS_OUTPUT.
+   Brian    15/12/2009 Remove M05 from NEW_SEGMENT
+   Mark     18/01/2014 Added Dwell
+   Mark     24/10/2018 Added Helical arcs.
+	Jeff	 12/11/2024 Added code required for turning air seal on/off for ATC router
+ =======================================


POST_NAME = "JJ Mach3 ATC (*.txt)"


FILE_EXTENSION = "txt"

UNITS = "inches"

DIRECT_OUTPUT = "Mach|Mach4.Document"

SUBSTITUTE = "({)}"

+------------------------------------------------
+    Line terminating characters
+------------------------------------------------

LINE_ENDING = "[13][10]"

+------------------------------------------------
+    Block numbering
+------------------------------------------------

LINE_NUMBER_START     = 0
LINE_NUMBER_INCREMENT = 10
LINE_NUMBER_MAXIMUM = 999999

+================================================
+
+    Formating for variables
+
+================================================

VAR LINE_NUMBER = [N|A|N|1.0]
VAR SPINDLE_SPEED = [S|A|S|1.0]
VAR FEED_RATE = [F|C|F|1.1]
VAR X_POSITION = [X|A|X|1.4]
VAR Y_POSITION = [Y|A|Y|1.4]
VAR Z_POSITION = [Z|A|Z|1.4]
VAR ARC_CENTRE_I_INC_POSITION = [I|A|I|1.4]
VAR ARC_CENTRE_J_INC_POSITION = [J|A|J|1.4]
VAR X_HOME_POSITION = [XH|A|X|1.4]
VAR Y_HOME_POSITION = [YH|A|Y|1.4]
VAR Z_HOME_POSITION = [ZH|A|Z|1.4]
VAR SAFE_Z_HEIGHT = [SAFEZ|A|Z|1.4]
VAR DWELL_TIME = [DWELL|A|P|1.2]
+================================================
+
+    Block definitions for toolpath output
+
+================================================

+---------------------------------------------------
+  Commands output at the start of the file
+---------------------------------------------------

begin HEADER

"( [TP_FILENAME] )"
"( File created: [DATE] - [TIME])"
"( for Mach2/3 from Vectric )"
"( Material Size)"
"( X= [XLENGTH], Y= [YLENGTH], Z= [ZLENGTH])"
"([FILE_NOTES])"
"(Toolpaths used in this file:)"
"([TOOLPATHS_OUTPUT])"
"(Tools used in this file: )"
"([TOOLS_USED])"
"[N]G00G20G17G90G40G49G80"
"[N]G70G91.1"
"[N]T[T]M06"
"[N] (Tool: [TOOLNAME])"
"[N]G00G43[ZH]H[T]"
"[N]M07"
"[N][S]M03"
"[N](Toolpath:- [TOOLPATH_NAME])"
"[N]([TOOLPATH_NOTES])"
"[N]G94"
"[N][XH][YH][F]"

+---------------------------------------------------
+  Commands output for rapid moves
+---------------------------------------------------

begin RAPID_MOVE

"[N]G00[X][Y][Z]"


+---------------------------------------------------
+  Commands output for the first feed rate move
+---------------------------------------------------

begin FIRST_FEED_MOVE

"[N]G1[X][Y][Z][F]"


+---------------------------------------------------
+  Commands output for feed rate moves
+---------------------------------------------------

begin FEED_MOVE

"[N]G1[X][Y][Z]"

+---------------------------------------------------
+  Commands output for the first clockwise arc move
+---------------------------------------------------

begin FIRST_CW_ARC_MOVE

"[N]G2[X][Y][I][J][F]"

+---------------------------------------------------
+  Commands output for clockwise arc  move
+---------------------------------------------------

begin CW_ARC_MOVE

"[N]G2[X][Y][I][J]"

+---------------------------------------------------
+  Commands output for the first counterclockwise arc move
+---------------------------------------------------

begin FIRST_CCW_ARC_MOVE

"[N]G3[X][Y][I][J][F]"

+---------------------------------------------------
+  Commands output for counterclockwise arc  move
+---------------------------------------------------

begin CCW_ARC_MOVE

"[N]G3[X][Y][I][J]"

+---------------------------------------------------
+  Commands output for first clockwise helical arc  moves
+---------------------------------------------------

begin FIRST_CW_HELICAL_ARC_MOVE

"[N]G2[X][Y][Z][I][J][F]"

+---------------------------------------------------
+  Commands output for clockwise helical arc  moves
+---------------------------------------------------

begin CW_HELICAL_ARC_MOVE

"[N]G2[X][Y][Z][I][J]"

+---------------------------------------------------
+  Commands output for first counterclockwise helical arc  moves
+---------------------------------------------------

begin FIRST_CCW_HELICAL_ARC_MOVE

"[N]G3[X][Y][Z][I][J][F]"

+---------------------------------------------------
+  Commands output for counterclockwise helical arc  moves
+---------------------------------------------------

begin CCW_HELICAL_ARC_MOVE

"[N]G3[X][Y][Z][I][J]"

+---------------------------------------------------
+  Commands output for first clockwise helical arc plunge moves
+---------------------------------------------------

begin FIRST_CW_HELICAL_ARC_PLUNGE_MOVE

"[N]G2[X][Y][Z][I][J][F]"

+---------------------------------------------------
+  Commands output for clockwise helical arc plunge moves
+---------------------------------------------------

begin CW_HELICAL_ARC_PLUNGE_MOVE

"[N]G2[X][Y][Z][I][J]"

+---------------------------------------------------
+  Commands output for first counter clockwise helical arc plunge moves
+---------------------------------------------------

begin FIRST_CCW_HELICAL_ARC_PLUNGE_MOVE

"[N]G3[X][Y][Z][I][J][F]"

+---------------------------------------------------
+  Commands output for counter clockwise helical arc plunge moves
+---------------------------------------------------

begin CCW_HELICAL_ARC_PLUNGE_MOVE

"[N]G3[X][Y][Z][I][J]"

+---------------------------------------------------
+  Commands output at toolchange
+---------------------------------------------------

begin TOOLCHANGE
"[N]M5"
"[N]G04 P10"
"[N]T[T]M6"
"[N] (Tool: [TOOLNAME])"
"[N]G43H[T]"


+---------------------------------------------------
+  Commands output for a new segment - toolpath
+  with same toolnumber but maybe different feedrates
+---------------------------------------------------

begin NEW_SEGMENT

"[N]M07"
"[N][S]M03"
"([TOOLPATH_NAME])"
"([TOOLPATH_NOTES])"


+---------------------------------------------
+  Commands output for a dwell move
+---------------------------------------------

begin DWELL_MOVE

"G04 [DWELL]"

+---------------------------------------------------
+  Commands output at the end of the file
+---------------------------------------------------

begin FOOTER

"[N]G00[ZH]"
"[N]G00[XH][YH]"
"[N]M5"
"[N]G04 P10"
"[N]M09"
"[N]M30"
%



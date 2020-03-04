#include-once
#cs ----------------------------------------------------------------------------
	Author:         Hawk63
	Themes for SCNet_GUI UDF
#ce ----------------------------------------------------------------------------

;#Set Default Theme
Global $GUIThemeColor = "0xFFFFFF" ; GUI Background Color
Global $FontThemeColor = "0x1B1B1B" ; Font Color
Global $GUIBorderColor = "0xD8D8D8" ; GUI Border Color
Global $ButtonBKColor = "0x0262A8" ; Metro Button BacKground Color
Global $ButtonTextColor = "0xFFFFFF" ; Metro Button Text Color
Global $CB_Radio_Color = "0xE5E5E5" ;Checkbox and Radio Color (Box/Circle)
Global $GUI_Theme_Name = "DarkTealV2" ;Theme Name (For internal usage)
Global $CB_Radio_Hover_Color = "0xD0D0D0" ; Checkbox and Radio Hover Color (Box/Circle)
Global $CB_Radio_CheckMark_Color = "0x1B1B1B" ; Checkbox and Radio checkmark color

Func _SetTheme($ThemeSelect = "SCNet_Light")
	$GUI_Theme_Name = $ThemeSelect
	Switch ($ThemeSelect)
		Case "SCNet_Light"
			$GUIThemeColor = "0xFFFFFF"
			$FontThemeColor = "0x1B1B1B"
			$GUIBorderColor = "0xD8D8D8"
			$ButtonBKColor = "0x0262A8"
			$ButtonTextColor = "0xFFFFFF"
			$GUI_Theme_Name = "SCNet_Light"
			$CB_Radio_Color = "0xE5E5E5"
			$CB_Radio_Hover_Color = "0xD0D0D0"
			$CB_Radio_CheckMark_Color = "0x1B1B1B"
		Case Else
			ConsoleWrite("SCNet-UDF-Error: Theme not found, using default theme." & @CRLF)
			$GUIThemeColor = "0xFFFFFF"
			$FontThemeColor = "0x1B1B1B"
			$GUIBorderColor = "0xD8D8D8"
			$ButtonBKColor = "0x0262A8"
			$ButtonTextColor = "0xFFFFFF"
			$CB_Radio_Color = "0xE5E5E5"
			$CB_Radio_Hover_Color = "0xD0D0D0"
			$CB_Radio_CheckMark_Color = "0x1B1B1B"
			$GUI_Theme_Name = "SCNet_Light"
	EndSwitch
EndFunc   ;==>_SetTheme

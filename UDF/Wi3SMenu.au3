#include-once
#include <Array.au3>
#include <WinAPI.au3>
#include <WinAPIGdi.au3>

#cs ==========================================================

	Name ..........: 	Wi3SMenu UDF
	Description ...: 	Create Slide Menu with Windows 10 style.
	Version .......: 	v1.0
	Author ........: 	wuuyi123 (NDH)

	 _ _ _ _ ___ ____ _____
	| | | |_|__ |   _|     |___ ___ _ _
	| | | | |__ |_   | | | | -_|   | | |
	|_____|_|___|____|_|_|_|___|_|_|___|
	------------------------------------
	~ Wi3SMenu ~ Slide Menu Win 10 Style
	------------------------------------

	MAIN FUNCTION

	Wi3SMenu_Create 			- Create a Wi3SMenu.
	Wi3SMenu_AddItem 			- Add menu item for menu.
	Wi3SMenu_SetColor 			- Set menu color.
	Wi3SMenu_SetItemColor 		- Set menu item color.
	Wi3SMenu_SetItemIcon 		- Set menu item icon.
	Wi3SMenu_ClickItem			- Click a menu item.
	Wi3SMenu_Slide 				- Slide a menu.
	Wi3SMenu_EnableItem 		- Enable/Disable menu item.
	Wi3SMenu_RegisterAutoSize 	- Set auto size when parent GUI resizing (only AutoIt v3 GUI).

#ce=============================================================================================


Global $__aWi3SMenuDataList[1]
Global Enum  $__idMenuTimer 		= 169, $__idMenuBtnTimer, $__idMenuItemTimer, $__idMenuSlideTimer
Global Const $__hWi3SMenuProc 		= DllCallbackRegister('__Wi3SMenu__Proc', 		'lresult', 	'hwnd;uint;wparam;lparam')
Global Const $__hWi3SMenuBtnProc 	= DllCallbackRegister('__Wi3SMenu__BtnProc', 	'lresult', 	'hwnd;uint;wparam;lparam')
Global Const $__hWi3SMenuItemProc 	= DllCallbackRegister('__Wi3SMenu__ItemProc', 	'lresult', 	'hwnd;uint;wparam;lparam')
Global Const $__hWi3SMenuSlideProc 	= DllCallbackRegister('__Wi3SMenu__SlideProc', 	'none', 	'hwnd;uint;uint_ptr;dword')
Global Const $tagWi3SMenuType 	  = 'HWND 	hParent;' 	& _
									'HWND	hBtn;'		& _
									'HWND	hItemCur;'	& _
									'HANDLE hProc;' 	& _
									'LONG 	hTimer;'	& _
									'INT	iMoved;'	& _
									'INT 	iMaxW;' 	& _
									'INT 	iSize;' 	& _
									'CHAR 	sText[50];' & _
									'INT 	iCont;' 	& _
									'HANDLE hFont;'		& _
									'BOOL 	bExpanded;'	& _
									'DWORD	iBack;'		& _
									'DWORD	iFore;'		& _
									'DWORD	iHover;'	& _
									'DWORD	iPress;'	& _
									'BOOL	bAutoHide;' & _
									'BOOL	bTabMode;'
Global Const $tagWi3SMenuBtnType  =	'HWND 	hMenu;'		& _
									'HANDLE hProc;'		& _
									'LONG 	hTimer;'	& _
									'BYTE 	iState;'	& _
									'BYTE 	iClick;'
Global Const $tagWi3SMenuItemType = 'HWND 	hMenu;' 	& _
									'HANDLE hProc;' 	& _
									'WCHAR 	sText[50];' & _
									'CHAR 	sEvent[30];'& _
									'BOOL	bEnable;'	& _
									'INT 	iBack;'	 	& _
									'INT 	iFore;' 	& _
									'INT 	iHover;' 	& _
									'INT 	iPress;' 	& _
									'HANDLE hFont;'		& _
									'HANDLE	hIcon;' 	& _
									'INT	iIconSize;' & _
									'LONG 	hTimer;' 	& _
									'BOOL 	bHover;' 	& _
									'BOOL 	bDown;'

#cs
Function name ......:	Wi3SMenu_Create
Description ........:	Create a Slide Menu Windows 10 style with color and opacity.
Syntax .............:	Wi3SMenu_Create($hParent, [$iMaxWidth = 150, $iItemSize = 50, [$sMenuName = '', [$iBack = 0x1F1F1F, [$iFore = 0xFFFFFF, [$iAlpha = -1, [$bTabMode = False, [$bAutoHide = True]]]]]]]])
Parameters .........:	[in]		(HWND) 	$hParent	- Handle of parent GUI.
						[in, opt] 	(INT) 	$iMaxWidth	- Maximium width of menu when expanded. Default is 150
						[in, opt] 	(INT) 	$iItemSize	- Size of item/Minimium width of menu. Default is 50
						[in, opt] 	(WCHAR) $sMenuName	- Title of menu. Default is null.
						[in, opt]	(DWORD) $iBack		- Background color of menu (ColorREF - BRG). Default is 0x1F1F1F.
						[in, opt]	(DWORD) $iFore		- Foreground color of menu (ColorREF - BRG). Default is 0xFFFFFF.
						[in, opt]	(INT) 	$iAlpha		- Opacity of menu, value from 0 to 255. Default is -1.
														* Note: if this value <> -1, do not set Classic Theme for your Windows.
						[in, opt]	(BOOL) 	$bTabMode	- Set Tab mode. Default is False.
						[in, opt]	(BOOL) 	$bAutoHide	- Auto hide menu. Default is True.
Return values ......: 	(HWND) Handle of Wi3SMenu. 0 if fail.
#ce ==========================================================================================================================================================================
Func Wi3SMenu_Create($hParent, $iMaxWidth = 150, $iItemSize = 50, $sMenuName = Null, $iBack = 0x1F1F1F, $iFore = 0xFFFFFF, $iAlpha = -1, $bTabMode = False, $bAutoHide = True)
	If Not $hParent Then Return 0
	__Wi3SMenu__Regiser()
	Local $MenuData = DllStructCreate($tagWi3SMenuType), $MenuBtnData = DllStructCreate($tagWi3SMenuBtnType)
	_ArrayAdd($__aWi3SMenuDataList, $MenuData)
	_ArrayAdd($__aWi3SMenuDataList, $MenuBtnData)
	Local $Rect = DllStructCreate('int x;int y;int w;int h')
	DllCall('user32.dll', 'bool', 'GetClientRect', 'hwnd', $hParent, 'struct*', $Rect)

	If @OSVersion = "WIN_7" Or @OSVersion = "WIN_VISTA" Then $iAlpha = -1

	Local $iExStyle = $iAlpha = -1 ? 0x80 : BitOR(0x80, 0x80000)
	$MenuBtnData.hMenu = _WinAPI_CreateWindowEx($iExStyle, 'Wi3.SMenu', $sMenuName, BitOR(0xE, 0x100, 0x40000000), 0, 0, $iItemSize, $Rect.h, $hParent)
	If @error Or $MenuBtnData.hMenu = 0 Then Return SetError(0, 0, False)
	Local $hBmpBack = _WinAPI_CreateSolidBitmap($hParent, $iBack, $iItemSize, $Rect.h, 0)
	DllCall('Gdi32.dll', 'bool', 'DeleteObject', 'handle', __SendMsg($MenuBtnData.hMenu, 0x0172, 0, $hBmpBack))
	If $iAlpha <> -1 Then DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $MenuBtnData.hMenu, "INT", $iBack, "byte", $iAlpha, "dword", 0x2)

	$MenuData.hParent 	= $hParent
	$MenuData.iMaxW		= $iMaxWidth
	$MenuData.iSize		= $iItemSize
	$MenuData.iBack 	= $iBack
	$MenuData.iFore 	= $iFore
	$MenuData.iHover 	= __AdjustBright($iBack, 0xF)
	$MenuData.iPress 	= __AdjustBright($iBack, 0x1F)
	$MenuData.sText 	= $sMenuName
	$MenuData.iCont		= 1
	$MenuData.bExpanded	= 0
	$MenuData.bAutoHide	= $bAutoHide
	$MenuData.bTabMode	= $bTabMode
	$MenuData.iMoved 	= $iItemSize
	$MenuData.hFont 	= _WinAPI_CreateFont(0, 9, 0, 0, Default, 0, 0, 0, Default, Default, Default, Default, Default, "Segoe UI")

	$MenuData.hProc = _WinAPI_SetWindowLong($MenuBtnData.hMenu, -4, DllCallbackGetPtr($__hWi3SMenuProc))
	_WinAPI_SetWindowLong($MenuBtnData.hMenu, -21, DllStructGetPtr($MenuData))
	__InvalidRect($MenuBtnData.hMenu)
	$MenuData.hBtn = _WinAPI_CreateWindowEx(0, 'Wi3.SMenu.Button', '', BitOR(0x10000000, 0x40000000, 0xE, 0x100), 0, 0, $iMaxWidth, $iItemSize, $MenuBtnData.hMenu)
	Local $hBmpBack2 = _WinAPI_CreateSolidBitmap($hParent, $iBack, $iMaxWidth, $iItemSize, 0)
	DllCall('Gdi32.dll', 'bool', 'DeleteObject', 'handle', __SendMsg($MenuData.hBtn, 0x0172, 0, $hBmpBack2))
	$MenuBtnData.hProc = _WinAPI_SetWindowLong($MenuData.hBtn, -4, DllCallbackGetPtr($__hWi3SMenuBtnProc))
	_WinAPI_SetWindowLong($MenuData.hBtn, -21, DllStructGetPtr($MenuBtnData))
	__InvalidRect($MenuData.hBtn)

	DllCall('user32.dll', 'bool', 'ShowWindow', 'hwnd', $MenuBtnData.hMenu, 'int', 4)

	Return $MenuBtnData.hMenu
EndFunc

#cs
Function name ......:	Wi3SMenu_AddItem
Description ........:	Create a menu item for Wi3SMenu.
Syntax .............:	Wi3SMenu_AddItem($hMenu, [$sText = Null, [$sIcon = Null, [$iIconSize = 24, [$iBack = -1, [$iFore = -1, [$sEvent = Null]]]]]])
Parameters .........:	[in]		(HWND) 	$hMenu		- Handle parent Wi3Smenu created by Wi3SMenu_Create()
						[in, opt]	(WCHAR) $sText		- Name of menu item. Default is null.
						[in, opt]	(WCHAR) $sIcon		- Path of icon for menu item. Default is null.
						[in, opt]	(INT) 	$iIconSize	- Size of icon for menu item, should use 2^n (2, 4, 8, 16, 32, 64, 128...). Default is 24.
						[in, opt]	(INT)	$iBack		- Background color of menu item (ColorREF - BRG). Default is -1 to get color of menu parent.
						[in, opt]	(INT)	$iFore		- Foreground color of menu item (ColorREF - BRG). Default is -1 to get color of menu parent.
						[in, opt]	(CHAR)	$sEvent		- Function name to execute when click-up menu item. Default is null.
Return values ......: 	(HWND) Handle of menu item. 0 if fail.
#ce ==================================================================================================================
Func Wi3SMenu_AddItem($hMenu, $sText = Null, $sIcon = Null, $iIconSize = 24, $iBack = -1, $iFore = -1, $sEvent = Null)
	If Not $hMenu Then Return 0

	Local $MData = DllStructCreate($tagWi3SMenuType, _WinAPI_GetWindowLong($hMenu, -21))
	If @error Then Return 0
	Local $MItemData = DllStructCreate($tagWi3SMenuItemType)
	_ArrayAdd($__aWi3SMenuDataList, $MItemData)
	Local $hMenuItem = _WinAPI_CreateWindowEx(0, 'Wi3.SMenu.Item', '', BitOR(0x10000000, 0x40000000, 0xE, 0x100, 0x200), 0, $MData.iSize*$MData.iCont, $MData.iMaxW, $MData.iSize, $hMenu)
	If @error Then Return 0
	$MData.iCont 		+= 1
	$MItemData.hMenu 	= $hMenu
	$MItemData.sText 	= $sText
	$MItemData.sEvent	= $sEvent
	$MItemData.hIcon 	= DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', 0, 'int', $iIconSize, 'int', $iIconSize, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)[5]
	$MItemData.iIconSize= $iIconSize
	$MItemData.iBack 	= ($iBack = -1) ? $MData.iBack : $iBack
	$MItemData.iFore 	= ($iFore = -1) ? $MData.iFore : $iFore
	$MItemData.iHover 	= __AdjustBright($MItemData.iBack, 0xF)
	$MItemData.iPress 	= __AdjustBright($MItemData.iBack, 0x1F)
	$MItemData.bEnable	= True

	$MItemData.hProc = _WinAPI_SetWindowLong($hMenuItem, -4, DllCallbackGetPtr($__hWi3SMenuItemProc))
	_WinAPI_SetWindowLong($hMenuItem, -21, DllStructGetPtr($MItemData))
	__InvalidRect($hMenu)
	__InvalidRect($hMenuItem)

	Return $hMenuItem
EndFunc

#cs
Function name ......:	Wi3SMenu_SetColor
Description ........:	Set color for menu.
Syntax .............:	Wi3SMenu_SetColor($hMenu, [$iBack = -1, [$iFore = -1]])
Parameters .........:	[in]		(HWND) 	$hMenu		- Handle parent Wi3Smenu created by Wi3SMenu_Create()
						[in, opt]	(DWORD) $iBack		- New background color for menu. Default is -1, no change.
						[in, opt]	(DWORD) $iFore		- New foreground color for menu. Default is -1, no change.
Return values ......: 	(BOOL) 1 if success, 0 if fail.
#ce ====================================================
Func Wi3SMenu_SetColor($hMenu, $iBack = -1, $iFore = -1)
	If Not $hMenu Then Return 0
	Local $Data = DllStructCreate($tagWi3SMenuType, _WinAPI_GetWindowLong($hMenu, -21))
	If @error Then Return 0
	If $iBack <> -1 Then
		$Data.iback = $iBack
		$Data.iHover 	= __AdjustBright($iBack, 0xF)
		$Data.iPress 	= __AdjustBright($iBack, 0x1F)
	EndIf
	If $iFore <> -1 Then $Data.iFore = $iFore
	__InvalidRect($hMenu)
	Return 1
EndFunc

#cs
Function name ......:	Wi3SMenu_SetItemColor
Description ........:	Set color for menu item.
Syntax .............:	Wi3SMenu_SetItemColor($hMenuItem, [$iBack = -1, [$iFore = -1]])
Parameters .........:	[in]		(HWND) 	$hMenuItem	- Handle menu item.
						[in, opt]	(DWORD) $iBack		- New background color for menu item. Default is -1, no change.
						[in, opt]	(DWORD) $iFore		- New foreground color for menu item. Default is -1, no change.
Return values ......: 	(BOOL) 1 if success, 0 if fail.
#ce ============================================================
Func Wi3SMenu_SetItemColor($hMenuItem, $iBack = -1, $iFore = -1)
	If Not $hMenuItem Then Return 0
	Local $Data = DllStructCreate($tagWi3SMenuItemType, _WinAPI_GetWindowLong($hMenuItem, -21))
	If @error Then Return 0
	If $iBack <> -1 Then
		$Data.iBack = $iBack
		$Data.iHover 	= __AdjustBright($iBack, 0xF)
		$Data.iPress 	= __AdjustBright($iBack, 0x1F)
	EndIf
	If $iFore <> -1 Then $Data.iFore = $iFore
	__InvalidRect($hMenuItem)
	Return 1
EndFunc

#cs
Function name ......:	Wi3SMenu_SetItemIcon
Description ........:	Set icon for menu item.
Syntax .............:	Wi3SMenu_SetItemIcon($hMenuItem, $sIcon, [$iSize = -1])
Parameters .........:	[in]		(HWND) 	$hMenuItem	- Handle menu item.
						[in]		(WCHAR) $sIcon		- Path to icon.
						[in, opt]	(INT) 	$iSize		- Size of icon. Default is -1, no change.
Return values ......: 	(BOOL) 1 if success, 0 if fail.
#ce ======================================================
Func Wi3SMenu_SetItemIcon($hMenuItem, $sIcon, $iSize = -1)
	If Not $hMenuItem Then Return 0
	Local $Data = DllStructCreate($tagWi3SMenuItemType, _WinAPI_GetWindowLong($hMenuItem, -21))
	If @error Then Return 0
	$Data.hIcon = DllCall('shell32.dll', 'int', 'SHExtractIconsW', _
	'wstr', $sIcon, 'int', 0, 'int', $iSize = -1 ? $Data.iIconSize : $iSize, 'int', $iSize = -1 ? $Data.iIconSize : $iSize, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)[5]
	__InvalidRect($hMenuItem)
	Return 1
EndFunc

#cs
Function name ......:	Wi3SMenu_ClickItem
Description ........:	Set icon for menu item.
Syntax .............:	Wi3SMenu_ClickItem($hMenuItem)
Parameters .........:	[in]		(HWND) 	$hMenuItem	- Handle menu item.
Return values ......: 	(BOOL) 1 if success, 0 if fail.
#ce ===============================
Func Wi3SMenu_ClickItem($hMenuItem)
	If Not $hMenuItem Then Return 0
	Local $MenuItemData = DllStructCreate($tagWi3SMenuItemType, _WinAPI_GetWindowLong($hMenuItem, -21))
	DllCall('user32.dll', 'lresult', 'SendMessageW', 'hwnd', $hMenuItem, 'uint', 0x0202, 'wparam', 0x0001, 'lparam', 0)
	If @error Then Return 0
	Return 1
EndFunc

#cs
Function name ......:	Wi3SMenu_Slide
Description ........:	Slide a Wi3SMenu.
Syntax .............:	Wi3SMenu_Slide($hMenu)
Parameters .........:	[in]		(HWND) 	$hMenu	- Handle of Wi3SMenu.
Return values ......: 	(BOOL) 1 if success, 0 if fail.
#ce =======================
Func Wi3SMenu_Slide($hMenu)
	If Not $hMenu Then Return 0
	__SetTimer($hMenu, $__idMenuSlideTimer, 10, DllCallbackGetPtr($__hWi3SMenuSlideProc))
	If @error Then Return 0
	Return 1
EndFunc


#cs
Function name ......:	Wi3SMenu_EnableItem
Description ........:	EnableItem or Disable menu item.
Syntax .............:	Wi3SMenu_EnableItem($hMenuItem, [$bEnable = True])
Parameters .........:	[in]		(HWND) 	$hMenu 		- Handle of menu item.
						[in, opt]	(BOOL)	$bEnable	- True if enable, false if disable. Default is True.
Return values ......: 	(BOOL) 1 if success, 0 if fail.
#ce =================================================
Func Wi3SMenu_EnableItem($hMenuItem, $bEnable = True)
	If Not $hMenuItem Then Return 0
	Local $Data = DllStructCreate($tagWi3SMenuItemType, _WinAPI_GetWindowLong($hMenuItem, -21))
	If $Data.bEnable = $bEnable Then Return 0
	DllCall('user32.dll', 'bool', 'EnableWindow', 'hwnd', $hMenuItem, 'bool', $bEnable)
	If @error Then Return 0
	$Data.bEnable = $bEnable
	__InvalidRect($hMenuItem)
	Return 1
EndFunc

#cs
Function name ......:	Wi3SMenu_RegisterAutoSize
Description ........:	EnableItem or Disable menu item.
Syntax .............:	Wi3SMenu_RegisterAutoSize()
Parameters .........:	(None)
Return values ......: 	(BOOL) 1 if success, 0 if fail.
Note................:	This function only use for AutoIt v3 GUI.
						If create window from WinAPI, you please add " __Wi3SMenu__WMSIZE($hWnd, $iMsg, $wParam, $lParam) " to WM_SIZE message.
						Example:
						...
						Function CallBbackProc($hWnd, $iMsg, $wParam, $lParam)
							...
							Switch $iMsg
								Case $WM_SIZE
									__Wi3SMenu__WMSIZE($hWnd, $iMsg, $wParam, $lParam)
								Case ...
							...
						EndFunc
						...
#ce =================================================
Func Wi3SMenu_RegisterAutoSize()
	Return GUIRegisterMsg(0x5, '__Wi3SMenu__WMSIZE')
EndFunc






#Region# ;===== Internal Functions =============================================

Func __Wi3SMenu__Proc($hWnd, $uMsg, $wParam, $lParam)
	Local $Data = DllStructCreate($tagWi3SMenuType, _WinAPI_GetWindowLong($hWnd, -21))
	Switch $uMsg
		Case 0x0113
			If Not $Data.bExpanded Then Return 0
			If Not _WinAPI_GetFocus() = $Data.hParent Then
				__KillTimer($hWnd, $__idMenuTimer)
				Wi3SMenu_Slide($hWnd)
				Return 0
			EndIf

			Local $WndRct = DllStructCreate('int;int;int;int')
			Local $CurPt  = DllStructCreate('int;int')
			DllCall('user32.dll', 'bool', 'GetWindowRect', 'hwnd', $hWnd, 'struct*', $WndRct)
			DllCall('user32.dll', 'bool', 'GetCursorPos', 'struct*', $CurPt)

			If __PtInRect($WndRct, $CurPt) Then Return 0

			Local $aRet = DllCall('user32.dll', "short", "GetAsyncKeyState", "int", 0x01)
			If @error Then Return 0
			$aRet = BitAND($aRet[0], 0x8000)

			If $aRet Then
				__KillTimer($hWnd, $__idMenuTimer)
				Wi3SMenu_Slide($hWnd)
				Return 0
			EndIf
	EndSwitch
	Return __CallWndProc($Data.hProc, $hWnd, $uMsg, $wParam, $lParam)
EndFunc

Func __Wi3SMenu__BtnProc($hWnd, $uMsg, $wParam, $lParam)
	Local $Data = DllStructCreate($tagWi3SMenuBtnType, _WinAPI_GetWindowLong($hWnd, -21))
	Local $MenuData = DllStructCreate($tagWi3SMenuType, _WinAPI_GetWindowLong($Data.hMenu, -21))
	Switch $uMsg
		Case 0x000F
			Local $Ps, $Rct = DllStructCreate('int x;int y;int w;int h')
			__GetClientRect($hWnd, $Rct)
			__BeginPaint($hWnd, $Ps)
				Local $hBrush
				If $Data.iState Then
					$hBrush = _WinAPI_CreateSolidBrush($Data.iState = 2 ?  $MenuData.iPress : $MenuData.iHover)
				Else
					$hBrush = _WinAPI_CreateSolidBrush($MenuData.iBack)
				EndIf

				_WinAPI_FillRect($Ps.hDC, $Rct, $hBrush)
				Local $hPen = _WinAPI_CreatePen(0, 1, $MenuData.iFore)
				_WinAPI_SelectObject($Ps.hDC, $hPen)
				_WinAPI_SetBkMode($Ps.hDC, 1)
				_WinAPI_SetTextColor($Ps.hDC, $MenuData.iFore)

				If $MenuData.bExpanded Then
					Local $X = Round($Rct.h/2-8), $Y = Round($Rct.h/2)
					_WinAPI_DrawLine($Ps.hDC, $X, $Y, $X+7, $Y-7)
					_WinAPI_DrawLine($Ps.hDC, $X, $Y, $X+7, $Y+7)
					_WinAPI_DrawLine($Ps.hDC, $X, $Y, $X+15, $Y)
				Else
					Local $X = Round($Rct.h/2-8), $Y = Round($Rct.h/2 - 4), $W = $X + 16
					_WinAPI_DrawLine($Ps.hDC, $X, 	$Y, $W,   $Y)
					_WinAPI_DrawLine($Ps.hDC, $X, $Y+4, $W, $Y+4)
					_WinAPI_DrawLine($Ps.hDC, $X, $Y+8, $W, $Y+8)
				EndIf

			_WinAPI_SelectObject($Ps.hDC, $MenuData.hFont)
			If $MenuData.sText And $MenuData.bExpanded Then __TextOut($Ps.hDC, $MenuData.iSize + 5, $MenuData.iSize/2-12, $MenuData.sText)

			__EndPaint($hWnd, $Ps)
			_WinAPI_DeleteObject($hBrush)
			_WinAPI_DeleteObject($hPen)
		Case 0x0202
			DllCall("user32.dll", "bool", "ReleaseCapture")
			If $Data.iClick = 2 Then Return 0
			$Data.iClick = 0
			IF __IsMouseOver($hWnd) Then
				$Data.iState = 1
			ELSE
				$Data.iState = 0
				Return 0
			ENDIf
			Wi3SMenu_Slide($Data.hMenu)
			If (Not $MenuData.bExpanded) And $MenuData.bAutoHide Then __SetTimer($Data.hMenu, $__idMenuTimer, 10, Null)
			__InvalidRect($hWnd)
			Return 0

		Case 0x0201
			DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $hWnd)
			IF $Data.iClick = 2 Then Return 0
			$Data.iClick = 1
			$Data.iState = 2
			__InvalidRect($hWnd)
			Return 0

		Case 0x0200
			IF $Data.iClick = 2 Then Return 0
			If $Data.iState Then Return 0
			IF __IsMouseOver($hWnd) Then
				IF $Data.hTimer = 0 Then $Data.hTimer = __SetTimer($hWnd, $__idMenuBtnTimer, 50, Null)
				IF $Data.iClick Then
					$Data.iState = 2
				Else
					$Data.iState = 1
				ENDIF
			ELSE
				IF $Data.iState = 0 Then Return 0
				$Data.iState = 0
			ENDIF
			__InvalidRect($hWnd)

		Case 0x0113
			IF __IsMouseOver($hWnd) = False Then
				__KillTimer($hWnd, $__idMenuBtnTimer)
				$Data.hTimer = 0
				$Data.iState = 0
			EndIf
			__InvalidRect($hWnd)
		Case 0x0014
			Return 1
	EndSwitch

	Return __CallWndProc($Data.hProc, $hWnd, $uMsg, $wParam, $lParam)
EndFunc

Func __Wi3SMenu__ItemProc($hWnd, $uMsg, $wParam, $lParam)
	Local $Data = DllStructCreate($tagWi3SMenuItemType, _WinAPI_GetWindowLong($hWnd, -21))
	Local $MenuData = DllStructCreate($tagWi3SMenuType, _WinAPI_GetWindowLong($Data.hMenu, -21))
	Switch $uMsg
		Case 0x000F
			Local $Ps, $Rct = DllStructCreate('int x;int y;int w;int h')
			__GetClientRect($hWnd, $Rct)
			__BeginPaint($hWnd, $Ps)
				Local $hBrush
				If $Data.bHover Then
					$hBrush = _WinAPI_CreateSolidBrush($Data.bDown ? $Data.iPress : $Data.iHover)
				Else
					$hBrush = _WinAPI_CreateSolidBrush($Data.iBack)
				EndIf
				_WinAPI_FillRect($Ps.hDC, $Rct, $hBrush)

				Local $H = ($Rct.h/2)-($Data.iIconSize/2)
				_WinAPI_DrawIconEx($Ps.hDC, $H, $H, $Data.hIcon, $Data.iIconSize, $Data.iIconSize)
				_WinAPI_SetBkMode($Ps.hDC, 1)
				_WinAPI_SetTextColor($Ps.hDC, $Data.bEnable ? $Data.iFore : 0xA0A0A0)

				If $MenuData.hItemCur == $hWnd And $MenuData.bTabMode Then
					$hBrush = _WinAPI_CreateSolidBrush(0xD77800)
					$Rct.w = 3
					_WinAPI_FillRect($Ps.hDC, $Rct, $hBrush)
				EndIf

				_WinAPI_SelectObject($Ps.hDC, $MenuData.hFont)
				If $Data.sText Then __TextOut($Ps.hDC, $MenuData.iSize + 5, $MenuData.iSize/2-12, $Data.sText)

			__EndPaint($hWnd, $Ps)
			_WinAPI_DeleteObject($hBrush)

		Case 0x0202
			If $MenuData.bTabMode Then
				__InvalidRect($MenuData.hItemCur)
				$MenuData.hItemCur = $hWnd
			EndIf
			If $MenuData.bExpanded Then	Wi3SMenu_Slide($Data.hMenu)

			DllCall("user32.dll", "bool", "ReleaseCapture")
			$Data.bDown = False
			__InvalidRect($hWnd)

			Sleep(10)
			If $Data.sEvent Then Call($Data.sEvent, $hWnd)

			Return 0

		Case 0x0201
			DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $hWnd)
			$Data.bDown = True
			__InvalidRect($hWnd)
			Return 0

		Case 0x0200
			If $Data.bHover Then Return
			$Data.bHover = True
			If $Data.hTimer = 0 Then $Data.hTimer = __SetTimer($hWnd, $__idMenuItemTimer, 10, Null)
			If $Data.bDown Then
				If __IsMouseOver($hWnd) Then
					$Data.bDown = True
				Else
					DllCall("user32.dll", "bool", "ReleaseCapture")
					$Data.bDown = False
				EndIf
			EndIf
			__InvalidRect($hWnd)

		Case 0x0113
			If __IsMouseOver($hWnd) = False Then
				__KillTimer($hWnd, $__idMenuItemTimer)
				$Data.hTimer = 0
				$Data.bHover = False
				__InvalidRect($hWnd)
			EndIf
	EndSwitch

	Return __CallWndProc($Data.hProc, $hWnd, $uMsg, $wParam, $lParam)
EndFunc

Func __Wi3SMenu__WMSIZE($hWnd, $iMsg, $wParam, $lParam)
	Local $hWndMenu = ControlGetHandle($hWnd, '', '[CLASS:Wi3.SMenu]')
	If $iMsg = 0x0005 Then _WinAPI_ShowWindow($hWndMenu, $wParam = 1 ? 0 : 5)
	Local $aPos = WinGetClientSize($hWnd)
	If @error Then Return 0
	WinMove($hWndMenu, '', 0, 0, Default, $aPos[1])
EndFunc

Func __Wi3SMenu__SlideProc($hWnd, $uMsg, $iTimerID, $iTime)
	Local $Data = DllStructCreate($tagWi3SMenuType, _WinAPI_GetWindowLong($hWnd, -21))
	Local $Rect = DllStructCreate('int x;int y;int w;int h')
	DllCall('user32.dll', 'bool', 'GetClientRect', 'hwnd', $Data.hParent, 'struct*', $Rect)

	If $Data.bExpanded Then
		If $Data.iMoved <= $Data.iSize Then
			__KillTimer($hWnd, $__idMenuSlideTimer)
			$Data.iMoved = $Data.iSize
			$Data.bExpanded = False
			__InvalidRect($Data.hBtn)
			Return 0
		EndIf
		$Data.iMoved -= 10
		_WinAPI_SetWindowPos($hWnd, 0, 0, 0, $Data.iMoved, $Rect.h, 0x10)
	Else
		If $Data.iMoved >= $Data.iMaxW Then
			__KillTimer($hWnd, $__idMenuSlideTimer)
			$Data.iMoved = $Data.iMaxW
			$Data.bExpanded = True
			__InvalidRect($Data.hBtn)
			Return 0
		EndIf
		$Data.iMoved += 10
		_WinAPI_SetWindowPos($hWnd, 0, 0, 0, $Data.iMoved, $Rect.h, 0x10)
	EndIf
EndFunc

Func __Wi3SMenu__Regiser()
	Local $aSzClass = ['Wi3.SMenu', 'Wi3.SMenu.Button', 'Wi3.SMenu.Item']
	For $i = 0 to 2
		__RegClassCopy('Static', $aszClass[$i], $i = 0 ? 32512 : 32649)
	Next
	Return 1
EndFunc

; ================================================
Func __AdjustBright($iColor, $iAjust)
	Local $Red, $Green, $Blue
	$Red = BitAND(BitShift($iColor, 16), 0xFF) + $iAjust
	$Green = BitAND(BitShift($iColor, 8), 0xFF) + $iAjust
	$Blue = BitAND($iColor, 0xFF) + $iAjust
	Return Int("0x" & Hex(__LimitColor($Red), 2) & Hex(__LimitColor($Green), 2) & Hex(__LimitColor($Blue), 2))
EndFunc

Func __LimitColor($iColor)
	If $iColor > 255 Then Return 255
	If $iColor < 0 Then Return 0
	Return $iColor
EndFunc

Func __IsMouseOver($hWnd)
	Local $Rct = DllStructCreate('int;int;int;int')
	Local $Pt = DllStructCreate('int;int')
	DllCall('user32.dll', 'bool', 'GetCursorPos', 'struct*', $Pt)

	Local $bHFP = DllCall('user32.dll', 'hwnd', 'WindowFromPoint', 'struct', $Pt)
	If @error Then Return 0
	If $bHFP[0] <> $hWnd Then Return 0

	DllCall('user32.dll', 'bool', 'GetWindowRect', 'hwnd', $hWnd, 'struct*', $Rct)
	Local $aRet = DllCall('user32.dll', 'bool', 'PtInRect', 'struct*', $Rct, 'struct', $Pt)
	If @error Then Return 0
	Return $aRet[0]
EndFunc

Func __RegClassCopy($sClassCopy, $sClassName, $idCursor = 32512)
	Local $WC = DllStructCreate('UINT style;PTR lpfnWndProc;int cbClsExtra;int cbWndExtra;handle hInstance;handle hIcon;handle hCursor;handle hbrBackground;PTR lpszMenuName;PTR lpszClassName')
	Local $hCursor = DllCall("user32.dll", "hwnd", "LoadCursor", "handle", 0, "int", $idCursor)[0]
	Local $Class = DllStructCreate("wchar szClassname["& StringLen($sClassName)+1 &"]")
	Local $hInstance = DllCall("kernel32.dll", "handle", "GetModuleHandleW", "ptr", Null)[0]

	DllCall('user32.dll', 'bool', 'GetClassInfoW', 'handle', $hInstance, 'wstr', $sClassCopy, 'ptr', DllStructGetPtr($WC))

    $Class.szClassname = $sClassName
	$WC.style = Null
    $WC.hInstance = Null
    $WC.hCursor = $hCursor
    $WC.lpszClassName = DllStructGetPtr($Class, 1)

    DllCall("user32.dll", "dword", "RegisterClassW", "ptr", DllStructGetPtr($WC))
EndFunc

Func __InvalidRect($hWnd, $tRECT = Null, $bErase = 0)
	DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hWnd, "struct*", $tRECT, "bool", $bErase)
EndFunc

Func __PtInRect(ByRef $tRECT, ByRef $tPoint)
	Local $aRet = DllCall("user32.dll", "bool", "PtInRect", "struct*", $tRECT, "struct", $tPoint)
	If (Not @error) Or IsArray($aRet) Then Return $aRet[0]
	Return False
EndFunc

Func __SendMsg($hWnd, $iMsg, $wParam = Null, $lParam = Null)
	Local $aRet = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)
	If @error Then Return False
	If IsArray($aRet) Then Return $aRet[0]
EndFunc

Func __SetTimer($hWnd, $iTimerID, $iElapse, $pTimerProc)
	DllCall('user32.dll', 'uint_ptr', 'SetTimer', 'hwnd', $hWnd, 'uint_ptr', $iTimerID, 'uint', $iElapse, 'struct*', $pTimerProc)
EndFunc

Func __KillTimer($hWnd, $iTimerID)
	DllCall('user32.dll', 'bool', 'KillTimer', 'hwnd', $hWnd, 'uint_ptr', $iTimerID)
EndFunc

Func __CallWndProc($hProcOld, $hWnd, $iMsg, $wParam, $lParam)
	Return DllCall("user32.dll", "lresult", "CallWindowProcW", "ptr", $hProcOld, "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)[0]
EndFunc

Func __BeginPaint($hWnd, ByRef $tPAINTSTRUCT)
	$tPAINTSTRUCT = DllStructCreate('hwnd hDC;int fErase;dword rPaint[4];int fRestore;int fIncUpdate;byte rgbReserved[32]')
	DllCall('user32.dll', 'handle', 'BeginPaint', 'hwnd', $hWnd, 'struct*', $tPAINTSTRUCT)
EndFunc

Func __EndPaint($hWnd, ByRef $tPAINTSTRUCT)
	DllCall('user32.dll', 'bool', 'EndPaint', 'hwnd', $hWnd, 'struct*', $tPAINTSTRUCT)
	$tPAINTSTRUCT = Null
EndFunc

Func __GetClientRect($hWnd, ByRef $tRect)
	DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $hWnd, "struct*", $tRect)
EndFunc

Func __TextOut($hDC, $iX, $iY, $sText, $iTextLen = Default)
	If @OSVersion = "WIN_7" Or @OSVersion = "WIN_VISTA" Then
		If $iTextLen = Default Then $iTextLen = StringLen($sText)
	Else
		If $iTextLen = Default Then $iTextLen = StringLen($sText) + 1
	EndIf
	DllCall('gdi32.dll', 'bool', 'TextOutW', 'handle', $hDC, 'int', $iX, 'int', $iY, 'wstr', $sText, 'int', $iTextLen)
EndFunc

#EndRegion#
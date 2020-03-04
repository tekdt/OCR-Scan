#include "UDF/SCNetGUI_UDF.au3"
#include "UDF/Wi3SMenu.au3"
#include <GuiRichEdit.au3>
#include <ComboConstants.au3>

Global $FilePath = ''
Opt("GUIOnEventMode", 1)
_SCN_EnableOnEventMode(True)
$Main = _SCN_CreateGUI("OCR Scan - dinhtrungtek@gmail.com", 500, 500)
GUISetBkColor(0xFFFFFF)
_SetTheme("SCNet_Light")
GUICtrlCreateTab(-10, -10, 1, 1)
$Menu = Wi3SMenu_Create($Main,150, 50, '', 0x000000, 0xFFFFFF, -1, True, True)
_SCN_CreateLabel("OCR Scan - dinhtrungtek@gmail.com", 220, 5, 400, 20)
$ADD_HOME = Wi3SMenu_AddItem($Menu,"Trang Chủ","Icons\home.ico", 24, -1, -1, 'MenuItem')
$ADD_ABOUT = Wi3SMenu_AddItem($Menu,"Giới thiệu","Icons\about.ico", 24, -1, -1, 'MenuItem')
$ADD_EXIT = Wi3SMenu_AddItem($Menu,"Thoát","Icons\exit.ico", 24, -1, -1, 'MenuItem')

$TAB_HOME = GUICtrlCreateTabItem("Trang Chủ")
$ImageFilePath = _SCN_CreateLabel("Chưa có tập tin nào được chọn", 160, 50, 200, 20)
$BrowseFile = _SCN_CreateButtonEx2("Duyệt File", 350, 45, 80, 30)
GUICtrlSetOnEvent($BrowseFile,_BrowseFile)

$VIE1 = _SCN_CreateRadio(1,"Tiếng Việt 1",160,90,150,30)
_SCN_RadioCheck(1,$VIE1)
GUICtrlSetOnEvent($VIE1,_RadioCheck)
$VIE2 = _SCN_CreateRadioEx(1,"Tiếng Việt 2",340,90,150,30)
GUICtrlSetOnEvent($VIE2,_RadioCheck)
$VIE3 = _SCN_CreateRadio(1,"Tiếng Việt 3",160,120,150,30)
GUICtrlSetOnEvent($VIE3,_RadioCheck)
$ENG = _SCN_CreateRadioEx(1,"Tiếng Anh",340,120,150,30)
GUICtrlSetOnEvent($ENG,_RadioCheck)
$ORTHER = _SCN_CreateRadioEx(1,"Ngôn ngữ khác",160,150,140,30)
GUICtrlSetOnEvent($ORTHER,_RadioCheck)

$SELECTORTHERLANGUAGE = GUICtrlCreateCombo("",300,154,190,30,BitOR($GUI_SS_DEFAULT_COMBO,$CBS_SIMPLE))
GUICtrlSetData(-1,"-------|afr (Afrikaans)|amh (Amharic)|ara (Arabic)|asm (Assamese)|aze (Azerbaijani)|aze_cyrl (Azerbaijani - Cyrilic)|bel (Belarusian)|ben (Bengali)|bod (Tibetan)|bos (Bosnian)|bre (Breton)|bul (Bulgarian)|cat (Catalan; Valencian)|ceb (Cebuano)|ces (Czech)|chi_sim (Chinese simplified)|chi_tra (Chinese traditional)|chr (Cherokee)|cym (Welsh)|dan (Danish)|deu (German)|dzo (Dzongkha)|ell (Greek, Modern, 1453-)|enm (English, Middle, 1100-1500)|epo (Esperanto)|equ (Math / equation detection module)|est (Estonian)|eus (Basque)|fas (Persian)|fin (Finnish)|fra (French)|frk (Frankish)|frm (French, Middle, ca.1400-1600)|gle (Irish)|glg (Galician)|grc (Greek, Ancient, to 1453)|guj (Gujarati)|hat (Haitian; Haitian Creole)|heb (Hebrew)|hin (Hindi)|hrv (Croatian)|hun (Hungarian)|iku (Inuktitut)|ind (Indonesian)|isl (Icelandic)|ita (Italian)|ita_old (Italian - Old)|jav (Javanese)|jpn (Japanese)|kan (Kannada)|kat (Georgian)|kat_old (Georgian - Old)|kaz (Kazakh)|khm (Central Khmer)|kir (Kirghiz; Kyrgyz)|kmr (Kurdish Kurmanji)|kor (Korean)|kor_vert (Korean vertical)|kur (Kurdish)|lao (Lao)|lat (Latin)|lav (Latvian)|lit (Lithuanian)|ltz (Luxembourgish)|mal (Malayalam)|mar (Marathi)|mkd (Macedonian)|mlt (Maltese)|mon (Mongolian)|mri (Maori)|msa (Malay)|mya (Burmese)|nep (Nepali)|nld (Dutch; Flemish)|nor (Norwegian)|oci (Occitan post 1500)|ori (Oriya)|osd (Orientation and script detection module)|pan (Panjabi; Punjabi)|pol (Polish)|por (Portuguese)|pus (Pushto; Pashto)|que (Quechua)|ron (Romanian; Moldavian; Moldovan)|rus (Russian)|san (Sanskrit)|sin (Sinhala; Sinhalese)|slk (Slovak)|slv (Slovenian)|snd (Sindhi)|spa (Spanish; Castilian)|spa_old (Spanish; Castilian - Old)|sqi (Albanian)|srp (Serbian)|srp_latn (Serbian - Latin)|sun (Sundanese)|swa (Swahili)|swe (Swedish)|syr (Syriac)|tam (Tamil)|tat (Tatar)|tel (Telugu)|tgk (Tajik)|tgl (Tagalog)|tha (Thai)|tir (Tigrinya)|ton (Tonga)|tur (Turkish)|uig (Uighur; Uyghur)|ukr (Ukrainian)|urd (Urdu)|uzb (Uzbek)|uzb_cyrl (Uzbek - Cyrilic)|yid (Yiddish)|yor (Yoruba)")
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetState(-1,128)

$Result = _SCN_CreateInput("", 160,190,330,260, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
$Start = _SCN_CreateButtonEx2("OCR Start", 160, 460, 90, 30)
GUICtrlSetOnEvent($Start,_Start)

$TAB_ABOUT = GUICtrlCreateTabItem("Giới thiệu")
_SCN_CreateInput("OCR Scan được viết bởi Nguyễn Đình Trung"&@CRLF&@CRLF&"Là phần mềm hỗ trợ quét các loại tập tin định dạng ảnh sang ký tự có thể chỉnh sửa."&@CRLF&"Phần mềm sử dụng thư viện Tesseract 5.0 của Google theo giấy phép mã nguồn mở."&@CRLF&@CRLF&"Mọi thông tin về phần mềm này vui lòng liên hệ Email: dinhtrungtek@gmail.com.",160, 50, 330, 400, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))

Wi3SMenu_ClickItem($ADD_HOME)
GUISetState(@SW_SHOW)
While 1
	Sleep(100)
WEnd

Func MenuItem($hMenuItem)
	Switch $hMenuItem
		Case $ADD_HOME
			GUICtrlSetState($TAB_HOME, 16)
			Wi3SMenu_EnableItem($ADD_HOME,False)
			Wi3SMenu_EnableItem($ADD_ABOUT,True)
		Case $ADD_ABOUT
			GUICtrlSetState($TAB_ABOUT, 16)
			Wi3SMenu_EnableItem($ADD_ABOUT,False)
			Wi3SMenu_EnableItem($ADD_HOME,True)
		Case $ADD_EXIT
			Exit
	EndSwitch
	Return 1
EndFunc

Func _BrowseFile()
	$FilePath = FileOpenDialog("Chọn tập tin cần OCR",@Scriptdir,"Tập tin hỗ trợ (*.JPEG;*.PNG;*.JPG)")
	GUICtrlSetData($ImageFilePath,'Chưa có tập tin nào được chọn')
	If NOT @Error Then
		GUICtrlSetData($ImageFilePath,StringSplit($FilePath,"\")[UBound(StringSplit($FilePath,"\"))-1])
	EndIf
EndFunc

Func _Start()
	GUICtrlSetData($Result,"")
	If $FilePath = '' Then
		_GUIDisable($Main, 0, 30)
		_SCN_MsgBox(16,'Chú ý!!!',"Bạn chưa chọn tập tin ảnh nào để OCR, vui lòng nhấn vào nút 'Duyệt File' và chọn tập tin cần OCR.",500,10,$Main)
		_GUIDisable($Main)
		Return 1
	EndIf
	If _SCN_RadioIsChecked(1,$ENG) = True Then
		GUICtrlSetData($Result,"Đang phân tích, vui lòng đợi...")
		RunWait('"'&@Scriptdir&'\Tesseract\tesseract.exe" --tessdata-dir "'&@Scriptdir&'\Tesseract\tessdata" "'&$FilePath&'" "'&@Scriptdir&'\result" -l eng',@ScriptDir,@SW_HIDE)
	ElseIf _SCN_RadioIsChecked(1,$VIE1) = True Then
		GUICtrlSetData($Result,"Đang phân tích, vui lòng đợi...")
		RunWait('"'&@Scriptdir&'\Tesseract\tesseract.exe" --tessdata-dir "'&@Scriptdir&'\Tesseract\tessdata" "'&$FilePath&'" "'&@Scriptdir&'\result" -l vie1',@ScriptDir,@SW_HIDE)
	ElseIf _SCN_RadioIsChecked(1,$VIE2) = True Then
		GUICtrlSetData($Result,"Đang phân tích, vui lòng đợi...")
		RunWait('"'&@Scriptdir&'\Tesseract\tesseract.exe" --tessdata-dir "'&@Scriptdir&'\Tesseract\tessdata" "'&$FilePath&'" "'&@Scriptdir&'\result" -l vie2',@ScriptDir,@SW_HIDE)
	ElseIf _SCN_RadioIsChecked(1,$VIE3) = True Then
		GUICtrlSetData($Result,"Đang phân tích, vui lòng đợi...")
		RunWait('"'&@Scriptdir&'\Tesseract\tesseract.exe" --tessdata-dir "'&@Scriptdir&'\Tesseract\tessdata" "'&$FilePath&'" "'&@Scriptdir&'\result" -l vie3',@ScriptDir,@SW_HIDE)
	ElseIf _SCN_RadioIsChecked(1,$ORTHER) = True Then
		If GUICtrlRead($SELECTORTHERLANGUAGE) = '' OR GUICtrlRead($SELECTORTHERLANGUAGE) = "-------" Then
			_GUIDisable($Main, 0, 30)
			_SCN_MsgBox(16,'Chú ý!!!',"Bạn chưa chọn ngôn ngữ để OCR, vui lòng chọn lại từ danh sách sổ xuống",500,10,$Main)
			_GUIDisable($Main)
			Return 1
		EndIf
		GUICtrlSetData($Result,"Đang phân tích, vui lòng đợi...")
		$Lang = StringSplit(GUICtrlRead($SELECTORTHERLANGUAGE),' ')[1]
		RunWait('"'&@Scriptdir&'\Tesseract\tesseract.exe" --tessdata-dir "'&@Scriptdir&'\Tesseract\tessdata" "'&$FilePath&'" "'&@Scriptdir&'\result" -l '&$Lang,@ScriptDir,@SW_HIDE)
	Else
		_GUIDisable($Main, 0, 30)
		_SCN_MsgBox(16,'Chú ý!!!',"Bạn chưa chọn ngôn ngữ để OCR, vui lòng kiểm tra lại",500,10,$Main)
		_GUIDisable($Main)
		Return 1
	EndIf
	GUICtrlSetData($Result,FileRead(@Scriptdir&'\result.txt'))
	Return 1
EndFunc

Func _RadioCheck()
	_SCN_RadioCheck(1,@GUI_CtrlID)
	If _SCN_RadioIsChecked(1,$ORTHER) = True Then
		GUICtrlSetState($SELECTORTHERLANGUAGE,64)
	Else
		GUICtrlSetState($SELECTORTHERLANGUAGE,128)
	EndIf
EndFunc
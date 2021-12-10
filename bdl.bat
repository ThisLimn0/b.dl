@ECHO OFF & SETLOCAL EnableDelayedExpansion
TITLE b.dl [stat:INIT] - Initialisation...
MODE 120,31
COLOR 1B


:::   _/                 _/                  _/     _/
:::    _/               _/_/_/          _/_/_/     _/
:::     _/             _/    _/      _/    _/     _/
:::   _/              _/    _/      _/    _/ _/_/_/
:::_/    _/_/_/_/    _/_/_/    _/    _/_/_/   _/_/_/_/_/
:::                                            _/
:::    /// ::::: /// :[b.dl]: /// ::::: /// :::
:::      A pure batch download manager script
:::      only using the given windows utils.
:::      Many fallback options are available.
:::
:::        ·   ·▐ ▄ ▄▄▄ .▄▄▄  ·▄▄▄▄▪  ·  ▪
:::          · •█▌▐█▀▄.▀·▀▄ █·██▪ ██   .
:::        ▪   ▐█▐▐▌▐▀▀▪▄▐▀▀▄ ▐█· ▐█▌   ▪
:::         · ▪██▐█▌▐█▄▄▌▐█•█▌██. ██ .   .
:::        ▪   ▀▀ █▪ ▀▀▀ .▀  ▀▀▀▀▀▀•  ▪
:::        ▄▄▄  ▄▄▄ . ▌ ▐·  .   ▄▄▌ ▐▄▄▄▄▌
:::        ▀▄ █·▀▄.▀·▪█·█▌▪     ██•  •██
:::        ▐▀▀▄ ▐▀▀▪▄▐█▐█• ▄█▀▄ ██▪   ▐█.▪
:::        ▐█•█▌▐█▄▄▌ ███ ▐█▌.▐▌▐█▌▐▌ ▐█▌·
:::        .▀  ▀ ▀▀▀ . ▀   ▀█▄▀▪.▀▀▀  ▀▀▀
:::        (ccc)2020 by Limn0 @ NerdRevolt
:::
:::    /// ::: /// ::: /// ::: /// ::: /// :::


SET "VER=0.5.0"
SET "VERSION=0.5.0-211210"


IF /I "%~1"=="PopOut" (
	SETLOCAL EnableDelayedExpansion
	ECHO.Starting up...
	SET "BitsAdminSession=%~2"
	SET "FilenameInTitle= // %~5"
	TITLE b.dl -[!BitsAdminSession!]- Download PopOut!FilenameInTitle!
	SET "RemoteURL=%~3"
	SET "LocalURL=%~4"
	MODE 70,8
	COLOR 1B
	CALL :BitsadminDownload "!BitsAdminSession!" "!RemoteURL!" "!LocalURL!"
	TIMEOUT /T 2 >NUL
	EXIT
)


IF /I "%~1"=="QuickDownload" (
	SET "ParametricDownloadLink=%~2"
	ECHO.!ParametricDownloadLink!
	PAUSE >NUL
	SET "ParametricDownloadSwitch=EXIT"
)

:MAIN
CLS


::USER:SETTINGS:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: /// ::: /// ::: /// ::: /// ::: /// :::/// ::: /// ::: /// ::: /// ::: /// :::/// ::: /// :::
SET "CL_MakeMode=0"				 ::: Special mode for development of realms and modules	1/on 0/off
SET "CL_DisplayCodebase=1"		 ::: Display codebase versions in the title				1/on 0/off
SET "CL_DisplayHeader=1"		 ::: Display header										1/on 0/off
SET "CL_ForgetUserInput=1"		 ::: Reset user input after download					1/on 0/off
SET "CL_DupeDetectLogging=1"	 ::: Log session for duplicate detection				1/on 0/off
SET "CL_ThirdPartyDownloader=yt-dlp.exe" ::: Third party command line downloader tool filename
SET "CL_ThirdPartyDownloaderName=yt-dlp" ::: Name of the third party tool for UI reasons
SET "DS_ThirdPartyDownloaderDownloadGithub=https://github.com/yt-dlp/yt-dlp/releases/download/2021.12.01/yt-dlp.exe"
SET "DS_ThirdPartyDownloaderDownloadGithubAlternateVersion=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
:::: /// ::: /// ::: /// ::: /// ::: /// :::/// ::: /// ::: /// ::: /// ::: /// :::/// ::: /// :::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


REM ///Supported services/////////
SET "Modules1=eroxia xvideos xnxx direct_download"
SET "Modules2="
SET "Modules3="
SET "Modules4="
SET "Modules5="
REM //////////////////////////////

REM ///Websites with dash-video can't be handeled with batch./////////
SET "Redlist=pornhub youporn zdf nrk"
REM //////////////////////////////////////////////////////////////////

REM CALL :StatusViaTitle test EnclosureA test test /// TODO Finish this module
IF NOT DEFINED FirstStart CALL :InitVars
IF NOT DEFINED FirstStart CALL :DoesWorkspaceExist
IF DEFINED FirstStart CALL :GenerateSessionToken
IF NOT "!CL_DisplayHeader!"=="0" CALL :SplishSplashSplosh
CALL :UserInput
:TryAgain
CALL :SanitiseUserInput
CALL :AnalyseInput
CALL :IsServiceSupported
CALL :BuildURL
CALL :IsServiceOnRedlist
ECHO.-[InfoLine]- Service:[!ServiceName!] IsServiceSupported:!ServiceSupported2! URL:!BuiltURL!
IF DEFINED ServiceSupported (
	CALL :FindRealm
)
IF "!ServiceSupported2!"=="true" (
	CALL :FindRealm
)
REM IF !ServiceSupported! EQU 1 CALL :FileCheck DownloadTry1
CALL :ThirdPartyDownloaderFallback
REM CALL :FileCheck DownloadTry2
TIMEOUT /T 1 >NUL
GOTO :MAIN


::: /// :[MAIN END]: /// :::


:InitVars
SET "FirstStart=1"
REM FOR /L %%A in (1,1,5) DO (
REM   IF DEFINED Modules%%A SET "SupportedServices=!SupportedServices! !Modules%%A!"
REM )
SET "SupportedServices=!Modules1!!Modules2!!Modules3!!Modules4!!Modules5!"
IF NOT DEFINED SupportedServices (
    ECHO.No services are currently supported. Maybe code some for yourself. Or nag the devs.
    SET "SupportedServices=."
)
SET "REMF="
SET "UsableLines=30"
SET "SELF=%~dp0"
SET "SELFEXT=%~dpnx0"
SET "SELFDropFolder=!SELF!Downloads\"
SET "SELFDropTemp=!SELFDropFolder!Temp\"
SET "ThirdPartyDownload=!SELFDropFolder!Temp\!CL_ThirdPartyDownloader!"
CALL :DoesWorkspaceExist
IF EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
	FOR /F "usebackq tokens=*" %%A IN (`!SELFDropTemp!!CL_ThirdPartyDownloader! --version`) DO (
  	SET "ThirdPartyDownloaderInitVer=%%A"
	)
) ELSE (
	SET "ThirdPartyDownloaderInitVer=unknown"
)
IF NOT !CL_MakeMode! EQU 0 (
	GOTO :MakeModeInit
)
EXIT /B


:MakeModeInit
REM // Alternate Path for development reasons.
SET "BdlSessionToken=MKMD"
SET "ZZZ=0"
SET "MakeModeInterrupt=MakeMode activated^!"
CALL :DoesWorkspaceExist
IF NOT CALL :SplishSplashSplosh
CALL :UserInput
SET "REMF=REM "
CALL :SanitiseUserInput
CALL :AnalyseInput
CALL :BuildURL
ECHO.
ECHO.::: URLDepthLevel and Dissection
ECHO.:::
ECHO.::: http: // www . example . com / page . php?parameter=loremipsum
ECHO.:::   0   ^|           1          ^|            2                    [URLDepthLevel]
ECHO.:::       ^|   0  ^|    1    ^|  2  ^|  0   ^|          1             ^| [Dissection:Delimiter{.}]
ECHO.Delimiter 1: / ^| Delimiter 2: . ^| Custom Identifier: !CustomIdentifier! ^| URL Depth Level: !URLDepthLevel!
ECHO.Service Name: !ServiceName!
ECHO.
ECHO.--[URLDepthLevel_and_Dissection]-----
FOR /L %%A IN (0,1,8) DO (
	SET /A UX2=%%A+1
	IF DEFINED URL%%A (
		SET "TMPY=%%A"
		ECHO.  URL%%A=		!URL%%A!
		FOR /L %%B IN (0,1,8) DO (
			SET "TMPXZ=URL!TMPY!%%BA"
		 	IF DEFINED URL!TMPY!%%BA (
				FOR %%# in (!TMPXZ!) DO (
					ECHO.     %%#=	!%%#!
				)
		 	)
		)
		IF DEFINED URL!UX2! (
			ECHO.--
		) ELSE (
			ECHO.-------
		)
	)
)
ECHO.
REM ECHO.DeBug: !VarIn! !VarOut! !%VarIn%! !%VarOut%! !Delimiter!
REM ECHO.%VarOut%1%CustomIdentifier% !%VarOut%1%CustomIdentifier%! !%VarOut%DepthLevel! !CustomIdentifier!
REM CALL :CheckWebsiteConnect /// TODO Finish this module
ECHO.End of MakeMode
ECHO.Do you want to continue to the Download Module? (y/N) -^> [:Realm_!ServiceName!]
CHOICE /C YN >NUL
IF !ERRORLEVEL! EQU 1 (
	CALL :Realm_!ServiceName!
)
IF !ERRORLEVEL! EQU 2 (
	GOTO :MAIN
)
PAUSE >NUL
GOTO :MAIN
EXIT /B


:DoesWorkspaceExist
IF NOT EXIST "!SELFDropFolder!" MKDIR "!SELFDropFolder!" >NUL
IF NOT EXIST "!SELFDropTemp!" MKDIR "!SELFDropTemp!" >NUL
IF EXIST "!SELFDropTemp!temp.html" DEL /F /Q "!SELFDropTemp!temp.html"
EXIT /B


:FileIsWrittenTo
TIMEOUT /T 7 >NUL
IF "%InputFile%"=="" ( EXIT /B )
FOR %%Z IN ("%InputFile%") DO (
	FOR /f "tokens=1,2" %%A IN ('robocopy "%%~dpZ." "%%~dpZ." "%%~nxZ" /l /nocopy /is /njh /njs /ndl /nc') DO IF "%%~dZ"=="%%~dB" (
	SET "FZ=%%A"
	SET "TY=%%B"
		IF /i NOT "!TY!"=="G" (
			IF /i NOT "!TY!"=="M" (
				SET "TY=Bytes"
			)
		)
		IF /i "!TY!"=="G" (
			SET "TY=GB"
		)
		IF /i "!TY!"=="M" (
			SET "TY=MB"
		)
	)
)
2>NUL (CALL;>>"%InputFile%") && (
  SET "Status="%InputFile%" is free^!" & CALL :FIWTUPD & GOTO :OutOfTheLoop
) || (
  SET "Status="%InputFile%" is in use or is read only^!"
)
CALL :FIWTUPD
TIMEOUT /T 2 >NUL
GOTO :FileIsWrittenTo


:FIWTUPD
CLS
ECHO.Downloading...
ECHO.!FZ! !TY!
ECHO.!Status!
EXIT /B


:OutOfTheLoop
CALL :FIWTUPD
TIMEOUT /T 3 >NUL
EXIT /B


:UserInput
IF "!CL_DisplayCodebase!"=="1" (
	SET "CL_Codebase=   ///   [bdl: !VERSION!; !CL_ThirdPartyDownloaderName!: !ThirdPartyDownloaderInitVer!]"
) ELSE (
	SET "CL_Codebase= "
)
IF "!CL_ForgetUserInput!"=="1" (
	SET "URL="
)
TITLE b.dl - Awaiting user input...!CL_Codebase!
IF DEFINED ParametricDownloadLink (
	ECHO. >!ParametricDownloadLink!
	SET "URL=!ParametricDownloadLink!"
	EXIT /B
)
SET /P "URL= >>> "
EXIT /B


:SanitiseUserInput
SET "HELPSTR=h -h /h --h hlp -hlp /hlp --hlp help -help /help --help"
SET "TESTSTR=t -t /t --t test -test /test --test test_all -test_all /test_all --test_all test_all_components -test_all_components /test_all_components --test_all_components"
SET "TESTSTRDL=td -td /td --td tdm -tdm /tdm --tdm test_download_modules -test_download_modules /test_download_modules --test_download_modules"
SET "UPDATESTR=u -u /u --u upd -upd /upd --upd update -update /update --update"
SET "MKMDSTR=m -m /m --m mkm -mkm /mkm --mkm mkmd -mkmd /mkmd --mkmd makemode -makemode /makemode --makemode"
SET "EXITSTR=q -q /q --q x -x /x --x exit -exit /exit --exit quit -quit /quit --quit"
FOR %%A IN (!EXITSTR!) DO (
    IF /i "!URL!"=="%%A" (
		ECHO.
		ECHO. Cleaning up...
		ECHO.
		ECHO.  ^>^>^> Temporary Files
		CALL :CL_CleanRoutine
		ECHO.  ^>^>^> EXITING
		TIMEOUT /T 1 >NUL
		CLS
		EXIT
	)
)
FOR %%A IN (!HELPSTR!) DO (
    IF /i "!URL!"=="%%A" (
		ECHO. b.dl - [!HELPSTR!]
		ECHO.	Usage: Put website link to download content into window.
		ECHO.	Currently Supported Services: !SupportedServices!
		ECHO.	The following services require !CL_ThirdPartyDownloaderName!: !RedList!
		ECHO.
		ECHO. Available Commands:
		ECHO.	Update !CL_ThirdPartyDownloaderName!: 			u /u -u upd -upd /upd update
		ECHO.	Test installed download modules: 	tdm /tdm -tdm test_download_modules
		ECHO.	Test all modules:			t /t -t /test -test test_all test_all_components
		ECHO.	This help document:			h /h -h /help -help --help help
		ECHO.
		ECHO. Press Any [Key] to continue.
		PAUSE >NUL
		GOTO :MAIN
		EXIT /B
	)
)
FOR %%A IN (!TESTSTR!) DO (
    IF /i "!URL!"=="%%A" (
		ECHO. b.dl - [test_all_components]
		ECHO.
		CALL :TestAllComponents
		ECHO. Press Any [Key] to continue.
		PAUSE >NUL
		GOTO :MAIN
		EXIT /B
	)
)
FOR %%A IN (!TESTSTRDL!) DO (
    IF /i "!URL!"=="%%A" (
		ECHO. b.dl - [test_download_modules]
		ECHO.
		CALL :TestDownloadModules
		ECHO. Press Any [Key] to continue.
		PAUSE >NUL
		GOTO :MAIN
		EXIT /B
	)
)
FOR %%A IN (!UPDATESTR!) DO (
    IF /i "!URL!"=="%%A" (
		IF DEFINED ThirdPartyDownloaderUpdatedVer (
			ECHO. b.dl - [update !CL_ThirdPartyDownloaderName! base]
			ECHO. 
			ECHO. You are running !CL_ThirdPartyDownloaderName! Version: !ThirdPartyDownloaderUpdatedVer!
			ECHO. !CL_ThirdPartyDownloaderName! is up to date.
			IF EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
				FOR /F "usebackq tokens=*" %%A IN (`!SELFDropTemp!!CL_ThirdPartyDownloader! --version`) DO (
			  	SET "ThirdPartyDownloaderInitVer=%%A"
				)
			) ELSE (
				SET "ThirdPartyDownloaderInitVer=unknown"
			)
			ECHO. Press Any [Key] to continue.
			TIMEOUT /T 2 >NUL
			GOTO :MAIN
		)
		IF NOT EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
			ECHO. b.dl - [update !CL_ThirdPartyDownloaderName! base]
			ECHO.
			ECHO. Can't check !CL_ThirdPartyDownloaderName! for updates if it does not exist.
			ECHO. Trying to download from repository...
			CALL :ThirdPartyDownloaderFallbackInitialStart
			CALL :CheckThirdPartyDownloaderForUpdates
			IF EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
				FOR /F "usebackq tokens=*" %%A IN (`!SELFDropTemp!!CL_ThirdPartyDownloader! --version`) DO (
			  	SET "ThirdPartyDownloaderInitVer=%%A"
				)
			) ELSE (
				SET "ThirdPartyDownloaderInitVer=unknown"
			)
			ECHO. Press Any [Key] to continue.
			TIMEOUT /T 2 >NUL
			GOTO :MAIN
			EXIT /B
		)
		ECHO. b.dl - [update !CL_ThirdPartyDownloaderName! base]
		ECHO.
		CALL :CheckThirdPartyDownloaderForUpdates
		IF EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
			FOR /F "usebackq tokens=*" %%A IN (`!SELFDropTemp!!CL_ThirdPartyDownloader! --version`) DO (
		  	SET "ThirdPartyDownloaderInitVer=%%A"
			)
		) ELSE (
			SET "ThirdPartyDownloaderInitVer=unknown"
		)
		ECHO. Press Any [Key] to continue.
		TIMEOUT /T 2 >NUL
		GOTO :MAIN
		EXIT /B
	)
)
IF /i "!URL!"=="restart" (
	FOR /L %%A IN (3,-1,1) DO (
		ECHO.Restarting in %%A...
		TIMEOUT /T 1 >NUL
	)
	START "" "!SELFEXT!"
	EXIT
)
IF "!URL!" EQU "" (
	ECHO. The URL you provided is empty. Please try again.
	PAUSE >NUL
	GOTO :MAIN
	EXIT /B
)
CALL :KillUnallowedCharacters URL URL

::: URLDepthLevel and Dissection
:::
::: http: // www . example . com / page . php?parameter=loremipsum
:::   0   |           1          |            2                    [URLDepthLevel]
:::       |   0  |    1    |  2  |  0   |          1             | [Dissection:Delimiter{.}]

REM Really bad workaround to a direct download related issue below, will fix later
SET URLDepthLevel=-1

FOR /F "tokens=1,2,3,4,5,6,7,8,9 delims=/" %%A IN ("!URL!") DO (
  SET "URL0=%%A"
  IF DEFINED URL0 (
    SET "URL1=%%B"
    SET /A URLDepthLevel+=1
    IF DEFINED URL1 (
      SET "URL2=%%C"
      SET /A URLDepthLevel+=1
      IF DEFINED URL2 (
        SET "URL3=%%D"
        SET /A URLDepthLevel+=1
        IF DEFINED URL3 (
          SET "URL4=%%E"
          SET /A URLDepthLevel+=1
          IF DEFINED URL4 (
            SET "URL5=%%F"
            SET /A URLDepthLevel+=1
            IF DEFINED URL5 (
              SET "URL6=%%G"
              SET /A URLDepthLevel+=1
              IF DEFINED URL6 (
                SET "URL7=%%H"
                SET /A URLDepthLevel+=1
                IF DEFINED URL7 (
                  SET "URL8=%%I"
                  SET /A URLDepthLevel+=1
                )
              )
            )
          )
        )
      )
    )
  )
	REM ECHO.URL0=%%A
	REM ECHO.URL1=%%B
	REM ECHO.URL2=%%C
	REM ECHO.URL3=%%D
	REM ECHO.URL4=%%E
	REM ECHO.URL5=%%F
	REM ECHO.URL6=%%G
	REM ECHO.URL7=%%H
	REM ECHO.URL8=%%I
	REM ECHO.!URL8! !URLDepthLevel!
	REM ECHO.Domain: %%B
	REM ECHO.URL1: %%C
	REM ECHO.VideoID: %%D
	REM ECHO.VideoName: %%E
)
SET "URLHasHttpCount=0"
FOR %%A IN ("http" "https") DO (
  IF "!URL0!" EQU "%%~A:" (
      SET /A URLHasHttpCount+=1
      EXIT /B
  )
)
!REMF!CALL :ResolveProblems
EXIT /B


:DissectURL
::: URLDepthLevel and Dissection
:::
::: http: // www . example . com / page . php?parameter=loremipsum
:::   0   |           1          |            2                    [URLDepthLevel]
:::       |   0  |    1    |  2  |  0   |          1             | [Dissection:Delimiter{.}]
SET "VarIn=%1"
SET "VarOut=%2"
SET "Delimiter=%3"
SET "CustomIdentifier=%4"
REM ECHO.DeBug: !VarIn! !VarOut! !%VarIn%! !%VarOut%! !Delimiter!
SET "!VarOut!DepthLevel!CustomIdentifier!=0"
FOR /F "tokens=1,2,3,4,5,6,7,8,9 delims=%Delimiter%" %%A IN ("!%VarIn%!!") DO (
  SET "!VarOut!0!CustomIdentifier!=%%A"
  IF DEFINED !VarOut!0!CustomIdentifier! (
    SET "!VarOut!1!CustomIdentifier!=%%B"
    SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
    IF DEFINED !VarOut!1!CustomIdentifier! (
      SET "!VarOut!2!CustomIdentifier!=%%C"
      SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
      IF DEFINED !VarOut!2!CustomIdentifier! (
        SET "!VarOut!3!CustomIdentifier!=%%D"
        SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
        IF DEFINED !VarOut!3!CustomIdentifier! (
          SET "!VarOut!4!CustomIdentifier!=%%E"
          SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
          IF DEFINED !VarOut!4!CustomIdentifier! (
            SET "!VarOut!5!CustomIdentifier!=%%F"
            SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
            IF DEFINED !VarOut!5!CustomIdentifier! (
              SET "!VarOut!6!CustomIdentifier!=%%G"
              SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
              IF DEFINED !VarOut!6!CustomIdentifier! (
                SET "!VarOut!7!CustomIdentifier!=%%H"
                SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
                IF DEFINED !VarOut!7!CustomIdentifier! (
                  SET "!VarOut!8!CustomIdentifier!=%%I"
                  SET /A !VarOut!DepthLevel!CustomIdentifier!+=1
                )
              )
            )
          )
        )
      )
    )
  )
  REM ECHO.DeBug: !VarIn! !VarOut! !%VarIn%! !%VarOut%! !Delimiter!
  REM ECHO.%VarOut%1%CustomIdentifier% !%VarOut%1%CustomIdentifier%! !%VarOut%DepthLevel! !CustomIdentifier!
)
EXIT /B

:TODO

:TestAllComponents
EXIT /B

:TODO

:TestDownloadModules
EXIT /B

:ColorLine
SET "CurrentLine=%~1"
FOR /F "delims=*" %%A IN ('FORFILES.EXE /P %~dp0 /M %~nx0 /C "CMD /C ECHO.!CurrentLine!"') DO ECHO.%%A
EXIT /B


:AnalyseInput
FOR /L %%A in (0,1,!URLDepthLevel!) DO (
  CALL :DissectURL URL%%A URL%%A . A
)
CALL :DissectionURLAnalysis
CALL :DetectDirectDownload
EXIT /B



:DetectDirectDownload
FOR /L %%A IN (1,1,8) DO (
	IF DEFINED URL%%A (
		IF "!URL%%A:~-4!"==".mp4" (
			SET "DDLFlag=1"
		)
	)
)
IF "!DDLFlag!"=="1" (
	ECHO.
	ECHO.DetectDDL.[!URL!]
	ECHO.
	ECHO. The provided URL might be a direct link to a file.
	ECHO. Do you want to provide an alternative filename?
	ECHO. Leave blank if not.
	ECHO.
	SET /P "TPDCustomFileName=Alternative Filename (.mp4 is automatically appended)>"
	IF NOT "!TPDCustomFileName!"=="" ( SET "TPDCustomFileName=!TPDCustomFileName!.mp4" ) ELSE ( SET "TPDCustomFileName=!URL%URLDepthLevel%!" )
	ECHO.
	GOTO :Realm_direct_download
)
EXIT /B


:KillUnallowedCharacters
SET "VarIn=%1"
SET "VarOut=%2"
SET "!VarIn!=!%VarIn%: =!"
SET "!VarIn!=!%VarIn%:&=^&!"
SET "!VarOut!=!%VarIn%!"
REM ECHO.DeBug: !VarIn! !VarOut! !%VarIn%! !%VarOut%!
EXIT /B

REM TODO Rewrite download module to feature clean design and progress bar.
:ThirdPartyDownloaderFallbackInitialStart
ECHO.Downloading !CL_ThirdPartyDownloaderName!... Try1
CALL :PowershellDownload "!DS_ThirdPartyDownloaderDownloadGithub!" "!SELFDropTemp!!CL_ThirdPartyDownloader!"
IF NOT EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
  ECHO./^^!\ There was some kind of error during the download.
  ECHO.Trying again with another version.
  IF NOT EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
    ECHO.Downloading !CL_ThirdPartyDownloaderName!... Try2
	CALL :JavascriptDownload "!DS_ThirdPartyDownloaderDownloadGithubAlternateVersion!" "!SELFDropTemp!!CL_ThirdPartyDownloader!"
    IF NOT EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
      ECHO./^^!\ There was some kind of error during the download of !CL_ThirdPartyDownloaderName!.
      ECHO.Trying again with another download method.
      ECHO.Downloading !CL_ThirdPartyDownloaderName!... Try3
      CALL :BitsadminDownload "TPDL" "!DS_ThirdPartyDownloaderDownloadGithub!" "!SELFDropTemp!!CL_ThirdPartyDownloader!"
	  IF NOT !BitsadminDLMErrorlevel! EQU 0 (
        ECHO./^^!\ There was some kind of error during the download.
        ECHO.Trying again with another version.
        ECHO.Downloading !CL_ThirdPartyDownloaderName!... Try4
        CALL :BitsadminDownload "TPDL2T" "!DS_ThirdPartyDownloaderDownloadGithubAlternateVersion!" "!SELFDropTemp!!CL_ThirdPartyDownloader!"
		IF NOT !BitsadminDLMErrorlevel! EQU 0 (
          ECHO./^^!\ There was some kind of error during the download of !CL_ThirdPartyDownloaderName!.
          ECHO.Trying again with another download method.
          ECHO.Downloading !CL_ThirdPartyDownloaderName!... Try5
          CALL :JavascriptDownload "!DS_ThirdPartyDownloaderDownloadGithub!" "!SELFDropTemp!!CL_ThirdPartyDownloader!"
          IF NOT EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
            ECHO./^^!\ There was some kind of error during the download.
            ECHO.Trying again with another version.
            ECHO.Downloading !CL_ThirdPartyDownloaderName!... Try6
            CALL :PowershellDownload "!DS_ThirdPartyDownloaderDownloadGithubAlternateVersion!" "!SELFDropTemp!!CL_ThirdPartyDownloader!"
          )
        )
      )
    )
  )
)
IF EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
	ECHO.Successfully downloaded !CL_ThirdPartyDownloaderName!.
) ELSE (
	ECHO.All download methods failed. Please obtain a copy of !CL_ThirdPartyDownloader! and put it in
	ECHO ^>^>^>!SELFDropTemp!^<^<^<
)
EXIT /B

:TODO

:HandleM3U8
EXIT /B


:ThirdPartyDownloaderFallback
ECHO./^^!\ All other download methods failed. Falling back on !CL_ThirdPartyDownloaderName!.
REM if everything else fails...
IF NOT EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!" (
  CALL :ThirdPartyDownloaderFallbackInitialStart
)
CALL :CheckThirdPartyDownloaderForUpdates
CALL :ThirdPartyDownloadAction
EXIT /B


:ThirdPartyDownloadAction
FOR /F "usebackq tokens=*" %%A IN (`!ThirdPartyDownload! --no-mark-watched --geo-bypass --get-filename !BuiltURL!`) DO (
  SET "TPDGetFilename=%%A"
  ECHO.!BuiltURL!
  ECHO.!TPDGetFilename! &PAUSE >NUL
  
)
IF NOT "!TPDCustomFileName!"=="" (
	SET "TPDGetFilename=!TPDCustomFileName!"
)
REM ECHO.!ThirdPartyDownload! --no-mark-watched --geo-bypass --write-thumbnail --no-playlist -R 42 --fragment-retries 42 !BuiltURL! -o "!SELFDropTemp!!TPDGetFilename!"
REM ECHO.!BuiltURL!
REM PAUSE
START /MIN "b.dl.!CL_ThirdPartyDownloaderName![%BdlSessionToken%] " !ThirdPartyDownload! --no-mark-watched --geo-bypass --write-thumbnail --no-playlist -R 42 --fragment-retries 42 !BuiltURL! -o "!SELFDropFolder![%%(uploader)s][!ServiceName!] !TPDGetFilename!"
SET "TPDCustomFileName="
SET "DDLFlag="
EXIT /B


:CheckThirdPartyDownloaderForUpdates
REM Only check once in a runtime for updates
IF DEFINED ThirdPartyDownloaderUpdatedVer EXIT /B
ECHO. Checking !CL_ThirdPartyDownloaderName! stub for updates...
FOR /F "usebackq tokens=*" %%A IN (`!SELFDropTemp!!CL_ThirdPartyDownloader! --version`) DO (
  SET "ThirdPartyDownloaderCurrentVer=%%A"
)
START /WAIT "!CL_ThirdPartyDownloaderName! Updater" "!SELFDropTemp!!CL_ThirdPartyDownloader!" -U
IF EXIST "!SELFDropTemp!!CL_ThirdPartyDownloader!.new" (
	DEL /F /Q "!SELFDropTemp!!CL_ThirdPartyDownloader!" >NUL
	REN "!SELFDropTemp!!CL_ThirdPartyDownloader!.new" "!CL_ThirdPartyDownloader!" >NUL
)
FOR /F "usebackq tokens=*" %%A IN (`!SELFDropTemp!!CL_ThirdPartyDownloader! --version`) DO (
  SET "ThirdPartyDownloaderUpdatedVer=%%A"
)
IF NOT "!ThirdPartyDownloaderCurrentVer!"=="!ThirdPartyDownloaderUpdatedVer!" (
  ECHO. ^>^>^> Successfully upgraded !CL_ThirdPartyDownloaderName! from !ThirdPartyDownloaderCurrentVer! to !ThirdPartyDownloaderUpdatedVer!...
) ELSE (
  ECHO. You are running !CL_ThirdPartyDownloaderName! Version: !ThirdPartyDownloaderUpdatedVer!
  ECHO. ^>^>^> !CL_ThirdPartyDownloaderName! is up to Date.
)
ECHO.
EXIT /B


:GenerateSessionToken
SET "ALPHANUMERICALS=ABCDEFGHIJKLMNOP0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
SET "BdlSessionToken="
FOR /L %%B IN (0,1,5) DO (
	SET /A RND=!RANDOM! * 62 / 32768 + 1
	FOR /F %%C IN ('ECHO.%%ALPHANUMERICALS:~!RND!^,1%%') DO SET "BdlSessionToken=!BdlSessionToken!%%C"
)
SET "BdlSessionToken=!BdlSessionToken:~0,4!"
EXIT /B


:ResolveProblems
ECHO.ResolveProblems: !URL!
IF /i "!URL0:~-2!"=="s:" (
  SET "URL0=https:"
  SET "URLHasHttpCount=1"
)
IF NOT DEFINED URL0 (
  SET "URL0=http:"
  SET "URLHasHttpCount=1"
)
IF NOT !URLHasHttpCount!==1 (
  SET "URL0=http:"
  SET "URLHasHttpCount=1"
)
IF !URLHttpWrongStandard!==1 (
  SET "URL0=https:"
)
IF !URLDepthLevel! EQU 1 (
  ECHO./^^!\ ERROR. Invalid URL.
  PAUSE >NUL
  GOTO :MAIN
)
ECHO.                 [TO]
CALL :BuildURL
ECHO.                 !BuiltURL!
EXIT /B

:TODO

:StatusViaTitle
::: b.dl - [Title1;EnclosureB;TitleStatusParameter2] {Title3;EnclosureC;TitleStatusParameter4} Title5 Title7
SET "EnclosureA=(PLACEHOLDER)"
SET "EnclosureB=[PLACEHOLDER]"
SET "EnclosureC={PLACEHOLDER}"
FOR /L %%A IN (1,1,9) DO (
  IF DEFINED TitleStatusParameter%%A SET "TitleStatusParameter%%A=%%%A" & ECHO.!TitleStatusParameter%%A!
)
FOR %%A IN (A B C) DO (
  IF "!TitleStatusParameter2!"=="Enclosure%%A" (
	FOR %%# in (!TMPXZ!) DO (
		SET "Title1=!Enclosure%%A:PLACEHOLDER=%TitleStatusParameter1%!"
		ECHO.%%#=!%%#!
	)
  )
)
TITLE b.dl - !Title1! !Title3! !Title5! !Title7!
PAUSE
EXIT /B

:FindRealm
CALL :Realm_!ServiceName!
EXIT /B

:TODO

:FileCheck
SET "ErrorlevelVarName=%1"
EXIT /B


:DissectionURLAnalysis
REM FOR /F "tokens=* delims=." %%A IN ("!URL1!!") DO (
REM  SET /A URL1AnalysisCounter+=1
REM )
IF !URLDepthLevel! EQU 2 (
  ECHO./^^!\ URL might be too short for Information.
  ECHO.The URL you provided was:
  ECHO.
  ECHO.       ^>^>^>!URL!^<^<^<
  ECHO.
  ECHO.Do you want to continue? [y/N]
  CHOICE /C YN /N >NUL
  IF NOT !ERRORLEVEL! EQU 1 (
    GOTO :MAIN
  )
)
IF !URL1DepthLevelA! EQU 4 (
  SET "ServiceName=!URL11A!"
) ELSE IF !URL1DepthLevelA! EQU 3 (
  SET "ServiceName=!URL11A!"
) ELSE IF !URL1DepthLevelA! EQU 2 (
  SET "ServiceName=!URL10A!"
) ELSE (
  SET "ServiceName=!URL11A!"
)
IF !URLDepthLevel! EQU 3 (
  IF !URL1DepthLevelA! EQU 2 (
    IF !URL2DepthLevelA! EQU 1 (
      ECHO.URL Shortener detected^!
      SET "ServiceName=!URL10A!.!URL11A!"
    )
  )
)
TITLE b.dl - Downloading from !ServiceName!!CL_Codebase!
EXIT /B


:BuildURL
REM TODO Bug: https://motherless.com/A720F3F has two IDS
SET "BuiltURL=!URL0!/"
SET "URLDepthLevel2=%URLDepthLevel%"
FOR /L %%A IN (1,1,!URLDepthLevel2!) DO (
  SET "BuiltURL=!BuiltURL!/!URL%%A!"
)
IF "!URL:~-1!"=="/" (
	SET "BuiltURL=!BuiltURL!!URL%URLDepthLevel%!/"
) ELSE (
	SET "BuiltURL=!BuiltURL!!URL%URLDepthLevel%!"
)
EXIT /B


:SplishSplashSplosh
CALL :RandomCatchphraseOfTheDay
ECHO.   _/                 _/                  _/     _/
ECHO.    _/               _/_/_/          _/_/_/     _/
ECHO.     _/             _/    _/      _/    _/     _/   "!Catchphrase%RandomBetween1And5%%ZZZ%!!MakeModeInterrupt!"
ECHO.   _/              _/    _/      _/    _/ _/_/_/
ECHO._/    _/_/_/_/    _/_/_/    _/    _/_/_/   _/_/_/_/_/
ECHO.      SessionToken: %BdlSessionToken% /// !VER!          _/
EXIT /B


:RandomCatchphraseOfTheDay
SET /A RandomBetween1And5=%RANDOM% %% 5 + 1
SET "Catchphrase1=42"
SET "Catchphrase2=Not faster than your mouse."
SET "Catchphrase3=1...2...3... test?"
SET "Catchphrase4=OK MOM, I'M DOWNLOADING^!^!^!"
SET "Catchphrase5=Damn you, dynamic webistes."
EXIT /B


:IsServiceSupported
FOR %%A IN (!SupportedServices!) DO (
  IF /I "%%A"=="!ServiceName!" (
    CALL :CodeCheck
    SET "ServiceSupported2=true"
    ECHO.Service seems to be supported.
	EXIT /B
  ) ELSE (
    SET "ServiceSupported2=false"
  )
)
EXIT /B


:IsServiceOnRedlist
FOR %%A IN (!RedList!) DO (
  IF  "%%A"=="!ServiceName!" (
    ECHO.We won't even bother downloading this the normal way...
    CALL :ThirdPartyDownloaderFallback
    TIMEOUT /T 1 >NUL
    GOTO :MAIN
  )
)
EXIT /B

:TODO

:CodeCheck
EXIT /B

:CL_CleanRoutine
PUSHD
CHDIR !SELFDropTemp!
FOR %%I in (*) DO (
	IF /i NOT "%%~I"=="!CL_ThirdPartyDownloader!" (
		IF /i NOT "%%~I"=="dl.js" (
			DEL /F /Q "%%~I"
		)
	)
)
POPD
EXIT /B

::: /// :[SUBROUTINE END]: /// :::


:BitsadminDownload
SET "BitsadminDLMSessionHandle=%~1"
SET "BitsadminDLMRemotePath=%~2"
SET "BitsadminDLMLocalPath=%~3"
bitsadmin /transfer b.dl-!BitsadminDLMSessionHandle!!BdlSessionToken! /priority HIGH "!BitsadminDLMRemotePath!" "!BitsadminDLMLocalPath!"
SET "BitsadminDLMErrorlevel=!ERRORLEVEL!"
EXIT /B

:PowershellDownload
SET "PowershellDLMRemotePath=%~1"
SET "PowershellDLMLocalPath=%~2"
powershell -command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;(New-Object System.Net.WebClient).DownloadFile('!PowershellDLMRemotePath!','!PowershellDLMLocalPath!')" >NUL
EXIT /B

:JavascriptDownload
SET "JavascriptDLMRemotePath=%~1"
SET "JavascriptDLMLocalPath=%~2"
IF NOT EXIST "!SELFDropTemp!\dl.js" CALL :DropDownloadJS
cscript //NoLogo //e:Jscript "!SELFDropTemp!\dl.js" "!JavascriptDLMRemotePath!" "!JavascriptDLMLocalPath!" >NUL
EXIT /B

:DropDownloadJS
ECHO ////BgetVersion 0.1.1 by Jahwi>"!SELFDropTemp!\dl.js"
ECHO  var url = WScript.Arguments(0),>>"!SELFDropTemp!\dl.js"
ECHO    filename = WScript.Arguments(1),>>"!SELFDropTemp!\dl.js"
ECHO    fso = WScript.CreateObject('Scripting.FileSystemObject'),>>"!SELFDropTemp!\dl.js"
ECHO    request, stream;>>"!SELFDropTemp!\dl.js"
ECHO  if (fso.FileExists(filename)) {>>"!SELFDropTemp!\dl.js"
ECHO    WScript.Echo('Already got ' + filename);>>"!SELFDropTemp!\dl.js"
ECHO  } else {>>"!SELFDropTemp!\dl.js"
ECHO    request = WScript.CreateObject('MSXML2.ServerXMLHTTP');>>"!SELFDropTemp!\dl.js"
ECHO    request.open('GET', url, false); // not async>>"!SELFDropTemp!\dl.js"
ECHO    request.send();>>"!SELFDropTemp!\dl.js"
ECHO    if (request.status === 200) { // OK>>"!SELFDropTemp!\dl.js"
ECHO      WScript.Echo("Size: " + request.getResponseHeader("Content-Length") + " bytes");>>"!SELFDropTemp!\dl.js"
ECHO      stream = WScript.CreateObject('ADODB.Stream');>>"!SELFDropTemp!\dl.js"
ECHO      stream.Open();>>"!SELFDropTemp!\dl.js"
ECHO      stream.Type = 1; // adTypeBinary>>"!SELFDropTemp!\dl.js"
ECHO      stream.Write(request.responseBody);>>"!SELFDropTemp!\dl.js"
ECHO      stream.Position = 0; // rewind>>"!SELFDropTemp!\dl.js"
ECHO      stream.SaveToFile(filename, 1); // adSaveCreateNotExist>>"!SELFDropTemp!\dl.js"
ECHO      stream.Close();>>"!SELFDropTemp!\dl.js"
ECHO    } else {>>"!SELFDropTemp!\dl.js"
ECHO      WScript.Echo('Failed');>>"!SELFDropTemp!\dl.js"
ECHO      WScript.Quit(1);>>"!SELFDropTemp!\dl.js"
ECHO    }>>"!SELFDropTemp!\dl.js"
ECHO  }>>"!SELFDropTemp!\dl.js"
ECHO  WScript.Quit(0);>>"!SELFDropTemp!\dl.js"
EXIT /B


::: /// :[DOWNLOAD METHODS END]: /// :::


:Realm_
SET "CurrentRealm=error"
ECHO.[!CurrentRealm!] Realm unknown.
ECHO.
ECHO.Something went wrong^^!
ECHO.This download module and/or service push is failing.
PAUSE >NUL
GOTO :MAIN
EXIT /B


::: ---

:TODO


:Realm_0_VariableBugCheck
FOR /L %%A in (1,1,9) DO SET SET "BugCheckArgument%%A=%~%%A"
EXIT /B

:Realm_0_VariableBugCheck_IsExpected
::: ---

:TODO


:Realm_1_FunctionBugCheck
FOR /L %%A in (1,1,9) DO SET SET "BugCheckArgument%%A=%~%%A"
EXIT /B


::: ---
:Realm_direct_download
SET "CurrentRealm=ddl"
TITLE b.dl - Downloading directly from !ServiceName!
SET "CL_Codebase=30-12-2020"
IF EXIST "!SELFDropFolder![NA] [!ServiceName!]!TPDCustomFileName!" (
	ECHO.An identical file already exists. Stopped downloading.
	ECHO.Returning in 5 seconds...
	SET "TPDCustomFileName="
	SET "DDLFlag="
	TIMEOUT /T 5 >NUL
	GOTO :MAIN
)
START "" %~dpnx0 "PopOut" "DDLMAN" "!URL!" "!SELFDropFolder![NA] [!ServiceName!]!TPDCustomFileName!" "!TPDCustomFileName!"
ECHO.The video will be queued and downloaded in the background. Check back later.
ECHO.Returning...
SET "TPDCustomFileName="
SET "DDLFlag="
TIMEOUT /T 3 >NUL
!ParametricDownloadSwitch!
GOTO :MAIN
EXIT /B

:Realm_eroxia
SET "CurrentRealm=eroxia"
TITLE b.dl - Downloading from eroxia!CL_Codebase!
REM // https://www.eroxia.com/video/xxx-xxxxxxx-xxxxxxxx-xxx-xxx-xxx-xxx-xxx-xxxxx-nnnnnn.html
REM // https://www.eroxia.com/embed/nnnnnn
REM Check if link is already embed, then skip to downloading since video clear link is on embed page
IF EXIST "!SELFDropTemp!temp.mp4" (
	DEL /F /Q "!SELFDropTemp!temp.mp4" >NUL
)
IF EXIST "!SELFDropTemp!temp.html" (
	DEL /F /Q "!SELFDropTemp!temp.html" >NUL
)
IF "!URL2!"=="embed" (
	ECHO.[!CurrentRealm!] Link type: [!URL2!]
	SET "EmbedURL=!BuiltURL!"
	SET "FileName=EROXIA-!URL3!"
	GOTO :eroxia_DL_Webpage
)
IF "!URL10A!"=="media" (
	ECHO.[!CurrentRealm!] Link type: [direct]
	SET "DownloadURL=!BuiltURL!"
	SET /A X=URLDepthLevel-1
	SET "FileName=!URL%X%!"
	GOTO :eroxia_Download
)
REM Get video code
ECHO.[!CurrentRealm!] Link type: [video]
SET A=1
FOR /L %%A IN (1,1,100) DO (
	IF "!URL3:~%%A,1!"=="-" (
		SET /A A+=1
	)
)
FOR /F "tokens=%A%* delims=-+." %%A IN ("!URL3!") DO (
	SET "VideoID=%%A"
)
IF DEFINED VideoID (
	ECHO.[!CurrentRealm!] Got VideoID.
)
SET "EmbedURL=https://www.eroxia.com/embed/!VideoID!"
:eroxia_DL_Webpage
SET "CurrentRealm=eroxia"
ECHO.[!CurrentRealm!] Downloading webpage...
CALL :JavascriptDownload "!EmbedURL!" "!SELFDropTemp!temp.html"
ECHO.[!CurrentRealm!] Parsing webpage...
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "video/mp4" ') DO (
	SET "SourceLine=%%A"
)
ECHO.[!CurrentRealm!] Getting download URL...
SET "SourceLine=!SourceLine:~13!"
SET "DownloadURL=!SourceLine:~0,-19!"
SET "FileName=!URL3:~0,-5!"
IF !CL_MakeMode! EQU 1 (
	REM ECHO.!VideoTitle!
	REM ECHO.!SourceLineLow!
	ECHO.[!CurrentRealm!] !DownloadURL!
	REM ECHO.!UploaderID!
	REM ECHO.!ThumbnailMosaique!
	REM ECHO.!Thumbnail!
	PAUSE >NUL
)
:eroxia_Download
SET "CurrentRealm=eroxia"
ECHO.[!CurrentRealm!] Starting download...
START /WAIT "" %~dpnx0 "PopOut" "EOAMFDL" "!DownloadURL!" "!SELFDropTemp!temp.mp4"
TIMEOUT /T 3 >NUL
ECHO.
ECHO.Renaming temp.mp4
RENAME "!SELFDropTemp!temp.mp4" "!FileName!.mp4" >NUL
ECHO.                  --^>
ECHO.                       !FileName!.mp4
ECHO.
ECHO.Moving file to !SELFDropFolder!.
MOVE "!SELFDropTemp!!FileName!.mp4" "!SELFDropFolder!" >NUL
ECHO.[!CurrentRealm!] Download finished.
TIMEOUT /T 5 >NUL
!ParametricDownloadSwitch!
GOTO :MAIN
EXIT /B


::: ---


:Realm_xvideos
SET "CurrentRealm=xvideos"
REM // https://www.xvideos.com/videonnnnnnnn/lil_d_wird_beim_ficken_von_valerie_kay_auf_dem_balkon_erwischt
REM // https://www.xvideos.com/embedframe/nnnnnnnn
REM Check if link is already embed, then skip to downloading since video clear link is on embed page
IF EXIST "!SELFDropTemp!temp.mp4" (
	DEL /F /Q "!SELFDropTemp!temp.mp4" >NUL
)
IF EXIST "!SELFDropTemp!temp.html" (
	DEL /F /Q "!SELFDropTemp!temp.html" >NUL
)
IF "!URL2!"=="embedframe" (
	ECHO.[!CurrentRealm!] Link type: [embed]
	SET "EmbedURL=!BuiltURL!"
	SET "FileName=XVIDEOS-!URL3!"
	GOTO :xvideos_DL_Webpage
)
REM Get video code, link is webpage, not embed
ECHO.[!CurrentRealm!] Link type: [video]
SET "VideoID=!URL2:video=!"
IF DEFINED VideoID (
	ECHO.[!CurrentRealm!] Got VideoID...
)
SET "EmbedURL=https://www.xvideos.com/embedframe/!VideoID!"
:xvideos_DL_Webpage
SET "CurrentRealm=xvideos"
ECHO.[!CurrentRealm!] Downloading webpage...
CALL :JavascriptDownload "!EmbedURL!" "!SELFDropTemp!temp.html"
ECHO.[!CurrentRealm!] Parsing webpage...
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setVideoTitle" ') DO (
	SET "VideoTitle=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setVideoUrlLow" ') DO (
	SET "SourceLineLow=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setVideoUrlHigh" ') DO (
	SET "SourceLineHigh=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setUploaderName" ') DO (
	SET "UploaderID=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setThumbSlide" ') DO (
	SET "ThumbnailMosaique=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setThumbUrl" ') DO (
	SET "Thumbnail=%%A"
	GOTO :xvideos_DL_ManageDownloadVars
)

:xvideos_DL_ManageDownloadVars
SET "CurrentRealm=xvideos"
SET "VideoTitle=!VideoTitle: =_!"
SET "VideoTitle=!VideoTitle:~32!"
SET "VideoTitle=!VideoTitle:~0,-3!"
SET "SourceLineLow=!SourceLineLow: =!"
SET "SourceLineLow=!SourceLineLow:~29!"
SET "SourceLineLow=!SourceLineLow:~0,-3!"
SET "SourceLineHigh=!SourceLineHigh: =!"
SET "SourceLineHigh=!SourceLineHigh:~30!"
SET "SourceLineHigh=!SourceLineHigh:~0,-3!"
SET "UploaderID=!UploaderID: =!"
SET "UploaderID=!UploaderID:~30!"
SET "UploaderID=!UploaderID:~0,-3!"
IF DEFINED XNXXFlag (
	SET "Thumbnail=!Thumbnail: =!"
	SET "Thumbnail=!Thumbnail:~26!"
	SET "Thumbnail=!Thumbnail:~0,-3!"
	SET "ThumbnailMosaique=!Thumbnail!"
	SET "FileName=!VideoTitle!-!UploaderID!"
	ECHO.Video title: !VideoTitle! by !UploaderID!
	FOR /L %%A IN (1,1,1000) DO (
		IF "!VideoTitle:~%%A,1!"=="&" (
			ECHO.[!CurrentRealm!] Found regional encoded video title.
			ECHO.[!CurrentRealm!] Falling back to original title.
			SET "FileName=!URL5!-!UploaderID!"
			ECHO.[!CurrentRealm!] New video title: !URL5! by !UploaderID!
			SET "XNXXFlag="
			GOTO :xvideos_escape_loop
		)
	)
	SET "XNXXFlag="
	GOTO :xvideos_escape_loop
)
SET "Thumbnail=!Thumbnail: =!"
SET "Thumbnail=!Thumbnail:~26!"
SET "Thumbnail=!Thumbnail:~0,-3!"
SET "ThumbnailMosaique=!ThumbnailMosaique: =!"
SET "ThumbnailMosaique=!ThumbnailMosaique:~28!"
SET "ThumbnailMosaique=!ThumbnailMosaique:~0,-3!"
REM
REM ECHO.!Thumbnail!
SET "FileName=!VideoTitle!-!UploaderID!"
ECHO.[!CurrentRealm!] Video title: !VideoTitle! by !UploaderID!
FOR /L %%A IN (1,1,1000) DO (
	IF "!VideoTitle:~%%A,1!"=="&" (
		ECHO.Found regional encoded video title.
		ECHO.Falling back to original title.
		SET "FileName=!URL5!-!UploaderID!"
		ECHO.New video title: !URL5! by !UploaderID!
		GOTO :xvideos_escape_loop
	)
)
:xvideos_escape_loop
SET "CurrentRealm=xvideos"
IF !CL_MakeMode! EQU 1 (
	ECHO.!VideoTitle!
	ECHO.!SourceLineLow!
	ECHO.!SourceLineHigh!
	ECHO.!UploaderID!
	ECHO.!ThumbnailMosaique!
	ECHO.!Thumbnail!
	PAUSE >NUL
)
:xvideos_Download
SET "CurrentRealm=xvideos"
ECHO.[!CurrentRealm!] Retreiving thumbnail...
CALL :JavascriptDownload "!ThumbnailMosaique!" "!SELFDropTemp!thumb.jpg"
ECHO.[!CurrentRealm!] Starting download...
START /WAIT "" %~dpnx0 "PopOut" "XVDMFDL" "!SourceLineHigh!" "!SELFDropTemp!temp.mp4"
ECHO.[!CurrentRealm!] Download complete.
TIMEOUT /T 2 >NUL
ECHO.[!CurrentRealm!] Renaming temp.mp4
RENAME "!SELFDropTemp!temp.mp4" "!FileName!.mp4" >NUL
RENAME "!SELFDropTemp!thumb.jpg" "!FileName!_thumb.jpg" >NUL
ECHO.                                   --^>
ECHO.                                        !FileName!.mp4
ECHO.Moving file to !SELFDropFolder!.
MOVE "!SELFDropTemp!!FileName!.mp4" "!SELFDropFolder!" >NUL
MOVE "!SELFDropTemp!!FileName!_thumb.jpg" "!SELFDropFolder!" >NUL
ECHO.[!CurrentRealm!] Download finished.
TIMEOUT /T 5 >NUL
!ParametricDownloadSwitch!
GOTO :MAIN
EXIT /B


::: ---


:Realm_xnxx
SET "CurrentRealm=xnxx"
SET "XNXXFlag=1"
IF EXIST "!SELFDropTemp!temp.mp4" (
	DEL /F /Q "!SELFDropTemp!temp.mp4" >NUL
)
IF EXIST "!SELFDropTemp!temp.html" (
	DEL /F /Q "!SELFDropTemp!temp.html" >NUL
)
ECHO.[!CurrentRealm!] Downloading webpage...
CALL :JavascriptDownload "!BuiltURL!" "!SELFDropTemp!temp.html"
ECHO.[!CurrentRealm!] Parsing webpage...
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "new HTML5Player" ') DO (
	SET "VideoID=%%A"
)
SET "VideoID=!VideoID:~50!"
SET "VideoID=!VideoID:~0,-3!
SET "EmbedURL=https://www.xvideos.com/embedframe/!VideoID!"
IF !CL_MakeMode! EQU 1 (
	ECHO.!EmbedURL!
	REM ECHO.!VideoTitle!
	REM ECHO.!SourceLineLow!
	REM ECHO.!SourceLineHigh!
	REM ECHO.!UploaderID!
	REM ECHO.!ThumbnailMosaique!
	REM ECHO.!Thumbnail!
)
GOTO :xvideos_DL_Webpage
EXIT /B


::: ---

:TODO

:Realm_xhamster

:::Currently broken until i fix the m3u8 fuckery.

EXIT /B
SET "CurrentRealm=xhamster"
TITLE b.dl - Downloading from xhamster!CL_Codebase!
REM // https://geocode.xhamster.com/videos/xx-xxxxx-xxxxx-xxxx-xxxxx-x-xxx-xxxxxx-xxx-nnnnnnn
REM // https://geocode.xhamster.com/embed/nnnnnnn
REM Check if link is already embed, then skip to downloading since video clear link is on embed page
IF EXIST "!SELFDropTemp!temp.mp4" (
	DEL /F /Q "!SELFDropTemp!temp.mp4" >NUL
)
IF EXIST "!SELFDropTemp!temp.html" (
	DEL /F /Q "!SELFDropTemp!temp.html" >NUL
)
IF "!URL2!"=="embed" (
	ECHO.[!CurrentRealm!] Link type: [!URL2!]
	SET "EmbedURL=!BuiltURL!"
	SET "FileName=XHAMSTER-!URL3!"
	GOTO :xhamster_DL_Webpage
)
REM Get video code
ECHO.[!CurrentRealm!] Link type: [video]
SET A=1
FOR /L %%A IN (1,1,100) DO (
	IF "!URL3:~%%A,1!"=="-" (
		SET /A A+=1
	)
)
FOR /F "tokens=%A%* delims=-" %%A IN ("!URL3!") DO (
	SET "VideoID=%%A"
)
IF DEFINED VideoID (
	ECHO.[!CurrentRealm!] Got VideoID.
)
SET "EmbedURL=https://!URL1!/embed/!VideoID!"
:xhamster_DL_Webpage
SET "CurrentRealm=xhamster"
ECHO.[!CurrentRealm!] Downloading webpage...
CALL :JavascriptDownload "!EmbedURL!" "!SELFDropTemp!temp.html"
ECHO.[!CurrentRealm!] Parsing webpage...
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "standard^":{^"mp4^"" ') DO (
	SET "SourceLine=%%A"
)
ECHO.[!CurrentRealm!] Getting download URL...
SET "SourceLine=!SourceLine:~13!"
SET "DownloadURL=!SourceLine:~0,-19!"
SET "FileName=!URL3:~0,-5!"
IF !CL_MakeMode! EQU 1 (
	REM ECHO.!VideoTitle!
	REM ECHO.!SourceLineLow!
	ECHO.[!CurrentRealm!] !DownloadURL!
	REM ECHO.!UploaderID!
	REM ECHO.!ThumbnailMosaique!
	REM ECHO.!Thumbnail!
	PAUSE >NUL
)
EXIT /B


::: ---



:TODO

:Realm_hclips

:::Currently broken

EXIT /B
SET "CurrentRealm=hclips"
TITLE b.dl - Downloading from hclips!CL_Codebase!
REM // https://hclips.com/videos/nnnnnnn/beautiful-blonde-riding-xx-xxx-xxxx-xx-xxxxxxxxx/
REM // https://hclips.com/embed/nnnnnnn/
REM Check if link is already embed, then skip to downloading since video clear link is on embed page

IF EXIST "!SELFDropTemp!temp.mp4" (
	DEL /F /Q "!SELFDropTemp!temp.mp4" >NUL
)
IF EXIST "!SELFDropTemp!temp.html" (
	DEL /F /Q "!SELFDropTemp!temp.html" >NUL
)

IF "!URL2!"=="embed" (
	ECHO.[!CurrentRealm!] Link type: [!URL2!]
	SET "EmbedURL=!BuiltURL!"
	SET "FileName=HCLIPS-!URL3!"
	GOTO :hclips_DL_Webpage
)

REM Get video code
ECHO.[!CurrentRealm!] Link type: [video]
SET "VideoID=!URL3!"
SET "FileName=HCLIPS-!URL4!!URL3!"
IF DEFINED VideoID (
	ECHO.[!CurrentRealm!] Got VideoID.
)
SET "EmbedURL=https://!URL1!/embed/!VideoID!"
:hclips_DL_Webpage
SET "CurrentRealm=hclips"
ECHO.[!CurrentRealm!] Downloading webpage...
CALL :JavascriptDownload "!EmbedURL!" "!SELFDropTemp!temp.html"
ECHO.[!CurrentRealm!] Parsing webpage...
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setVideoUrlLow" ') DO (
	SET "SourceLineLow=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setVideoUrlHigh" ') DO (
	SET "SourceLineHigh=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setUploaderName" ') DO (
	SET "UploaderID=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setThumbSlide" ') DO (
	SET "ThumbnailMosaique=%%A"
)
FOR /F "delims=*" %%A IN ('TYPE !SELFDropTemp!temp.html ^| FIND "html5player.setThumbUrl" ') DO (
	SET "Thumbnail=%%A"
	GOTO :hclips_DL_ManageDownloadVars
)

:::Realm ideas to check out: imgur erome motherless porn.com redtube heavyr eporner shameless youjizz

:TODO
:DL_FLICKRSINGLEPIC
SET "EmbedURL=https://www.flickr.com/services/oembed?url="
SET "URL=!AAA!//!SERVICE!/!FIRST!/!SECOND!/!THIRD!/"
IF NOT EXIST "%S1%\FlickLoad\" MKDIR "%S1%\FlickLoad\"

IF NOT EXIST "%S2%\FlickLoad\" MKDIR "%S2%\FlickLoad\"
WGET -q --no-verbose --no-check-certificate -O "%S1%\FlickLoad\temp.html" "!EmbedURL!!URL!" --user-agent="Mozilla/42.0"
FOR /F "delims=^^<+^^> tokens=1,2,3,4,5" %%A IN ('TYPE %S1%\FlickLoad\temp.html ^| FIND "type"') DO (
        SET "FT=%%C"
)
IF NOT "!FT!"=="photo" (
	ECHO.
	ECHO.ATTENTION^^!^^!^^!
	ECHO. -------------------
	ECHO. Filetype ^>^>^>!FT!^<^<^< might not be supported.
	ECHO. -------------------
	ECHO.
	PAUSE
	REM CALL :DL_FLICKRSINGLEPIC.METHOD_B
	EXIT /B
)
FOR /F "delims=^^<+^^> tokens=1,2,3,4,5" %%A IN ('TYPE %S1%\FlickLoad\temp.html ^| FIND "title"') DO (
        SET "FILENAME=%%C"
		ECHO.FILENAME:!FILENAME!
		GOTO :DL_FLICKRSINGLEPIC.B
)
:DL_FLICKRSINGLEPIC.B
FOR /F "delims=^^<+^^> tokens=1,2,3,4,5" %%A IN ('TYPE %S1%\FlickLoad\temp.html ^| FIND "author_name"') DO (
        SET "AUTHORNAME=%%C"
)
IF EXIST "%S2%\FlickLoad\!AUTHORNAME!\!THIRD!.jpg" EXIT /B
FOR /F "delims=^^<+^^> tokens=1,2,3,4,5" %%A IN ('TYPE %S1%\FlickLoad\temp.html ^| FIND "author_url"') DO (
        SET "AUTHORURL=%%C"
)
IF NOT EXIST "%S2%\FlickLoad\!AUTHORNAME!\" MKDIR "%S2%\FlickLoad\!AUTHORNAME!\"
IF NOT EXIST "%S2%\FlickLoad\!AUTHORNAME!\page.txt" (
	ECHO.bamd Flickload Module v.0.1 > "%S2%\FlickLoad\!AUTHORNAME!\page.txt"
	ECHO.Author Name: !AUTHORNAME! >> "%S2%\FlickLoad\!AUTHORNAME!\page.txt"
	ECHO.Author URL: !AUTHORURL! >> "%S2%\FlickLoad\!AUTHORNAME!\page.txt"
	ECHO.>> "%S2%\FlickLoad\!AUTHORNAME!\page.txt"
)
ECHO.!Third!.jpg - !Filename! - !URL!>> "%S2%\FlickLoad\!AUTHORNAME!\page.txt"
FOR /F "delims=^^<+^^> tokens=1,2,3,4,5 skip=1" %%A IN ('TYPE %S1%\FlickLoad\temp.html ^| FIND "url"') DO (
        SET "DLURL=%%C"
		ECHO.DLURL:!DLURL!
		GOTO :DL_FLICKRSINGLEPIC.C
)
:DL_FLICKRSINGLEPIC.C
WGET -q --no-verbose --no-check-certificate -O "%S1%\FlickLoad\!Third!.jpg" "!DLURL!" --user-agent="Mozilla/42.0"
MOVE "%S1%\FlickLoad\!Third!.jpg" "%S2%\FlickLoad\!AUTHORNAME!\" >NUL
EXIT /B

:DL_FLICKRSINGLEPIC.METHOD_B
WGET -q --no-verbose --no-check-certificate -O "%S1%\FlickLoad\temp.html" "!URL!" --user-agent="Mozilla/42.0"
FOR /F "delims={+: tokens=1,2,3,4,5,6,7,8," %%A IN ('TYPE %S1%\FlickLoad\temp.html ^| FIND "displayUrl"') DO (
        SET "AUTHORURL=%%C"
		ECHO.%%A
		ECHO.%%B
		ECHO.%%C
		ECHO.%%D
		ECHO.%%E
		ECHO.%%F
		ECHO.%%G
		ECHO.%%H
)
PAUSE
EXIT /B

::: /// :[DOWNLOAD MODULES END]: /// :::

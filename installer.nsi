!include "FileFunc.nsh"
!include "LogicLib.nsh"

OutFile "MultiRuntimeInstaller.exe"
InstallDir "$PROGRAMFILES\SynapsisApp"
RequestExecutionLevel admin
InstallDirRegKey HKCU "Software\SynapsisApp" "InstallPath"

Section "Install Environment"

  SetOutPath "$INSTDIR"

  ; ----------------------------------------
  ; Check if Python 3.12 is installed
  ; ----------------------------------------
  DetailPrint "Checking for Python 3.12..."
  ReadRegStr $0 HKLM "SOFTWARE\Python\PythonCore\3.12\InstallPath" ""

  ${If} $0 == ""
    DetailPrint "Python not found. Installing locally..."
    File "python-3.12.0-amd64.exe"
    ExecWait '"$INSTDIR\python-3.12.0-amd64.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0'
  ${Else}
    DetailPrint "Python already installed at: $0"
  ${EndIf}


  ; ----------------------------------------
  ; Check if Node.js is available
  ; ----------------------------------------
  DetailPrint "Checking for Node.js..."
  ClearErrors
  nsExec::ExecToLog 'node -v'
  Pop $1

  ${If} ${Errors}
    DetailPrint "Node.js not found. Installing locally..."
    File "node-v20.12.2-x64.msi"
    ExecWait 'msiexec /i "$INSTDIR\node-v20.12.2-x64.msi" /quiet'
  ${Else}
    DetailPrint "Node.js is already available."
  ${EndIf}


  ; ----------------------------------------
  ; Check if Java Runtime (JDK 21+) is installed
  ; ----------------------------------------
  DetailPrint "Checking for Java..."
  ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"

  ${If} $2 == ""
    DetailPrint "Java not found. Installing locally..."
    File "jdk-21_windows-x64_bin.exe"
    ExecWait '"$INSTDIR\jdk-21_windows-x64_bin.exe" /s'
  ${Else}
    DetailPrint "Java detected: Version $2"
  ${EndIf}


  ; ----------------------------------------
  ; Copy app files from /dist
  ; ----------------------------------------
  DetailPrint "Copying application files..."
  SetOutPath "$INSTDIR"
  File /r "dist\*.*"

  ; Save install location
  WriteRegStr HKCU "Software\SynapsisApp" "InstallPath" "$INSTDIR"

SectionEnd

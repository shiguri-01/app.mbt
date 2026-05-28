@echo off
setlocal

if defined VSCMD_ARG_TGT_ARCH goto run
if defined VCINSTALLDIR goto run

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
  echo Unable to find vswhere.exe. Install Visual Studio Build Tools or run this from a Developer Command Prompt.
  exit /b 1
)

for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set "VS_INSTALL_DIR=%%i"
)

if not defined VS_INSTALL_DIR (
  echo Unable to find Visual Studio C++ build tools. Install the C++ build tools workload or run this from a Developer Command Prompt.
  exit /b 1
)

set "VSVARS=%VS_INSTALL_DIR%\VC\Auxiliary\Build\vcvarsall.bat"
if not exist "%VSVARS%" (
  echo Unable to find vcvarsall.bat at "%VSVARS%".
  exit /b 1
)

call "%VSVARS%" x64
if errorlevel 1 exit /b %errorlevel%

:run
%*

@echo off
setlocal

set "VSVARS=C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"

call "%VSVARS%" x64
if errorlevel 1 exit /b %errorlevel%

%*

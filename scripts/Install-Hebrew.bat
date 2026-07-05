@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\installer\Install-HebrewMovieMaker.ps1" -PackageRoot "%~dp0.."

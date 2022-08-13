@echo off
python pdxinfobuilder.py
%USERPROFILE%"\Documents\PlaydateSDK\bin\pdc.exe" src musik
%USERPROFILE%"\Documents\PlaydateSDK\bin\PlaydateSimulator.exe" "musik.pdx"
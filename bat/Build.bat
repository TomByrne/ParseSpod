@echo off
cd ../
del dist\\HAAR.zip /Q
rmdir dist\\temp /S /Q
timeout 1
mkdir dist\\temp
xcopy src dist\\temp /S /I
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('dist\\temp', 'dist\\HAAR.zip'); }"
haxelib submit dist\\HAAR.zip
rmdir dist\\temp /S /Q
pause
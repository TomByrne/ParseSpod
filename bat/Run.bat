@echo off
cd bin

::HaarTool-debug.exe load-parse email@address.com password IDM -- make verbose=true package=com.imagination.idm.parseApi
::HaarTool-debug.exe make verbose=true package=com.imagination.idm.parseApi

::neko haar.n load-parse email@address.com password IDM -- make verbose=true package=com.imagination.idm.parseApi
neko haar.n make verbose=true package=com.imagination.idm.parseApi

pause


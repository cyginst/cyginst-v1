setlocal

set CYG_NAME=emacs-w32.test
set CYG_BITS=32
::set CYG_CATS=Archive,Python
set CYG_PKGS=procps,psmisc,tmux,emacs-w32,emacs-el
set DT_ICONS=1
::set CYG_HOME=.

set CYG_DEBUG=0
set CYG_SITE=http://mirrors.kernel.org/sourceware/cygwin/
set CYG_LANG=ja
set CYG_FONT=MS Gothic
set CYG_FONT_HEIGHT=12

call cyginst.bat SUBPROC

endlocal
pause

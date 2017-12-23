setlocal

set CYG_NAME=emacs.test
set CYG_BITS=32
::set CYG_CATS=Archive,Python
set CYG_PKGS=procps,psmisc,tmux,emacs
set DT_ICONS=1
::set CYG_HOME=.
::set CYG_ASIS=1

set CYG_DEBUG=0
set CYG_SITE=http://mirrors.kernel.org/sourceware/cygwin/
set CYG_LANG=ja
set CYG_FONT=MS Gothic
set CYG_FONT_HEIGHT=12
set CYG_CURSOR_TYPE=block
set CYG_CONFIRM_EXIT=no

call cyginst.bat SUBPROC

endlocal
pause

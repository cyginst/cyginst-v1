@if(0)==(0) echo off
:: URL: https://github.com/cyginst/cyginst-v1/blob/master/cyginst.bat
:: REPO: cyginst-v1-2024-0218
setlocal

if "%1"=="SUBPROC" goto skip_init

set CYG_NAME=cyginst
set CYG_BITS=auto
::set CYG_CATS=Archive,Python
set CYG_PKGS=git,vim
set DT_ICONS=1
::set CYG_HOME=.
::set CYG_ASIS=1

set CYG_DEBUG=0
set CYG_SITE=http://mirrors.kernel.org/sourceware/cygwin/
set CYG_LANG=ja
set CYG_FONT=MS Gothic
set CYG_FONT_HEIGHT=16
set CYG_CURSOR_TYPE=block
set CYG_CONFIRM_EXIT=no

:skip_init

set SCRIPT=%~0
for /f "delims=\ tokens=*" %%z in ("%SCRIPT%") do (set SCRIPT_CURRENT_DIR=%%~dpz)

if "%CYG_DEBUG%"=="1" echo on
if /i "%CYG_BITS%"=="auto" (
    if exist "%ProgramFiles(x86)%" (
        set CYG_BITS=64
    ) else (
        set CYG_BITS=32
    )
)
set CYG_SETUP=
if "%CYG_BITS%"=="32" (
    set CYG_SETUP=setup-x86.exe
) else if "%CYG_BITS%"=="64" (
    set CYG_SETUP=setup-x86_64.exe
) else (
    echo CYG_BITS must be 32 or 64. [Current CYG_BITS: %CYG_BITS%] Aborting!
    if not "%1"=="SUBPROC" pause
    exit /b
)
call :dl_from_url %CYG_SETUP% http://www.cygwin.com/%CYG_SETUP%
set CYG_ROOT=%SCRIPT_CURRENT_DIR%%CYG_NAME%
if not exist "%CYG_ROOT%\bin\bash.exe" set CYG_ROOT=%CYG_ROOT%.c%CYG_BITS%
if not exist "%USERPROFILE%\.cyg-pkgs" mkdir "%USERPROFILE%\.cyg-pkgs"
set CAT_SPEC=
if not "%CYG_CATS%"=="" set CAT_SPEC=--categories="%CYG_CATS%"
if not "%CYG_PKGS%"=="" set CYG_PKGS="%CYG_PKGS%,"
set PKG_SPEC=--packages="%CYG_PKGS%curl,wget,gawk,tar,gnupg,libiconv,libiconv2"
%CYG_SETUP% -q -W %CAT_SPEC% %PKG_SPEC% ^
                  --root="%CYG_ROOT%" ^
                  --local-package-dir="%USERPROFILE%\.cyg-pkgs" ^
                  --site=%CYG_SITE% ^
                  --no-admin ^
                  --no-shortcuts ^
                  --upgrade-also
if exist "%CYG_ROOT%\Cygwin.bat" move "%CYG_ROOT%\Cygwin.bat" "%CYG_ROOT%\Cygwin%CYG_BITS% @%CYG_NAME%.bat"
if not exist "%CYG_ROOT%\usr\local\bin\apt-cyg" (
    bitsadmin /TRANSFER "apt-cyg" "https://github.com/kou1okada/apt-cyg/raw/master/apt-cyg" "%CYG_ROOT%\usr\local\bin\apt-cyg"
    "%CYG_ROOT%\bin\bash.exe" -l -c "chmod 755 /usr/local/bin/apt-cyg"
)
cscript.exe //nologo //E:JScript "%~f0"

endlocal
if not "%1"=="SUBPROC" pause
exit /b
goto :EOF
:dl_from_url
if not exist "%SCRIPT_CURRENT_DIR%%1" bitsadmin /TRANSFER "%1" "%2" "%SCRIPT_CURRENT_DIR%%1"
exit /b
@end

  if (!String.prototype.format) {
    String.prototype.format = function() {
      var args = arguments;
      return this.replace(/{(\d+)}/g, function(match, number) { 
        return typeof args[number] != 'undefined'
          ? args[number]
          : match
        ;
      });
    };
  }

  if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(prefix) {
      return (this.lastIndexOf(prefix, 0) === 0);
    };
  }

  if (!String.prototype.endsWith) {
    String.prototype.endsWith = function(suffix) {
      var sub = this.length - suffix.length;
      return (sub >= 0) && (this.lastIndexOf(suffix) === sub);
    };
  }

  if (!String.prototype.removeFirst) {
    String.prototype.removeFirst = function(prefix) {
      if (this.lastIndexOf(prefix, 0) === 0) {
        return this.substr(prefix.length);
      } else {
        return this;
      }
    };
  }

  if (!String.prototype.removeLast) {
    String.prototype.removeLast = function(suffix) {
      var sub = this.length - suffix.length;
      if (sub >= 0 && this.lastIndexOf(suffix) === sub) {
        return this.substr(0, this.lastIndexOf(suffix));
      } else {
        return this;
      }
    };
  }

  var env = new ActiveXObject("WScript.Shell").Environment("PROCESS");

  var CYG_OPTS = {
    debug:       (env.item("CYG_DEBUG") == "1"),
    root:         env.item("CYG_ROOT"),
    name:         env.item("CYG_NAME"),
    bits:         env.item("CYG_BITS"),
    dt_icons:    (env.item("DT_ICONS") == "1"),
    home:         env.item("CYG_HOME").replace(/^\s+|\s+$/g, ''), /*trim()*/
    asis:        (env.item("CYG_ASIS") == "1"),
    lang:         env.item("CYG_LANG"),
    font:         env.item("CYG_FONT"),
    font_height:  env.item("CYG_FONT_HEIGHT"),
    cursor_type:  env.item("CYG_CURSOR_TYPE"),
    confirm_exit: env.item("CYG_CONFIRM_EXIT")
  };

  postCygwinInstall(CYG_OPTS);

  try {
    //var http = WScript.CreateObject("MSXML2.XMLHTTP");
    var http = WScript.CreateObject("WinHttp.WinHttpRequest.5.1");
    http.Open("GET", "http://bit.ly/post-install-message_txt", false);
    http.Send();
    echo(http.responseText);
  } catch(e) {
  }

  WScript.Quit();

  function echo(msg) {
    WScript.Echo(msg);
  }

  function msgbox(msg) {
    var shell = new ActiveXObject("WScript.Shell");
    shell.Popup(msg, 0, "Cygwin Install", 0);
  }

  function postCygwinInstall(opts) {

    var StreamTypeEnum    = { adTypeBinary: 1, adTypeText: 2 };
    var LineSeparatorEnum = { adLF: 10, adCR: 13, adCRLF: -1 };
    var StreamReadEnum    = { adReadAll: -1, adReadLine: -2 };
    var StreamWriteEnum   = { adWriteChar: 0, adWriteLine: 1 };
    var SaveOptionsEnum   = { adSaveCreateNotExist: 1, adSaveCreateOverWrite: 2 };

    function createShorcut(dir, name, icon, target, args) {
      var shell = new ActiveXObject("WScript.Shell");
      var sc = shell.CreateShortcut(dir + "\\" + name + ".lnk");
      sc.IconLocation = icon;
      sc.TargetPath = target;
      sc.Arguments = args;
      sc.WorkingDirectory = "";
      sc.Save();
    }

    function writeTextToFile_Utf8_NoBOM(path, text) {
      var stream = new ActiveXObject("ADODB.Stream");
      stream.Type = StreamTypeEnum.adTypeText;
      stream.Charset = "utf-8";
      stream.Open();
      stream.WriteText(text);
      stream.Position = 0
      stream.Type = StreamTypeEnum.adTypeBinary;
      stream.Position = 3
      var buf = stream.Read();
      stream.Position = 0
      stream.Write(buf);
      stream.SetEOS();
      stream.SaveToFile(path, SaveOptionsEnum.adSaveCreateOverWrite);
      stream.Close();
    }

    function deleteFile(path) {
      var fso = new ActiveXObject("Scripting.FileSystemObject");
      try {
        fso.DeleteFile(path, true);
      } catch(e) {
      }
    }

    function editConfigFile(path, lineStart, lineAfter, override) {
      if (lineAfter == null) override = true;
      var txt = "";
      var found = false;
      var match = false;
      try {
        var stream1 = new ActiveXObject("ADODB.Stream");
        stream1.Type = StreamTypeEnum.adTypeText;
        stream1.Charset = "utf-8";
        stream1.LineSeparator = LineSeparatorEnum.adLF;
        stream1.Open();
        stream1.LoadFromFile(path);
        while (!stream1.EOS) {
          var line = stream1.ReadText(StreamReadEnum.adReadLine);
            if (line.startsWith(lineStart)) {
              found = true;
              if (!override) break;
              if (lineAfter == null) continue;
              if (line == lineAfter) {
                match = true;
                break;
              }
              line = lineAfter;
            }
            txt += line + "\n";
        }
        if (!found && lineAfter != null) txt += lineAfter + "\n";
        stream1.Close();
      } catch(e) {
        if (lineAfter != null) txt = lineAfter + "\n";
      }
      if (match) return;
      if (found && !override) return;
      if (txt == "")
        deleteFile(path)
      else
        writeTextToFile_Utf8_NoBOM(path, txt);
    }

    function defaultSetting(path, lineStart, lineAfter) { editConfigFile(path, lineStart, lineAfter, false); }

    function replaceSetting(path, lineStart, lineAfter) { editConfigFile(path, lineStart, lineAfter, true); }

    var fso = new ActiveXObject("Scripting.FileSystemObject");
    var shell = new ActiveXObject("WScript.Shell");

    var profilePath = opts.root + "\\etc\\profile";
    if (opts.home == "") {
      replaceSetting(profilePath, "  USER=\"$(/usr/bin/id -un)\"", "  USER=\"$(/usr/bin/id -un)\"");
    } else {
      var privateHome = opts.home.endsWith("$");
      opts.home = opts.home.removeLast("$");
      opts.home = fso.GetAbsolutePathName(opts.home).replace(new RegExp("\\\\", "g"), "/");
      opts.home = opts.home.removeLast("/");
      var unixHome = "`/usr/bin/cygpath -u {0}`".format(opts.home);
      replaceSetting(profilePath, "  USER=\"$(/usr/bin/id -un)\"", "  USER=\"$(/usr/bin/id -un)\";HOME=" + unixHome + (privateHome ? "" : "/$USER"));
    }

    var bashrcPath = opts.root + "\\etc\\bash.bashrc";
    var bashrcOrig = bashrcPath + ".orig";
    if (fso.FileExists(bashrcPath)) {
      if (!fso.FileExists(bashrcOrig)) {
        fso.CopyFile(bashrcPath, bashrcOrig, true);
        var ps1 = ("if [ \"x$INSIDE_EMACS\" != \"x\" ]; then PS1='\\[\\e[35m\\]\\u@{0}(Cygwin{1}) \\w\\[\\e[0m\\]\\n$ '; "
                   + "else PS1='\\[\\e]0;Cygwin{1} @{0} \\w\\a\\]\\n\\[\\e[32m\\]\\u@{0}(Cygwin{1}) \\[\\e[33m\\]\\w\\[\\e[0m\\]\\n$ '; fi")
                  .format(opts.name, opts.bits);
        replaceSetting(bashrcPath, "PS1=", ps1);
      }
    }

    var desktopPath = shell.SpecialFolders("Desktop");
    if (opts.debug) WScript.Echo("desktopPath=" + desktopPath);

    var name, icon, target, args;

    var bashPath = opts.root + "\\bin\\bash.exe";
    if (!fso.FileExists(bashPath)) return;

    name = "Bash Console @{0} ({1}bit)".format(opts.name, opts.bits);
    icon = opts.root + "\\Cygwin.ico";
    target = bashPath;
    args = "--login -i";
    createShorcut(opts.root, name, icon, target, args);
    if (opts.dt_icons) createShorcut(desktopPath, name, icon, target, args);

    var minttyPath = opts.root + "\\bin\\mintty.exe";
    if (!fso.FileExists(minttyPath)) return;

    var minttyrcPath = opts.root + "\\etc\\minttyrc";
    if (opts.lang != "")         defaultSetting(minttyrcPath, "Language=",    "Language={0}".format(opts.lang));
    if (opts.font != "")         defaultSetting(minttyrcPath, "Font=",        "Font={0}".format(opts.font));
    if (opts.font_height != "")  defaultSetting(minttyrcPath, "FontHeight=",  "FontHeight={0}".format(opts.font_height));
    if (opts.cursor_type != "")  defaultSetting(minttyrcPath, "CursorType=",  "CursorType={0}".format(opts.cursor_type));
    if (opts.confirm_exit != "") defaultSetting(minttyrcPath, "ConfirmExit=", "ConfirmExit={0}".format(opts.confirm_exit));

    var minttyCommon = "-i /Cygwin-Terminal.ico --window max";

    name = "Cygwin Terminal @{0} ({1}bit)".format(opts.name, opts.bits);
    icon = opts.root + "\\Cygwin-Terminal.ico";
    target = minttyPath;
    args = "{0} -".format(minttyCommon);
    createShorcut(opts.root, name, icon, target, args);
    if (opts.dt_icons) createShorcut(desktopPath, name, icon, target, args);

    var tmuxPath = opts.root + "\\bin\\tmux.exe";
    if (fso.FileExists(tmuxPath)) {
      var tmuxConfPath = opts.root + "\\etc\\tmux.conf";
      replaceSetting(tmuxConfPath, "bind -n S-up ",
                opts.asis ? null : "bind -n S-up select-pane -U \\; display-panes");
      replaceSetting(tmuxConfPath, "bind -n S-down ",
                opts.asis ? null : "bind -n S-down select-pane -D \\; display-panes");
      replaceSetting(tmuxConfPath, "bind -n S-left ",
                opts.asis ? null : "bind -n S-left select-pane -L \\; display-panes");
      replaceSetting(tmuxConfPath, "bind -n S-right ",
                opts.asis ? null : "bind -n S-right select-pane -R \\; display-panes");
      replaceSetting(tmuxConfPath, "bind-key -n C-Up ",
                opts.asis ? null : "bind-key -n C-Up resize-pane -U \\; display-panes");
      replaceSetting(tmuxConfPath, "bind-key -n C-Down ",
                opts.asis ? null : "bind-key -n C-Down resize-pane -D \\; display-panes");
      replaceSetting(tmuxConfPath, "bind-key -n C-Left ",
                opts.asis ? null : "bind-key -n C-Left resize-pane -L \\; display-panes");
      replaceSetting(tmuxConfPath, "bind-key -n C-Right ",
                opts.asis ? null : "bind-key -n C-Right resize-pane -R \\; display-panes");
      var name, icon, target, args;
      name = "Tmux @{0} ({1}bit)".format(opts.name, opts.bits);
      icon = opts.root + "\\Cygwin-Terminal.ico";
      target = minttyPath;
      args = "{0} -t \"Tmux @{1} ({2}bit)\" /bin/bash --login -c \"/usr/bin/tmux\""
             .format(minttyCommon, opts.name, opts.bits);
      createShorcut(opts.root, name, icon, target, args);
      if (opts.dt_icons) createShorcut(desktopPath, name, icon, target, args);
    }

    var emacsPath = opts.root + "\\bin\\emacs";
    if (fso.FileExists(emacsPath)) {
      var name, icon, target, args;
      name = "Emacs Shell @{0} ({1}bit)".format(opts.name, opts.bits);
      var emacsW32Path = opts.root + "\\bin\\emacs-w32.exe";
      if (fso.FileExists(emacsW32Path)) icon = emacsW32Path + ", 0"; else icon = opts.root + "\\Cygwin-Terminal.ico";
      target = minttyPath;
      args = "{0} -t \"Emacs Shell @{1} ({2}bit)\" /bin/bash --login -c \"/usr/bin/emacs -nw --eval '(progn (shell) (delete-other-windows))'\""
             .format(minttyCommon, opts.name, opts.bits);
      createShorcut(opts.root, name, icon, target, args);
      if (opts.dt_icons) createShorcut(desktopPath, name, icon, target, args);
    }

    function editEmacsSiteStart(siteStartPath) {
      if (fso.FolderExists(fso.getParentFolderName(siteStartPath))) {
        echo("EDIT: " + siteStartPath);
        defaultSetting(siteStartPath,
          "(setq frame-title-format ",
          "(setq frame-title-format \"[%b] @{0} - Emacs ({1}bit)\")".format(opts.name, opts.bits));
        defaultSetting(siteStartPath,
          "(set-frame-parameter nil 'fullscreen ",
          opts.asis ? null : "(set-frame-parameter nil 'fullscreen 'maximized)");
        defaultSetting(siteStartPath,
          "(windmove-default-keybindings",
          opts.asis ? null : "(windmove-default-keybindings 'meta)");
        defaultSetting(siteStartPath, "(global-set-key (kbd \"\\e <up>\")",
                   opts.asis ? null : "(global-set-key (kbd \"\\e <up>\") 'windmove-up)");
        defaultSetting(siteStartPath, "(global-set-key (kbd \"\\e <down>\")",
                   opts.asis ? null : "(global-set-key (kbd \"\\e <down>\") 'windmove-down)");
        defaultSetting(siteStartPath, "(global-set-key (kbd \"\\e <left>\")",
                   opts.asis ? null : "(global-set-key (kbd \"\\e <left>\") 'windmove-left)");
        defaultSetting(siteStartPath, "(global-set-key (kbd \"\\e <right>\")",
                   opts.asis ? null : "(global-set-key (kbd \"\\e <right>\") 'windmove-right)");
        defaultSetting(siteStartPath, "(global-set-key (kbd \"\\C-x <kp-add>\")",
                   opts.asis ? null : "(global-set-key (kbd \"\\C-x <kp-add>\") 'balance-windows)");
      }
    }
    editEmacsSiteStart(opts.root + "\\usr\\share\\emacs\\site-lisp\\site-start.el");

    var gitConfigPath = opts.root + "\\etc\\gitconfig";
    if (!fso.FileExists(gitConfigPath)) {
        writeTextToFile_Utf8_NoBOM(gitConfigPath, "[core]\n\tautocrlf = input\n");
    }

  }


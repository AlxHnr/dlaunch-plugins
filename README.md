# Dlaunch plugins

This repository contains various small plugins for
[Dlaunch](https://github.com/AlxHnr/Dlaunch). Here is a short overview of
them:

### exec-path

Run arbitrary programs which are locatable trough your path variable. This
plugin provides a source named _"exec-path"_, and a handler which runs
these.

### open-home-files

Search your home directory for files and open them using. This plugin
provides a source named _"home-files"_. It uses _xdg-open_ to start your
systems default application for the given filetype. To change your systems
default programs, refer to the application of your desktop environment.

This plugin ignores various directories by default, like VCS or cache
directories. To disable this or to specify custom patterns, you must create
the file `~/.config/dlaunch/ignore-files.scm`. It is a Scheme file
containing various quoted regex strings. Remember to escape backslashes,
unless you want to use ASCII escape sequences. For more informations, refer
to the documentation of the
[irregex unit](http://wiki.call-cc.org/man/4/Unit%20irregex).

Here is an example:

```scheme
"^.*\\.(a|o|so|dll|class|pyc|bin)$"
"^.*\\/\\.(gconf|mozilla|git|cache)$"
"^.*\\/\\.(fontconfig|thumbnails|icons|themes|wine)$"
```

### user-cmd

Allows you to specify custom commands and aliases and provides a source
named _"user-cmd"_. They can be defined in the file
`~/.config/dlaunch/user-commands.scm`.

Here are some examples:

```scheme
; Some custom commands:
"i3-msg restart"
"claws-mail --receive-all"

; Some aliases:
("Shutdown System" . "sudo shutdown -h now")
("Reboot System"   . "sudo shutdown -r now")
```

## License

Released under the zlib license.

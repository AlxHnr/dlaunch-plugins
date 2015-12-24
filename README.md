This repository contains various small plugins for
[dlaunch](https://github.com/AlxHnr/dlaunch). This is free software,
released into the public domain. See the LICENSE file for more
informations.

Here is a short overview of them:

## exec-path

Run arbitrary programs which are locatable trough your path variable. This
plugin provides a source named _"exec-path"_, and a handler which runs
them.

## open-home-files

Search your home directory for files and open them. This plugin provides a
source named _"home-files"_. It uses _xdg-open_ to start your systems
default application for the given filetype. To change your systems default
programs, refer to the documentation of your desktop environment.

This plugin ignores various paths by default, like VCS or cache
directories. If you want to know what will be ignored exactly, take a look
at the [source code](https://github.com/AlxHnr/dlaunch-plugins/blob/master/open-home-files.scm#L10-L15).
To add your own ignore expressions, you must create the file
`~/.config/dlaunch/ignore-files.txt`. It is a text file containing one
regex pattern per line. This file can be empty. The expressions will be
matched against full filepaths. The allowed regex syntax is explained in
the documentation of the [irregex unit](http://wiki.call-cc.org/man/4/Unit%20irregex).

Here is an example:

```
^.*\.(a|o|so|dll|class|pyc|bin)$
^.*/\.(gconf|mozilla|claws-mail|cache|fontconfig|git|svn|hg)$
^.*/\.(thumbnails|icons|themes|wine)$
^.*/\.local/share/Trash$
```

If you want to override the defaults, you can create the file
`~/.config/dlaunch/ignore-files-override.txt`. This file has the same
structure as the normal ignore file, but will override both the defaults
and the patterns in `ignore-files.txt`.

## user-cmd

Allows you to specify custom commands and aliases in the file
`~/.config/dlaunch/user-commands.scm`. This plugin provides a source named
_"user-cmd"_.

Here is a configuration example:

```scheme
; Some custom commands:
"i3-msg restart"
"claws-mail --receive-all"

; Some aliases:
("Shutdown System" . "sudo shutdown -h now")
("Reboot System"   . "sudo shutdown -r now")
```

## command-history

Execute arbitrary shell commands and remember them until their score fades.
It provides a source named _"cmd-hist"_ and ignores commands which do not
start with a letter, number or underscore. This allows other plugins to
implement special commands prefixed by i.e. `:` or `=`.

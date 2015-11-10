# atom-diary package

Keep a diary in atom using markup like [Asciidoc](http://asciidoc.org/) or [Markdown](https://daringfireball.net/projects/markdown/).

This addon allows you to keep a diary in atom - how great is that?  It has a nice three month calendar view for easy navigation to past entries and organizes your diary files in monthly files.

* Add an entry for today: `Ctrl-Alt-E`
* Open calendar view: `Ctrl-Shift-E`

This addon is inspired by my Emacs module [diary-private.el](http://meta-x.de/software/diary-private.el)

You might want to install the [Asciidoctor preview package for Atom](https://atom.io/packages/asciidoctor-preview) for previewing your diary files.

## Features

![Screenshot of atom-diary](https://raw.githubusercontent.com/sluedecke/atom-diary/master/screenshot.png)

* `Ctrl-Alt-E`: Creates month based Asciidoc or Markdown files for diaries
* `Ctrl-Shift-E`: Opens three month calendar view, days with entries are clickable
* Calendar view allows to navigate back and forth between months and years
* User can set a language for the diary files different from the system language

## TODO items

### Major features

1. Make diary printable
  * include meta Asciidoc/Markdown files to create a printable diary using include::\*[]
* Make diary manageable
  * Add command to open diary basedir as a project with own tree-view, probably integrate with [project-manager](https://atom.io/packages/project-manager)
  * add sorting and other cleanup routines

### Minor features

* can we make use of services to communicate between atom windows?
* expand on ~/ and $HOME in baseDir configuration
* Improve markup support by using file templates
* watch for changes on diary files even when they are changed by atom outside atom-diary
* add some simple caching in calendar-lib::getDays which is based on file modification times
* Review licensing and consider switching to MIT License

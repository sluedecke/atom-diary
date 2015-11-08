# atom-diary package

This is a simple package to create diary entries using an [Asciidoc](http://asciidoc.org/) or [Markdown](https://daringfireball.net/projects/markdown/) templates.

There will be one file for each month which contains all entries for this month.
New entries for a day will be appended this file.  If there is no file
for the relevant month, it will be created and all files are kept within a configurable directory.

This addon is inspired by my Emacs module [diary-private.el](http://meta-x.de/software/diary-private.el)

You might want to install the [Asciidoctor preview package for Atom](https://atom.io/packages/asciidoctor-preview) for previewing your diary files.

## Features

![](screenshot.png)

* Creates month based Asciidoc or Markdown files for diaries
* Includes three month calendar view, days with entries are highlighted
* User can set a language for the diary files different from the system language
* Automatically creates the diary base directory and one sub-directory per year

## TODO items

### Major features

1. Add a calendar view
  * [DONE] add calendar view
  * [DONE] highlight dates with entries
  * [DONE] do not change cursor when hovering over days
  * [DONE] add close button to calendar view
  * [IN PROGRESS] open file for a day when clicking on it
  * add navigation to calendar view (switching months)
  * make useful for light and dark themes
* Make diary printable
  * include meta Asciidoc/Markdown files to create a printable diary using include::\*[]
* Make diary manageable
  * Add command to open diary basedir as a project with own tree-view, probably integrate with [project-manager](https://atom.io/packages/project-manager)
  * add sorting and other cleanup routines

### Minor features

* can we make use of services to communicate between atom windows?
* expand on ~/ and $HOME in baseDir configuration
* Improve markup support by using file templates
* Review licensing and consider switch to MIT License

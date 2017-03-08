# atom-diary package

Keep a diary in Atom using markup like [AsciiDoc](http://asciidoc.org/) or [Markdown](https://daringfireball.net/projects/markdown/).

This package allows you to keep a diary in atom - how great is that?  It has a nice three month calendar view for easy navigation to past entries and organizes your diary in monthly files.

- `Alt-Shift-d a`: Creates a new diary entry for the current time
- `Alt-Shift-d c`: Toggles the calendar view
- `Alt-Shift-d d`: Opens the diary as a project in a dedicated window
- `Alt-Shift-d p`: Creates a "printable" version of the diary

This package is inspired by my Emacs module [diary-private.el](http://meta-x.de/software/diary-private.el).

You might want to install the [AsciiDoctor preview package for Atom](https://atom.io/packages/asciidoctor-preview) for previewing your diary files.

## Features

![Screenshot of atom-diary](https://raw.githubusercontent.com/sluedecke/atom-diary/master/screenshot.png)

* Creates month based AsciiDoc or Markdown files for diaries
* Calendar view with clickable days
* Calendar view allows to navigate back and forth between months and years
* User can set a language for the diary files different from the system language
* User can create a printable version of the full diary (AsciiDoc only at the moment)
* User can open the diary folder as an atom project in a separate window

## TODO items

### Major features

1. [IN PROGRESS] Make diary printable
  * [DONE] Create meta AsciiDoc files to create a printable diary
  * Create meta Markdown files to create a printable diary
* Calendar View
  * [IN PROGRESS] Create new entries by right-clicking on a day
  * Add year selector (click on a year number to open selector, shall navigate to the selected year and the current month)
* [IN PROGRESS] Make diary manageable
  * [DONE] Add command to open diary basedir as a project with it's own tree-view, probably integrate with [project-manager](https://atom.io/packages/project-manager)
  * Add sorting and other cleanup routines


### Minor features

* Ask user on the very first start whether he wants to use AsciiDoc or Markdown
* Make navigating to settings an option in the packages menu (or add easy switching of markup language)
* Expand on ~/ and $HOME in baseDir configuration
* Improve markup support by using file templates
* Watch for changes on diary files even when they are changed by atom outside atom-diary
* Add some simple caching in calendar-lib::getDays which is based on file modification times
* When day changes, update marker on calendar view
* If available, open a pane with asciidoc/asciidoctor preview
* What happens if project-manager is not installed?

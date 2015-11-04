# atom-diary package

This is a simple package to create diary entries using a Asciidoc templates.

There will be one file for each month which contains all entries for this month.
New entries for a day will be appended to the months file.  If there is no file
for the relevant month, it will be created.

## Features

* Creates month based Asciidoc files for diaries
* Automatically creates the diary base directory, one sub-directory per year
* User can set a language for the diary files different from the system language

## TODO items

* expand on ~/ and $HOME in baseDir configuration
* include meta Asciidoc file to create a printable diary using include::*[]
* put month files in a directory per year

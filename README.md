# atom-diary package

This is a simple package to create diary entries using a Asciidoc templates.

There will be one file for each month which contains all entries for this month.
New entries for a day will be appended to the months file.  If there is no file
for the relevant month, it will be created.

## TODO items

* hardcoded '/home/saschal/.diary/atom' in configuration +
  This should be something like $HOME/... or ~/
* Path logic uses platform specific path separator
* enable users to choose and set language for diary files

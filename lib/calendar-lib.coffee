# coffeelint: disable=max_line_length
fs = require 'fs'
os = require 'os'
path = require 'path'
moment = require 'moment'
mkdirp = require 'mkdirp'
{Directory} = require 'atom'

# returns a map of days found in the files around now
# will check files for month(now) -1, month(now), month(now) + 1 if they exist
module.exports.getDays = getDays = (baseDir, prefix, markup, now) ->
  ## console.log "getDays called with #{baseDir} #{prefix} #{markup} #{now}"
  map = {}
  # start with last month
  myMoment = moment(now).subtract(1, 'month').startOf('month')
  for i in [0...3]
    year = myMoment.format("YYYY")
    month = myMoment.format("MM")
    name = getMonthFileName(baseDir, prefix, year, month, markup)
    map[year] = {} unless map[year]
    map[year][month] = {}
    try
      ## console.log "checking #{name}"
      s = fs.statSync(name)
      if s.isFile()
        content = fs.readFileSync(name, 'utf8')
        while (myArray = markups[markup].regex.exec(content)) != null
          # store only first match
          unless map[year][month][myArray[1]]
            map[year][month][myArray[1]] = markups[markup].regex.lastIndex
      else
        console.log "Not a file: #{name}"
    catch error
      ## console.log "Error reading file #{name}: #{error.message}"
    myMoment.add(1, 'month')
  ## console.log map
  map

module.exports.getCreateDirectories = getCreateDirectories = (baseDir, now) ->
  myDir = absolutize(baseDir)
  monthDir = myDir + path.sep + now.format('YYYY')
  aDir = new Directory(monthDir)
  mkdirp.sync(aDir.getRealPathSync())
  [myDir, monthDir]

module.exports.getMonthFileName = getMonthFileName = (baseDir, prefix, year, month, markup) ->
  absolutize(baseDir) +
    path.sep + year +
    path.sep + prefix + '-' + year + '-' + month + '.' + markups[markup].ext

module.exports.absolutize = absolutize = (directory) ->
  baseDir = path.normalize(directory)
  if !path.isAbsolute(baseDir)
    baseDir = os.homedir() + path.sep + baseDir
  baseDir

module.exports.markups = markups = {
  'Asciidoc' : {
    'ext': 'adoc'
    'regex': new RegExp("== ([0-9]+)", 'g')
    'fileHeader':
      """
      = {0}
      :toc:
      :numbered!:

      """
    'entryHeader':
      """

      == {0}


      """
    },
  'Markdown' : {
    'ext' : 'md'
    'regex': new RegExp("## ([0-9]+)", 'g')
    'fileHeader':
      """
      # {0}

      """
    'entryHeader':
      """

      ## {0}


      """
  }
}

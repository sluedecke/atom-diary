# coffeelint: disable=max_line_length
fs = require 'fs'
os = require 'os'
path = require 'path'
moment = require 'moment'
mkdirp = require 'mkdirp'

String.prototype.format = ->
  args = arguments
  return this.replace /{(\d+)}/g, (match, number) ->
    return if typeof args[number] isnt 'undefined' then args[number] else match

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

module.exports.createPrintableDiary = createPrintableDiary = (baseDir, prefix, markup) ->
  # delete old files first
  # a. iterate over years
  #    delete old year file
  #    create year file which includes all months
  #    collect year
  # b. create overall diary file
  #    delete old overall file
  #    create new one from year collection
  if !markups[markup]['summaryTemplate']
    throw new Error("Unsupported markup: #{markup}")
  baseDir = absolutize(baseDir)
  files = fs.readdirSync(baseDir)
  yearIncludes = ""
  for year in files
    if year.match(/^[0-9]{4}$/)
      # delete existing year summary files
      summaryFileNameBaseName = year + path.sep + prefix + '-' + year + '-00.' + markups[markup].ext
      summaryFileName = baseDir + path.sep + summaryFileNameBaseName
      try
        fs.unlinkSync(summaryFileName)
      catch error
        console.log "ignored error while deleting year file: #{error}"
      # collect month files
      monthFiles = fs.readdirSync(baseDir + path.sep + year)
      matcher = new RegExp("#{prefix}-#{year}-[0-9]{2}\.#{markups[markup].ext}")
      includes = ""
      for m in monthFiles
        if m.match(matcher)
          includes = includes + markups[markup].includeTemplate.format(m)
      summary = markups[markup].summaryTemplate.format(year, includes)
      console.log "writing to #{summaryFileName}"
      fs.writeFileSync(summaryFileName, summary)
      yearIncludes = yearIncludes + markups[markup].includeTemplate.format(summaryFileNameBaseName)

  # unlink diary summary file
  diarySummaryFile = "#{baseDir}#{path.sep}#{prefix}-all.#{markups[markup].ext}"
  diarySummary = markups[markup].summaryTemplate.format("Diary", yearIncludes)
  try
    fs.unlinkSync(diarySummaryFile)
  catch error
    console.log "ignored error while deleting diary summary file: #{error}"
  console.log "writing to #{diarySummaryFile}"
  fs.writeFileSync(diarySummaryFile, diarySummary)

# returns absolutized and existing directories for
# baseDir and the monthDir for the given now
# module.exports.getCreateDirectories = getCreateDirectories = (baseDir, now) ->
#   myDir = absolutize(baseDir)
#   monthDir = myDir + path.sep + now.format('YYYY')
#   mkdirp.sync(monthDir)
#   [myDir, monthDir]

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
    'regexStart': '== '
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
    'summaryTemplate':
      """
      = {0}
      :toc: left
      :toclevels: 4
      :numbered!:

      :leveloffset: +1

      {1}
      :leveloffset: -1
      """
    'includeTemplate':
      """
      include::{0}[]

      """
    },
  'Markdown' : {
    'ext' : 'md'
    'regex': new RegExp("## ([0-9]+)", 'g')
    'regexStart': '## '
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

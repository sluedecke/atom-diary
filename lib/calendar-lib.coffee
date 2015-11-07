# coffeelint: disable=max_line_length
fs = require 'fs'
path = require 'path'
moment = require 'moment'

# returns a map of days found in the files around now
# will check files for month(now) -1, month(now), month(now) + 1 if they exist
module.exports.getDays = getDays = (baseDir, prefix, ext, now, regex) ->
  map = {}
  myMoment = moment(now).subtract(1, 'month').startOf('month')
  for i in [0...3]
    year = myMoment.format("YYYY")
    month = myMoment.format("MM")
    name = baseDir + path.sep + year + path.sep + prefix + '-' + year + '-' + month + '.' + ext
    map[year] = {} unless map[year]
    map[year][month] = {}
    try
      s = fs.statSync(name)
      if s.isFile()
        content = fs.readFileSync(name, 'utf8')
        while (myArray = regex.exec(content)) != null
          map[year][month][myArray[1]] = 1
    catch error
    myMoment.add(1, 'month')
  map

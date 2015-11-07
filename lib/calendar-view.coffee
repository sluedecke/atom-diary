# coffeelint: disable=max_line_length

moment = require 'moment'
cal = require './calendar-lib'

module.exports =
class CalendarView
  dayMap = {}
  main = null

  constructor: (main) ->
    @main = main
    @element = document.createElement('div')
    m = document.createElement('label')
    m.textContent = "Calendar View"
    m.id = "calendar-title"
    @element.appendChild(m)
    d = document.createElement('div')
    d.id = 'calendar-content'
    @element.appendChild(d)

  update: (now) ->
    @element.removeChild(@element.lastChild)
    d = document.createElement('div')
    @element.appendChild(d)

    t = document.createElement('label')
    t.textContent = "Now: " + now.toString()
    d.appendChild(t)

    # for last, this and next month, add children
    table = document.createElement('table')
    d.appendChild(table)
    tr = table.insertRow(-1)
    tr.setAttribute("valign", "top")
    @dayMap = cal.getDays(
      cal.absolutize(atom.config.get('atom-diary.baseDir')),
      atom.config.get('atom-diary.filePrefix'),
      atom.config.get('atom-diary.markupLanguage')
      now)
    @addMonth(tr.insertCell(-1), moment(now).subtract(1, 'months'))
    @addMonth(tr.insertCell(-1), moment(now))
    @addMonth(tr.insertCell(-1), moment(now).add(1, 'months'))


  # Adds a month table to the root element.
  addMonth: (root, startDate) ->
    now = moment(startDate).startOf('month')
    t = document.createElement('table')
    t.className = "cal-monthtable"
    root.appendChild(t)

    # add month name
    tr = t.insertRow(-1)
    tc = tr.insertCell(-1)
    tc.innerHTML = now.format("MMMM YYYY")
    tc.setAttribute("colspan", "7")
    tc.className = "cal-header"

    # add weekday names
    tr = t.insertRow(-1)
    someMoment = moment(now).startOf('week')
    for i in [0...7]
      @addCell(tr, someMoment.format("dd"), @getClasses(someMoment, true))
      someMoment.add(1, 'day')

    # iterate over month and add rows with days
    tr = t.insertRow(-1)
    myMonth = now.month()
    someMoment = moment(now).startOf('week')
    year = now.format("YYYY")
    month = now.format("MM")
    for i in [0...42] # iterate over 6 rows which is the max of possible rows
      if myMonth == someMoment.month()
        classes = @getClasses(someMoment)
        day = someMoment.format("DD")
        if @dayMap[year][month][day]
          classes += " cal-has-entry"
        @addCell(tr, day, classes)
      else
        @addCell(tr, "", "")
      if i % 7 == 6 then tr = t.insertRow(-1)
      someMoment.add(1, 'day')


  addCell: (row, title, clazz) ->
    c = row.insertCell(-1)
    c.innerHTML = title
    c.className = clazz
    c.addEventListener("click", @logEvent)


  ##
  ## Internal routines to make life easier
  ##

  getClasses: (now, header) ->
    r = "cal-cell"
    if !header
      r+= " cal-day"
    if now.isoWeekday() > 5
      r += " cal-weekend"
    actual = moment()
    if now.year() == actual.year() and now.dayOfYear() == actual.dayOfYear()
      r += " cal-today"
    r

  ##
  ## Callbacks for click events
  ##

  toggleEvent: (e) ->
    console.log e
    if @main
      @main.toggleCalendar()
    else
      console.log "main is not: #{main}"

  logEvent: (e) ->
    console.log e
    console.log e.target.textContent


  ##
  ## Remaining lifecycle routines
  ##

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  serialize: ->

# coffeelint: disable=max_line_length

moment = require 'moment'
cal = require './calendar-lib'

module.exports =
class CalendarView
  dayMap = {}
  main = null
  now = null

  constructor: (main) ->
    @main = main
    @element = document.createElement('div')

    #
    # calendar header and close button
    #
    titleBar = document.createElement('div')
    titleBar.className = 'calendar-titlebar'
    @element.appendChild(titleBar)

    m = document.createElement('label')
    m.textContent = "Diary Calendar View"
    titleBar.appendChild(m)

    m = document.createElement('label')
    m.textContent = "|"
    m.className = "calendar-separator"
    titleBar.appendChild(m)

    m = document.createElement('label')
    m.textContent = 'Jump to:'
    titleBar.appendChild(m)

    m = document.createElement('label')
    m.textContent = "prev YEAR"
    m.className = "cal-cell cal-has-entry"
    m.addEventListener('click', @prevYear)
    m.calendar = this
    titleBar.appendChild(m)

    m = document.createElement('label')
    m.textContent = "TODAY"
    m.className = "cal-cell cal-has-entry"
    m.addEventListener('click', @showToday)
    m.calendar = this
    titleBar.appendChild(m)

    m = document.createElement('label')
    m.textContent = "next YEAR"
    m.className = "cal-cell cal-has-entry"
    m.addEventListener('click', @nextYear)
    m.calendar = this
    titleBar.appendChild(m)

    m = document.createElement('label')
    m.textContent = "X"
    m.className = "calendar-close calendar-navigation"
    m.addEventListener('click', @toggleEvent)
    m.main = @main
    titleBar.appendChild(m)

    #
    # main calendar content, dummy element will be replaced by update()
    #
    d = document.createElement('div')
    d.className = 'calendar-content'
    @element.appendChild(d)


  update: (now) ->
    @now = now
    @element.removeChild(@element.lastChild)
    d = document.createElement('div')
    d.className = 'calendar-content'
    @element.appendChild(d)

    #
    # add day tables for last, this and next month
    #
    table = document.createElement('table')
    d.appendChild(table)
    tr = table.insertRow(-1)
    tr.setAttribute("valign", "top")
    @dayMap = cal.getDays(
      atom.config.get('atom-diary.baseDir'),
      atom.config.get('atom-diary.filePrefix'),
      atom.config.get('atom-diary.markupLanguage')
      now)
    @addMonthNavigation(tr, -1, "<<")
    @addMonth(tr.insertCell(-1), moment(now).subtract(1, 'months'))
    @addMonth(tr.insertCell(-1), moment(now))
    @addMonth(tr.insertCell(-1), moment(now).add(1, 'months'))
    @addMonthNavigation(tr, 1, ">>")

  # Adds a month table to the root element.
  addMonth: (root, startDate) ->
    now = moment(startDate).startOf('month')
    t = document.createElement('table')
    t.className = "cal-monthtable"
    root.appendChild(t)

    #
    # add month name as a header spanning all columns
    #
    tr = t.insertRow(-1)
    tc = tr.insertCell(-1)
    tc.innerHTML = now.format("MMMM YYYY")
    tc.setAttribute("colspan", "7")
    tc.className = "cal-header"

    #
    # add weekday names as 'headers' for the days
    #
    tr = t.insertRow(-1)
    someMoment = moment(now).startOf('week')
    for i in [0...7]
      @addCell(tr, someMoment.format("dd"), @getClasses(someMoment, true))
      someMoment.add(1, 'day')

    #
    # iterate over month and add rows with days
    #
    tr = t.insertRow(-1)
    myMonth = now.month()
    myStartDay = now.weekday()
    someMoment = moment(now).startOf('week')
    year = now.format("YYYY")
    month = now.format("MM")
    for i in [0...42] # iterate over 6 rows which is the max of possible rows
      # ony cells from the month at hand shall have content
      if myMonth == someMoment.month()
        classes = @getClasses(someMoment)
        day = someMoment.format("DD")
        if @dayMap[year][month][day]
          classes += " cal-has-entry"
        @addCell(tr, day, classes, year, month, @dayMap[year][month][day])
      else
        @addCell(tr)
      if i % 7 == 6 then tr = t.insertRow(-1)
      someMoment.add(1, 'day')
    # add "hidden" to make all entries same height
    if myStartDay < 5
      tr = t.insertRow(-1)
      @addCell(tr, "00", "cal-hidden")

  addCell: (row, title, clazz, year, month, position) ->
    c = row.insertCell(-1)
    c.className = clazz
    if title
      c.innerHTML = title
    else
      c.innerHTML = ""
    if position # day at cell has a diary entry
      c.setAttribute('year', year)
      c.setAttribute('month', month)
      c.setAttribute('day', title)
      c.addEventListener("click", @openFileEvent)
    c.main = @main


  addMonthNavigation: (root, direction, character) ->
    cell = root.insertCell(-1)
    cell.innerText = character
    cell.setAttribute('dir', direction)
    cell.className = "calendar-navigation"
    cell.calendar = this
    cell.addEventListener('click', @monthNavigate)
    root.appendChild(cell)


  ##
  ## Internal routines to make life easier
  ##

  getClasses: (now, header) ->
    r = "cal-cell"
    if now.isoWeekday() > 5
      r += " cal-weekend"
    actual = moment()
    if now.isSame(actual, 'day')
      r += " cal-today"
    r

  ##
  ## Callbacks for click events
  ##

  # these are called on HTMLELement as this

  toggleEvent: (e) ->
    @main.toggleCalendar()

  openFileEvent: (e) ->
    @main.openDiaryFile(e.target.attributes.year.value,
      e.target.attributes.month.value,
      e.target.attributes.day.value)

  monthNavigate: (e) ->
    console.log "navigate to this direction: " + e.target.attributes.dir.value
    console.log "calendar is: " + @calendar
    @calendar.update(moment(@calendar.now).add(e.target.attributes.dir.value, 'month'))

  showToday: (e) ->
    @calendar.update(@calendar.main.getMoment())

  prevYear: (e) ->
    # @calendar.update(now.startOf('month').subtract(1, 'year'))
    console.log "now is #{@calendar.now.toJSON()}"
    @calendar.update(@calendar.now.year(@calendar.now.year() - 1))

  nextYear: (e) ->
    console.log "now is #{@calendar.now.toJSON()}"
    @calendar.update(@calendar.now.startOf('month').add(1, 'year'))

  ##
  ## Remaining lifecycle routines
  ##

  # Tear down any state and detach
  destroy: ->
    ## TODO remove event listeners?
    @element.remove()

  getElement: ->
    @element

  serialize: ->

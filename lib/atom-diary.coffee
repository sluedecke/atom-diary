# coffeelint: disable=max_line_length
{CompositeDisposable} = require 'atom'
path = require 'path'
moment = require 'moment'
CalendarView = require './calendar-view'
cal = require './calendar-lib'

module.exports = AtomDiary =
  subscriptions: null
  disposables: null
  myCalendar: null
  myCalendarPanel: null

  config:
    baseDir:
      title: 'Directory for your diary files'
      description: 'atom-diary will generate new diary files here and open them as needed.  If it is a relative path, it will be interpreted as a relative to your home directory (os.homedir).<br/>NOTE: special characters like ~ or $HOME are not intrpreted at the moment and left as is!'
      type: 'string'
      default: 'Diary'
    filePrefix:
      title: 'Prefix of diary files, translates to "prefix-2015-11.adoc" for Asciidoc markup'
      type: 'string'
      default: 'diary'
    diaryLocale:
      title: 'Language of the diary file'
      description: 'If you happen to have a differen system language than your diary language, you can set you diary language here.  This affects the generation of month and day names.<br/><br/>Leave empty to use your system default locale.'
      type: 'string'
      default: ''
    markupLanguage:
      title: 'Markup language to be used for diary files'
      description: 'Determines what format your diary files are created in.  Please note that changing this value does not convert existing files and you might end up with a mix of markup styles'
      type: 'string'
      default: 'Asciidoc'
      enum: ['Asciidoc', 'Markdown']


  activate: (state) ->
    @myCalendar = new CalendarView(this)
    @myCalendarPanel = atom.workspace.addBottomPanel(item: @myCalendar.getElement(), visible: false)
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:addEntry':  => @addEntry()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:showProject':  => @showProject()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:toggleCalendar':  => @toggleCalendar()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:updateCalendar':  => @updateCalendar()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:createPrintableDiary':  => @createPrintableDiary()

    @disposables = new CompositeDisposable()
    # allow for easy formatting of strings
    # as seen in: http://stackoverflow.com/a/14263681/3079262
    String.prototype.format = ->
      args = arguments
      return this.replace /{(\d+)}/g, (match, number) ->
        return if typeof args[number] isnt 'undefined' then args[number] else match


  deactivate: ->
    @subscriptions.dispose()
    @myCalendar.destroy()
    @myCalendarPanel.destroy()
    @disposables.destroy()


  serialize: ->
    calendarViewState: @myCalendar.serialize()


  updateCalendar: ->
    @myCalendar.update(@getMoment())


  toggleCalendar: ->
    console.log 'Calendarview was toggled!'
    if @myCalendarPanel.isVisible()
      @myCalendarPanel.hide()
    else
      @myCalendar.update(@getMoment())
      @myCalendarPanel.show()


  createPrintableDiary: ->
    cal.createPrintableDiary(
      atom.config.get('atom-diary.baseDir'),
      atom.config.get('atom-diary.filePrefix'),
      atom.config.get('atom-diary.markupLanguage')
    )


  openPrintableDiary: ->
    diarySummaryFile = "#{cal.absolutize(atom.config.get('atom-diary.baseDir'))}#{path.sep}#{atom.config.get('atom-diary.filePrefix')}-all.#{cal.markups[atom.config.get('atom-diary.markupLanguage')].ext}"
    atom.workspace.open(diarySummaryFile, {searchAllPanes: true})


  openFile: (fileName, closure) ->
    console.log 'will now open file: ' + fileName
    console.log 'closure is #{closure}'
    atom.workspace.open(fileName, {searchAllPanes: true}).then (editor) =>
      @disposables.add editor.getBuffer().onDidSave =>
        if @myCalendarPanel.isVisible()
          @myCalendar.update(@myCalendar.now)
      @disposables.add editor.getBuffer().onDidReload =>
        if @myCalendarPanel.isVisible()
          @myCalendar.update(@myCalendar.now)
      closure(editor)


  openDiaryFile: (year, month, day) ->
    console.log "opening diary file for #{year} #{month} #{day}"
    myMarkup = atom.config.get('atom-diary.markupLanguage')
    @openFile(
      cal.getMonthFileName(
        atom.config.get('atom-diary.baseDir'),
        atom.config.get('atom-diary.filePrefix'),
        year, month, myMarkup),
      ((e) ->
        e.scan new RegExp(cal.markups[myMarkup].regexStart + day), (result) ->
          e.setCursorBufferPosition(result.range.start, autoscroll: false)
          e.scrollToBufferPosition(result.range.start, center: true)
          result.stop()))


  # returns a localized moment
  getMoment: ->
    now = moment()
    if atom.config.get('atom-diary.diaryLocale') != ''
      now.locale(atom.config.get('atom-diary.diaryLocale'))
    now


  showProject: ->
    now = @getMoment()
    dirs = cal.getCreateDirectories(atom.config.get('atom-diary.baseDir'), now)
    console.log('opening path ' + dirs[0])
    atom.open({pathsToOpen: [dirs[0]], newWindow: false})


  addEntry: ->
    #
    # setup now and markup type
    #
    now = @getMoment()
    myMarkup = atom.config.get('atom-diary.markupLanguage')

    #
    # getCreate monthDir
    #
    dirs = cal.getCreateDirectories(atom.config.get('atom-diary.baseDir'), now)
    monthDir = dirs[1]

    #
    # determine month file and other key information
    #
    monthFileName = cal.getMonthFileName(
      atom.config.get('atom-diary.baseDir'),
      atom.config.get('atom-diary.filePrefix'),
      now.format("YYYY"),
      now.format("MM"),
      myMarkup)
    currentHeader = cal.markups[myMarkup].fileHeader.format [now.format('MMMM YYYY')]
    currentEntry = cal.markups[myMarkup].entryHeader.format [now.format('DD. MMMM, LT, dddd')]

    #
    # open new file in atom
    #
    console.log 'will now open file: ' + monthFileName
    @openFile(
      monthFileName,
      ((editor) ->
        editor.moveToBottom()
        # if the file is empty, insert boilerplate
        if (editor.getText().length is 0)
          editor.insertText(currentHeader)
        editor.insertText(currentEntry)
      ))

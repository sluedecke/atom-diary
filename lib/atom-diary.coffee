# coffeelint: disable=max_line_length
{CompositeDisposable} = require 'atom'
{Directory} = require 'atom'
mkdirp = require 'mkdirp'
moment = require 'moment'
path = require 'path'
os = require 'os'
CalendarView = require './calendar-view'

module.exports = AtomDiary =
  subscriptions: null
  myCalendar: null
  myCalendarPanel: null
  markups: {
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
    @myCalendar = new CalendarView(state.calendarViewState)
    @myCalendarPanel = atom.workspace.addBottomPanel(item: @myCalendar.getElement(), visible: false)
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:addEntry':  => @addEntry()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:showProject':  => @showProject()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:toggleCalendar':  => @toggleCalendar()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:updateCalendar':  => @updateCalendar()
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

  # returns a localized moment
  getMoment: ->
    now = moment()
    if atom.config.get('atom-diary.diaryLocale') != ''
      now.locale(atom.config.get('atom-diary.diaryLocale'))
    now

  # now is a moment
  getCreateDirectories: (now) ->
    baseDir = path.normalize(atom.config.get('atom-diary.baseDir'))
    if !path.isAbsolute(baseDir)
      baseDir = os.homedir() + path.sep + baseDir
      console.log 'baseDir converted to absolute ' + baseDir
    else
      console.log 'baseDir already is absolute ' + baseDir
    monthDir = baseDir + path.sep + now.format('YYYY')
    myDir = new Directory(monthDir)
    mkdirp.sync(myDir.getRealPathSync())
    [baseDir, monthDir]


  showProject: ->
    now = @getMoment()
    dirs = @getCreateDirectories(now)
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
    dirs = @getCreateDirectories(now)
    monthDir = dirs[1]

    #
    # getCreate month file
    #
    dayString = now.format('YYYY-MM')
    monthFileName = monthDir + path.sep + atom.config.get('atom-diary.filePrefix') + '-' + dayString + '.' + @markups[myMarkup]['ext']
    console.log 'monthFileName will be ' + monthFileName
    currentHeader = (@markups[myMarkup]['fileHeader']).format [now.format('MMMM YYYY')]
    currentEntry = (@markups[myMarkup]['entryHeader']).format [now.format('DD. MMMM, LT, dddd')]

    #
    # open new file in atom
    #
    console.log 'will now open file: ' + monthFileName
    # FIXME check if monthFileName is already open somewhere and reuse this
    # atom.workspace.open(monthFileName, {searchAllPanes: true}).then (editor) ->
    atom.workspace.open(monthFileName, {searchAllPanes: true}).then (e) ->
      editor = e
      # editor = atom.workspace.getActiveTextEditor()
      editor.moveToBottom()
      # if the file is empty, insert boilerplate
      if (editor.getText().length is 0)
        editor.insertText(currentHeader)
      editor.insertText(currentEntry)

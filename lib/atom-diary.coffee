{CompositeDisposable} = require 'atom'
{Directory} = require 'atom'
mkdirp = require 'mkdirp'
moment = require 'moment'
path = require 'path'
os = require 'os'

module.exports = AtomDiary =
  subscriptions: null
  markups: {
    'Asciidoc' : {
      'ext': 'adoc',
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
      'ext' : 'md',
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
      description: 'atom-diary will generate new diary files here and open them as needed.  If it is a relative path, it will be interpreted as a relative to your home directory (os.homedir)'
      type: 'string'
      default: 'Diary'
    filePrefix:
      title: 'Prefix of diary files, translates to "prefix-2015-11.adoc"'
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
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:add_entry':  => @add_entry()
    # allow for easy formatting of strings
    # as seen in: http://stackoverflow.com/a/14263681/3079262
    String.prototype.format = ->
      args = arguments
      return this.replace /{(\d+)}/g, (match, number) ->
        return if typeof args[number] isnt 'undefined' then args[number] else match

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  add_entry: ->
    now = moment()
    myMarkup = atom.config.get('atom-diary.markupLanguage')
    # determine current date in terms of year, month, day
    # getCreate basedir
    baseDir = path.normalize(atom.config.get('atom-diary.baseDir'))
    if !path.isAbsolute(baseDir)
      console.log 'baseDir is not absolute ' + baseDir
      baseDir = os.homedir() + path.sep + baseDir
      console.log 'baseDir converted to absolute ' + baseDir
    else
      console.log 'baseDir is absolute ' + baseDir
    baseDir = baseDir + path.sep + now.format('YYYY')
    myDir = new Directory(baseDir)
    mkdirp.sync(myDir.getRealPathSync())

    # getCreate month file
    if atom.config.get('atom-diary.diaryLocale') != ''
      now.locale(atom.config.get('atom-diary.diaryLocale'))
    console.log 'diary locale set for moments ' + now.locale()
    dayString = now.format('YYYY-MM')
    fileName = atom.config.get('atom-diary.filePrefix') + '-' + dayString + '.' + @markups[myMarkup]['ext']
    console.log 'filename will be ' + fileName
    currentHeader = (@markups[myMarkup]['fileHeader']).format [now.format('MMMM YYYY')]
    currentEntry = (@markups[myMarkup]['entryHeader']).format [now.format('DD. MMMM, LT, dddd')]

    # open new file in atom
    console.log 'will now open file: ' + baseDir + path.sep + fileName
    atom.workspace.open(baseDir + path.sep + fileName, null).then ->
      editor = atom.workspace.getActiveTextEditor()
      editor.moveToBottom()
      # if the file is empty, insert boilerplate
      if (editor.getText().length is 0)
        editor.insertText(currentHeader)
      editor.insertText(currentEntry)

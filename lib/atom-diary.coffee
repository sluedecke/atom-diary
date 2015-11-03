{CompositeDisposable} = require 'atom'

module.exports = AtomDiary =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:add_entry':  => @add_entry()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  add_entry: ->
    console.log 'AtomDiary::add_entry was called!'

    # determine current date in terms of year, month, day
    # getCreate month file
    # append entry for now
    # open file

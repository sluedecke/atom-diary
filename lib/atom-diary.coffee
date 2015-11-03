AtomDiaryView = require './atom-diary-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomDiary =
  atomDiaryView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomDiaryView = new AtomDiaryView(state.atomDiaryViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomDiaryView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-diary:add-entry': => @add_entry()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomDiaryView.destroy()

  serialize: ->
    atomDiaryViewState: @atomDiaryView.serialize()

  add_entry: ->
    console.log 'AtomDiary::add_entry was called!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

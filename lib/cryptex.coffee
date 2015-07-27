{CompositeDisposable} = require 'atom'
crypto = require './encryption'

module.exports = Cryptex =
  activate: (state) ->
    @subs = new CompositeDisposable
    @subs.add atom.commands.add 'atom-text-editor',
      'cyptex:encrypt-this-file': =>
        @encryptEditor()

  deactivate: () ->
    @subs.dispose()

  getPassword: (f) ->
    f 'foobar'

  encryptEditor: (ed = atom.workspace.getActiveTextEditor()) ->
    @getPassword (pw) =>
      text = ed.getText()
      ed.setText crypto.encode text, pw

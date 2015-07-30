{CompositeDisposable} = require 'atom'
crypto = require './encryption'

module.exports = Cryptex =
  activate: (state) ->
    @subs = new CompositeDisposable
    @subs.add atom.commands.add 'atom-text-editor',
      'bombe:encrypt-this-file': =>
        @encryptEditor()

  deactivate: () ->
    @subs.dispose()

  getPassword: (f) ->
    f 'foobar'

  chunk: (xs, n=80) ->
    for i in [0...xs.length] by n
      xs.slice i, i+n

  format: (s) -> @chunk(s).join('\n')

  encryptEditor: (ed = atom.workspace.getActiveTextEditor()) ->
    @getPassword (pw) =>
      ed.bombeKey = pw

{CompositeDisposable} = require 'atom'
crypto = require './encryption'
Dialog = require './dialog'
status = require './status'

module.exports =
  activate: (state) ->
    @subs = new CompositeDisposable
    @subs.add atom.workspace.observeTextEditors (ed) =>
      @handleOpen ed
    @subs.add atom.commands.add 'atom-text-editor',
      'bombe:encrypt-this-file': (e) =>
        @encryptEditor e.currentTarget.getModel()
      'bombe:decrypt-this-file': (e) =>
        @decryptEditor e.currentTarget.getModel()

  deactivate: () ->
    @subs.dispose()
    status.deactivate()

  consumeStatusBar: (bar) ->
    status.activate bar

  prompt: (s, f) ->
    process.nextTick =>
      d = new Dialog
        iconClass: 'icon-lock'
        prompt: s
      d[0].querySelector('atom-text-editor').style.webkitTextSecurity = 'disc'
      d.onConfirm = (pw) =>
        f pw, d
      d.attach()

  chunk: (xs, n=80) ->
    for i in [0...xs.length] by n
      xs.slice i, i+n

  format: (s) -> @chunk(s).join('\n')

  encryptEditor: (ed) ->
    @prompt 'Password for this file:', (pw, d) =>
      d.close()
      ed.bombe = {key: pw, listener: @listenSave ed}
      if ed.getPath() then ed.save()
      status.update()

  decryptEditor: (ed) ->
    if ed.bombe
      ed.bombe.listener.dispose()
      delete ed.bombe
      if ed.getPath() then ed.save()
      status.update()
    else
      @handleOpen ed

  listenSave: (ed) ->
    ed.onDidSave => @handleSave ed

  handleSave: (ed) ->
    return if ed.bombe.saving
    ed.bombe.saving = true
    text = ed.getText()
    {key} = ed.bombe
    enc = 'bombe-aes192\n' + @format crypto.encode text, key
    ed.setText enc
    ed.save()
    delete ed.bombe.saving
    ed.getBuffer().cachedDiskContents = text
    ed.undo()
    ed.undo()

  handleOpen: (ed) ->
    ls = ed.getBuffer().getLines()
    if ls[0] == 'bombe-aes192'
      ls.shift()
      enc = ls.join ''
      @prompt 'This file is encrypted. Password:', (pw, d) =>
        try
          text = crypto.decode enc, pw
        catch e
          d.showError 'Incorrect password.'
          return
        d.close()
        ed.getBuffer().cachedDiskContents = text
        ed.setText text
        ed.bombe = {key: pw, listener: @listenSave ed}
        status.update()

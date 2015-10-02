module.exports =
  activate: (bar) ->
    @bar = bar
    @createView()
    @listener = atom.workspace.observeActivePaneItem (item) =>
      @update item

  deactivate: ->
    @listener.dispose()

  createView: ->
    @view = document.createElement 'div'
    @view.classList.add 'inline-block', 'icon', 'icon-lock'

  update: (item = atom.workspace.getActivePaneItem()) ->
    encrypted = item?.bombe?
    # if encrypted
    #   console.log @tile
    if encrypted and not @tile?
      @tile = @bar.addRightTile
        item: @view
        priority: 0
    else if not encrypted and @tile?
      @tile.destroy()
      @tile = null

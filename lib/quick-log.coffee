fs   = require 'fs-plus'
path = require 'path'
util = require 'util'
proc = require 'child_process'
Subs = require 'sub-atom'

jsRegex = /^\/\/\sAdded\sby\squick-log/

module.exports =
  config:
    showLineNumbers:
      type: 'boolean'
      default: yes

  activate: ->
    @subs = new Subs
    @subs.add atom.commands.add 'atom-text-editor', "quick-log:add",  => @add()  
    @subs.add atom.commands.add 'atom-text-editor', "quick-log:clean", => @removeAll()  
    @subs.add atom.workspace.observeTextEditors (@editor) =>
      if @validExt() then @adjustAllLineNums()
      @editor = null
    @subs.add atom.workspace.onDidStopChangingActivePaneItem =>
      if @editor then @adjustAllLineNums()
      @editor = null
      @adjustAllLineNums()
    @subs.add atom.config.observe 'quick-log.showLineNumbers', => 
      for @editor in atom.workspace.getTextEditors() when @validExt()
        @adjustAllLineNums()
        @editor = null
      
  validExt: -> 
    ext = path.extname(@editor.getPath()).toLowerCase()
    @inCoffee = (ext is '.coffee')
    ext in ['.coffee','.js']

  getEditor: ->
    if @editor then return true
    @chgSub?.dispose()
    @chgSub = null
    if not (@editor = atom.workspace.getActiveTextEditor()) or not @validExt()
      @editor = null
      return false
    @chgSub = @editor.onDidStopChanging => @adjustAllLineNums()
    return true
    
  getLabel: (str) ->
    label = str.replace /\s+/g, ' '
    if (ext = path.extname label)
      label = label[0...label.length-ext.length]
    if label.length > 8 then label.replace(/[aeiou\W]/gi, '')[0...8] \
                        else label.replace /\W/g, ''
  
  add: ->
    if not @getEditor() then return
    selRange = @editor.getLastSelection().getBufferRange()
    if /^\s*qLog\(/.test  @editor.lineTextForBufferRow selRange.start.row
      @qLogRow = selRange.start.row
    else if selRange.start.isEqual selRange.end
      @qLogRow = selRange.start.row
      indent = /^\s*/.exec(@editor.lineTextForBufferRow @qLogRow)[0]
      @editor.setTextInBufferRange [[@qLogRow, 0], [@qLogRow, 0]], indent + "qLog(#{@qLogRow+1});\n"
      @addQLogJS()
    else if @qLogRow? and /^\s*qLog\(/.test  @editor.lineTextForBufferRow @qLogRow
      selText = @editor.getTextInBufferRange selRange
      line = @editor.lineTextForBufferRow @qLogRow
      if (lineParts = /(^\s*qLog\([^\)]*)\)[^\)]*$/.exec line)
        left = lineParts[1]
        val = (if left.indexOf(',') > -1 then ":'+(#{selText})" else "'")
        line = left + ", '" + @getLabel(selText) + val
        @editor.setTextInBufferRange [[@qLogRow,0],[@qLogRow,9e9]], line + ');'
        
  adjustAllLineNums: ->  
    if not @getEditor() then return
    haveQLog = no
    for row in [0..@editor.getLineCount()]
      lineNum = (if atom.config.get('quick-log.showLineNumbers') then row+1 else -1)
      if (parts = /^(\s*qLog\()\s*([-\d]+)/.exec @editor.lineTextForBufferRow row)
        haveQLog = yes
        if +parts[2] isnt lineNum
          lftCol = parts[1].length
          rgtCol = parts[0].length
          @editor.setTextInBufferRange [[row,lftCol],[row,rgtCol]], '' + lineNum, undo: 'skip'
    if haveQLog then @addQLogJS()  \
                else @removeAll()
    
  addQLogJS: ->
    if not @getEditor() then return
    haveJS = no
    @editor.scan jsRegex, (res) -> haveJS = yes; res.stop()
    if not haveJS
      appendToBuf = (str) =>
        @editor.setTextInBufferRange [[9e9,9e9],[9e9,9e9]], '\n' + str
      if @inCoffee then appendToBuf '`'
      appendToBuf @js @getLabel @editor.getTitle()
      if @inCoffee then appendToBuf '`'
      
  removeAll: ->
    if not @getEditor() then return
    row = -1
    while ++row < @editor.getLineCount()
      line = @editor.lineTextForBufferRow row
      while /^\s*qLog\(/.test line
        @editor.setTextInBufferRange [[row,0],[row+1,0]], ''
        line = @editor.lineTextForBufferRow row
      if jsRegex.test line
        firstRowToDel = row - (if @inCoffee then 1 else 0)
        @editor.setTextInBufferRange [[firstRowToDel,0],[9e9,9e9]], ''
        break
        
  deActivate: ->
    @subs.dispose()
    @chgSub?.dispose()
    
  js: (label) ->
    """
      // Added by quick-log, do not edit
      // to remove, use "quick-log:remove" (ctrl-alt-?)
      function qLog() {
        var i, str = new Date().toString().slice(16,25) + '#{label}:';
        if (arguments.length > 0)
          str += '(' + arguments[0] +')';
        for (i = 1; i < arguments.length; i++)
          str += ' ' + arguments[i];
        console.log(str);
      }
    """


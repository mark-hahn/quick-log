fs   = require 'fs-plus'
path = require 'path'
util = require 'util'
proc = require 'child_process'
Subs = require 'sub-atom'

jsRegex = /^`?\/\/\sAdded\sby\squick-log[\S\s]+\/\/\sEnd\sof\sqLog\sfunction`?/

module.exports =
  config:
    labelWidth:
      type: 'integer'
      default: 12

  activate: ->
    @subs = new Subs
    @subs.add atom.commands.add 'atom-text-editor', "quick-log:add",   => @add()  
    @subs.add atom.commands.add 'atom-text-editor', "quick-log:clean", => @removeAll()  
    @subs.add atom.workspace.observeTextEditors (@editor) =>
      if @validExt() then @adjustAllLineNums()
      @editor = null
    @subs.add atom.workspace.onDidStopChangingActivePaneItem =>
      if @editor then @adjustAllLineNums()
      @editor = null
      @adjustAllLineNums()
      
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
    label = str.replace(/\s+/g, ' ').replace /(.js|.coffee)$/, ''
    maxWidth = atom.config.get 'quick-log.labelWidth'
    if label.length > maxWidth then label.replace(/[aeiou\W]/gi, '')[0...maxWidth] \
                               else label.replace /\W/g, ''
  
  add: ->
    if not @getEditor() then return
    selRange = @editor.getLastSelection().getBufferRange()
    if /^\s*qLog\(/.test  @editor.lineTextForBufferRow selRange.start.row
      @qLogRow = selRange.start.row
    else if selRange.start.isEqual selRange.end
      @qLogRow = selRange.start.row
      indent = /^\s*/.exec(@editor.lineTextForBufferRow @qLogRow)[0]
      lineNum = @qLogRow+1
      @editor.setTextInBufferRange [[@qLogRow, 0], [@qLogRow, 0]], indent + "qLog(#{lineNum});\n"
      @addQLogJS()
    else if @qLogRow? and /^\s*qLog\(/.test  @editor.lineTextForBufferRow @qLogRow
      selText = @editor.getTextInBufferRange selRange
      line = @editor.lineTextForBufferRow @qLogRow
      if (lineParts = /(^\s*qLog\([^\)]*)\)[^\)]*$/.exec line)
        left = lineParts[1]
        val = (if left.indexOf(',') > -1 then ":',#{selText}" else "'")
        line = left + ", '" + @getLabel(selText) + val
        @editor.setTextInBufferRange [[@qLogRow,0],[@qLogRow,9e9]], line + ');'

  adjustAllLineNums: ->  
    if not @getEditor() then return
    haveQLog = no
    for row in [0..@editor.getLineCount()]
      lineNum = row+1
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
        @editor.setTextInBufferRange [[9e9,9e9],[9e9,9e9]], str
      appendToBuf '\n'
      if @inCoffee then appendToBuf '`'
      appendToBuf @js @getLabel @editor.getTitle()
      if @inCoffee then appendToBuf '`'
      appendToBuf '\n'
  
  removeAll: ->
    if not @getEditor() then return
    delOne = yes
    while delOne
      delOne = no
      @editor.scan /^\s*qLog\(/, (res) =>
        row = res.range.start.row
        @editor.setTextInBufferRange [[row, 0],[row+1, 0]], ''
        delOne = yes
        res.stop()
    @editor.scan jsRegex, (res) => 
      rowBeg = res.range.start.row - 1
      rowEnd = res.range.end.row   + 1
      @editor.setTextInBufferRange [[rowBeg,0],[rowEnd,0]], ''
      res.stop()
        
  deActivate: ->
    @subs.dispose()
    @chgSub?.dispose()
    
  js: (label) ->
    """
      // Added by quick-log, do not edit
      // to remove, use "quick-log:clean" (ctrl-alt-?)
      function qLog() {
        var i, args, str = new Date().toString().slice(16,25) + '#{label}';
        if (arguments.length) str += '(' + arguments[0] +')';
        args = [str].concat([].slice.call(arguments,1));
        console.log.apply(console,args);
      }
      // End of qLog function
    """


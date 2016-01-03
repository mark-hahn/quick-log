# lib/quick-log.coffee

fs   = require 'fs'
path = require 'path'
qLog = require('quick-log-npm')('qcklg')

module.exports =
  config:
    logToFile:
      type: 'boolean'
      default: no

  activate: ->
    atom.commands.add 'atom-text-editor', "quick-log:add", => @add()  

  add: ->
    if not (@editor = atom.workspace.getActiveTextEditor())         or
  	   not (selRange = @editor.getLastSelection().getBufferRange()) or 
       path.extname(@editor.getPath()).toLowerCase() not in ['.coffee','.js']
      return
      
    @ensureNpmRequire()
      
    if selRange.start.isEqual selRange.end
      # create new debug statement
      @row = selRange.start.row
      line = @editor.lineTextForBufferRow @row
      if not /^\s*qLog\b/.exec line
        indent = @editor.indentationForBufferRow @row
        @editor.setTextInBufferRange [[@row, 0], [@row, 0]],
          "qLog(#{@row+1});\n"
        @editor.setIndentationForBufferRow @row, indent
    else
      # add selection to debug statement
      x=1
      
  ensureNpmRequire: ->
    haveRequire = no
    @editor.scan /^\s*qLog\s*=\s*require\s*\('quick-log-npm'\)\s*\(?'\w+'\)?\s*$/, (res) ->
      haveRequire = yes
      res.stop()
    if not haveRequire  
      fileName = @editor.getTitle()  
      len = fileName.length - path.extname(fileName).length
      title = fileName[0...len].replace /[aeiou\W]/gi, ''
      title or= fileName
      @editor.setTextInBufferRange [[0, 0], [0, 0]], 
        "qLog = require('quick-log-npm')('#{title}')\n"
    @adjustAllLines()
    
  adjustAllLines: ->
    
    
          
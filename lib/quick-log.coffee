# lib/quick-log.coffee

fs   = require 'fs'
path = require 'path'
qLog  = require('quick-log-npm') 'quick-log'

module.exports =
  config:
    logToFile:
      type: 'boolean'
      default: no

  activate: ->
    atom.commands.add 'atom-text-editor', "quick-log:add", => @add()  

  add: ->
    if not (@editor = atom.workspace.getActiveTextEditor()) or
  	   not (selRange = @editor.getSelectedBufferRange())    or 
       path.extname(@editor.getPath()).toLowerCase() not in ['.coffee','js']
      return
      
    if selRange.start.isEqual selRange.end
      # create new debug statement
      row    = selRange.start.row
      indent = @editor.indentationForBufferRow row
      @editor.setTextInBufferRange [[row, 0], [row, 0]],
        "qLog(#{row});\n"
      @editor.setIndentationForBufferRow row, indent
      
    else
      # add selection to debug statement
      x=1
    
      
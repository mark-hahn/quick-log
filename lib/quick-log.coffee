
# lib/quick-log.coffee

fs   = require 'fs'
path = require 'path'
qLog = require('quick-log.npm') 'quick-log'

module.exports =
  config:
    logToFile:
      type: 'boolean'
      default: no

  activate: ->
    atom.commands.add 'atom-text-editor', "quick-log:add", => @add()  

  toggle: ->
    if not (@editor = atom.workspace.getActiveTextEditor()) or
  	   not (selRange = @editor.getSelectedBufferRange())    or 
       path.extname(@editor.getPath()).toLowerCase() not in ['.coffee','js']
      return
    
    if selRange.begin.isEqual selRange.end
      # create new debug statement
      row    = selRange.begin.row
      indent = @editor.indentationForBufferRow row
      @editor.setTextInBufferRange {column: 0, row}, 
        'qLog();\n'
      
    else
      # add selection to debug statement
      x=1
    
      
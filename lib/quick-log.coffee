fs   = require 'fs-plus'
path = require 'path'
util = require 'util'
proc = require 'child_process'
log  = (args...) -> console.log.apply console, args

module.exports =
  config:
    showLineNumbers:
      type: 'boolean'
      default: yes

  activate: ->
    atom.commands.add 'atom-text-editor', "quick-log:add",    => @add()  
    atom.commands.add 'atom-text-editor', "quick-log:remove", => @removeAll()  
    atom.config.observe 'quick-log.showLineNumbers', => 
      for editor in atom.workspace.getTextEditors() 
        @adjustAllLineNums editor

  add: ->
    if not (@editor = atom.workspace.getActiveTextEditor())         or
  	   not (selRange = @editor.getLastSelection().getBufferRange()) or 
       path.extname(@editor.getPath()).toLowerCase() not in ['.coffee','.js']
      return
    
    # @ensureNpm()  
    # @ensureNpmRequire()
    
    if /^\s*qLog\(/.test  @editor.lineTextForBufferRow selRange.start.row
      @row = selRange.start.row
    else if selRange.start.isEqual selRange.end
      @row = selRange.start.row
      indent = /^\s*/.exec(@editor.lineTextForBufferRow @row)[0]
      @editor.setTextInBufferRange [[@row, 0], [@row, 0]], indent + "qLog(#{@row+1});\n"
      @adjustAllLineNums @editor
    else if @row? and /^\s*qLog\(/.test  @editor.lineTextForBufferRow @row
      selText = @editor.getTextInBufferRange selRange
      selText = selText.replace /\s+/g, ' '
      label   = selText.replace(/[aeiou\W]/gi, '')[0...8]
      line    = @editor.lineTextForBufferRow @row
      if (lineParts = /(^\s*qLog\([^\)]*)\)[^\)]*$/.exec line)
        left = lineParts[1]
        line = left + ', "' + label
        if left.indexOf(',') > -1 then line += ':","' + selText
        @editor.setTextInBufferRange [[@row,0],[@row,9e9]], line + '");'
        
  ensureNpm: ->
    if (edPath = @editor.getPath()) not in editorPathsCheckedForNpm
      editorPathsCheckedForNpm.push edPath
      havePkg = no
      for projPath in atom.project.getPaths()
        if edPath[0...projPath.length] is projPath
          packPath = path.join projPath, 'package.json'
          havePkg = yes
          break
      if havePkg
        if fs.readFileSync(packPath).toString().indexOf('"quick-log-npm"') is -1
          stdOut = proc.execSync "npm install quick-log-npm --save", cwd: projPath
          console.log 'Added quick-log-npm to ' + packPath
      else
        console.log 'Could not find package.json. Please add "quick-log-npm" module manually'
        
  ensureNpmRequire: ->
    haveRequire = no
    @editor.scan /^\s*qLog\s*=\s*require\s*\('quick-log-npm'\)\s*\(?'\w+'\)?\s*$/, (res) ->
      haveRequire = yes
      res.stop()
    if not haveRequire  
      tabName = @editor.getTitle()  
      len = tabName.length - path.extname(tabName).length
      title = tabName[0...len].replace(/[aeiou\W]/gi, '')[0...8]
      title or= tabName
      @editor.setTextInBufferRange [[0, 0], [0, 0]], 
        "qLog = require('quick-log-npm')('#{title}')\n"
    @adjustAllLineNums @editor
  
  adjustAllLineNums: (editor) ->  
    for row in [0..editor.getLineCount()]
      if (parts = /^(\s*qLog\()\s*[-\d]+/.exec editor.lineTextForBufferRow row)
        lftCol = parts[1].length
        rgtCol = parts[0].length
        lineNum = (if atom.config.get('quick-log.showLineNumbers') then row+1 else -1)
        editor.setTextInBufferRange [[row,lftCol],[row,rgtCol]], '' + lineNum, undo: 'skip'
        
  removeAll: ->
    row = 0
    while row < @editor.getLineCount()
      while /^\s*qLog\(/.test @editor.lineTextForBufferRow row
        @editor.setTextInBufferRange [[row,0],[row+1,0]], ''
      row++
    
    
          
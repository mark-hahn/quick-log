###
  automatically inserted coffee-trace function
###
`function cT(info) {//`

fileParts = /(\\|\/)([^\\/]*)\.[^\.]*$/.exec __filename
file = (if fileParts then fileParts[2] else '')

infoParts = info.split '~'
snip = infoParts[0]
line = ':' + infoParts[1][...-3]
type = infoParts[1][-3..-3]
file = file[...(15 - line.length)] + line
while file.length < 15 then file += ' '
 
pfx = ->
  date = new Date()
  secs = date.getSeconds()
  secs = '' + (if secs < 10 then '0' + secs else secs)
  s100 = Math.floor date.getMilliseconds() / 10
  s100 = '' + (if s100 < 10 then '0' + s100 else s100)
  secs + '.' + s100 + ' ' + file + ' (' + snip + ')'

log2file = (args) -> 
  #log2fileBodyStart#
  require('fs').appendFileSync require('path').join(__dirname, 'coffee-trace.log'),
    pfx() + ' ' + require('util').inspect(args, depth: null).replace(/\s+/g, ' ') + '\n' 
  #log2fileBodyEnd#
  
return (arg) ->
  if type is 'f' 
    (args...) -> 
      console.log pfx(), args
      log2file args
      arg.apply @, args
  else 
    console.log pfx(), [arg]
    log2file [arg]
    arg
`}`

jsdom = require 'jsdom'

getval = (obj, key) ->
  k = key.shift()
  if key.length
    getval obj[k], key
  else
    obj[k]

ansi =
  codes:
    off: 0
    bold: 1
    underscore: 4
    blink: 5
    reverseVideo: 7
    conceal: 8
    fg:
      black: 30
      red: 31
      green: 32
      yellow: 33
      blue: 34
      magenda: 35
      cyan: 36
      white: 37
    bg:
      black: 40
      red: 41
      green: 42
      yellow: 43
      blue: 44
      magenta: 45
      cyan: 46
      white: 47

  getCode: (modes) ->
    csi = String.fromCharCode(0x1B) + '['
    textprop = 'm'
    modes = modes.split ','
    codes = for mode in modes
      getval(ansi.codes, mode.split '.')
    csi + codes.join(';') + textprop

  propertize: (text, modes) ->
    ansi.getCode(modes) + text + ansi.getCode('off')


module.exports = class Article
  constructor: (@html) ->

  html: ->
    @html

  ansi: ->
    doc = jsdom.jsdom @html
    ret = for elem in doc.children
      tag = elem.tagName.toLowerCase()
      if tag in ['h1', 'h2']
        ansi.propertize(elem.textContent, 'bold,underscore,fg.cyan') + "\n"
      else if tag in ['h3', 'h4']
        ansi.propertize(elem.textContent, 'bold,underscore') + "\n"
      else if tag is 'p'
        elem.textContent
      else if tag is 'pre'
        elem.textContent.replace(/^[\W]+/, '') + "\n"
      else
        elem.textContent
    ret.join('')

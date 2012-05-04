jsdom = require 'jsdom'

module.exports = class Article
  ansiCodes:
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

  _getAnsiCode: (obj, key) ->
    k = key.shift()
    if key.length
      @_getAnsiCode obj[k], key
    else
      obj[k]

  constructor: (@html) ->

  html: ->
    @html

  ansiCode: (modes) ->
    csi = String.fromCharCode(0x1B) + '['
    textprop = 'm'
    codes = []
    modes = modes.split ','
    for mode in modes
      codes.push @_getAnsiCode(@ansiCodes, mode.split '.')
    csi + codes.join(';') + textprop

  ansiProp: (text, modes) ->
    @ansiCode(modes) + text + @ansiCode('off')

  ansi: ->
    doc = jsdom.jsdom @html
    ret = []
    for elem in doc.children
      tag = elem.tagName.toLowerCase()
      if tag in ['h1', 'h2']
        ret.push @ansiProp(elem.textContent, 'bold,underscore,fg.cyan') + "\n"
      if tag in ['h3', 'h4']
        ret.push @ansiProp(elem.textContent, 'bold,underscore') + "\n"
      else if tag is 'p'
        ret.push elem.textContent
      else if tag is 'pre'
        ret.push elem.textContent.replace(/^[\W]+/, '') + "\n"
      else
        ret.push elem.textContent
    ret.join('')

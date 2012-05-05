# exec = require('child_process').exec
http = require 'http'
jsdom = require 'jsdom'
fs = require 'fs'
path = require 'path'
existsSync = fs.existsSync || path.existsSync
mkdirP = (path) ->
  dirs = path.split '/'
  _path = ''
  for dir in dirs
    _path = _path + dir + '/'
    unless existsSync _path
      fs.mkdirSync _path
fillZero = (num, n) ->
  str = num + ''
  cnt = n - str.length
  while cnt-- > 0
    str = "0" + str
  str

LOCALE_REF_URL_MAP =
  ja_JP:
    host: 'nodejs.jp'
    path: '/nodejs.org_ja/docs'
  en_US:
    host: 'nodejs.org'
    path: '/docs'

DB_DIR = __dirname + '/db'

option('-l', '--locale [LOCALE]', 'locale for reference');
option('-v', '--node-version [NODE_VERSION]', 'node version for reference');
option('-q', '--query [QUERY]', 'query for search');
defaults =
  'node-version': 'v0.6.16'
  'locale': 'ja_JP'
getopt = (option, name) ->
  if option.hasOwnProperty name
    option[name]
  else if defaults.hasOwnProperty name
    defaults[name]
  else
    null


#### Helpers ####
# getNodeVersion = (fn) ->
#   exec 'node -v', (err, stdout, stderr) ->
#     fn err, stdout.replace("\n", '')

requestReference = (url, version, success, error) ->
  console.log 'Fetching all.html..'
  http.get
    host: url.host
    path: url.path + '/' + version + '/api/all.html'
    port: 80
  , (res) ->
    unless res.statusCode is 200
      console.log 'Retry fetching with short version number..'
      # reduce most minor version and retry
      if /\d+(\.\d+){2}/.test version
        requestReference url
          , version.replace(/\.\d+$/,'')
          , success
          , error
      else
        error err if error
    else # 200
      success(res) if success

  .on 'error', (err) ->
    console.log 'Fetch failed.'
    error err if error

storeArticles = (referenceHtml, dir) ->
  console.log "Parse HTML.."
  doc = jsdom.jsdom referenceHtml, jsdom.level(1, 'core')
  console.log "Parse HTML done."
  content = doc.getElementById('apicontent')
  # remove marks ('#')
  marks = content.getElementsByClassName('mark')
  for mark in marks
    span = mark.parentNode
    span.parentNode.removeChild span
  elements = content.children
  console.log "Elements Count: " + elements.length
  _tmp = []
  idx = 0
  for element in elements
    if element.tagName.toLowerCase() in ['h1', 'h2']
      if _tmp.length
        storeArticle fillZero(idx++, 3), _tmp.join("\n"), dir
        _tmp = []
    _tmp.push element.outerHTML

normalizeFilename = (str) ->
  str = str.replace(/(\n)+/g, ' ')
           .replace('#', '')
           .replace(/[ ]+$/, '')
  encodeURIComponent str

storeArticle = (name, article, dir) ->
  mkdirP dir
  fs.writeFileSync dir + '/' + normalizeFilename(name), article
  console.log "Wrote #{dir + '/' + name}"

getTokens = (text) ->
  ret = []
  text = text.replace /\(.*\)/g, ''
         .replace /^Class\:/, ''
  tokens = text.match /\w+/g
  for token in tokens
    unless token in ret
      ret.push token.toLowerCase()
  tokens = text.match /[\w\.]+/g
  for token in tokens
    unless token in ret
      ret.push token.toLowerCase()
  ret

#### Tasks ####
task 'fetch', 'fetch reference html', (options) ->
  nodeVersion = getopt options, 'node-version'
  locale = getopt options, 'locale'
  url = LOCALE_REF_URL_MAP[locale]
  dbdir = "#{DB_DIR}/#{nodeVersion}/#{locale}"
  requestReference url
    , nodeVersion
    , (httpRes) ->
      console.log "Receiving Body.."
      _buf = [];
      httpRes.setEncoding 'utf-8'
      httpRes.on 'data', (chunk) ->
        _buf.push chunk
      httpRes.on 'end', ->
        console.log "Fetch done."
        mkdirP dbdir
        fs.writeFileSync dbdir + '/all.html', _buf.join('')
        _buf = []

task 'articles', 'generate local html articles', (options) ->
  nodeVersion = getopt options, 'node-version'
  locale = getopt options, 'locale'
  dbdir = "#{DB_DIR}/#{nodeVersion}/#{locale}"
  html = fs.readFileSync dbdir + '/all.html', 'utf-8'
  storeArticles html, dbdir

task 'index', 'make index for each articles', (options) ->
  nodeVersion = getopt options, 'node-version'
  locale = getopt options, 'locale'
  indexTags = ['h1', 'h2', 'h3']
  index = {}
  dbdir = "#{DB_DIR}/#{nodeVersion}/#{locale}"
  files = fs.readdirSync dbdir
  for file in files
    unless file in [ 'all.html', 'index.json' ]
      console.log "Processing: #{file}"
      html = fs.readFileSync dbdir + '/' + file, 'utf-8'
      doc = jsdom.jsdom html
      for tag in indexTags
        elems = doc.getElementsByTagName tag
        for elem in elems
          text = elem.textContent.replace /[ \n]+$/, ''
          tokens = getTokens(text)
          for token in tokens
            data = file
            if index.hasOwnProperty token
              unless data in index[token]
                index[token].push data
            else
              index[token] = [data]
  fs.writeFileSync dbdir + '/index.json', JSON.stringify index
  console.log "Wrote: #{dbdir + '/index.json'}"

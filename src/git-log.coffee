spawn = require('child_process').spawn


C0 = '%x00'
PRETTY_FORMAT_MAP =
  commitHash: '%H'
  abbreviatedCommitHash: '%h'
  treeHash: '%T'
  abbreviatedTreeHash: '%t'
  parentHashes: '%P'
  abbreviatedParentHashes: '%p'
  authorName: '%an'
  authorEmail: '%ae'
  authorDate: '%ad'
  authorDateRelative: '%ar'
  committerName: '%cn'
  committerEmail: '%ce'
  committerDate: '%cd'
  committerDateRelative: '%cr'
  subject: '%s'
PRETTY_FORMAT = "#{C0}#{C0}#{C0}#{(code for key, code of PRETTY_FORMAT_MAP).join C0}#{C0}#{C0}#{C0}"

parseRow = (row, returnRestIn = null) ->
  if (parts = row.split /\x00{3}/g).length >= 3 and (segments = parts[1].split /\x00/g).length is Object.keys(PRETTY_FORMAT_MAP).length
    res = {}
    res[returnRestIn] = parts.slice(2).join '\x00\x00\x00' if returnRestIn
    for key, code of PRETTY_FORMAT_MAP
      res[key] = segments.shift()
    res
  else
    null

module.exports = (path = process.cwd(), options = {}, args = [], callback = ->) ->
  if arguments.length is 2 and options?.constructor is Function
    callback = options
    options = {}
  if arguments.length is 3 and args?.constructor is Function
    callback = args
    args = []
  options.date = 'iso'
  options.pretty = "format:'#{PRETTY_FORMAT}'"
  optArgs = ['log']
  for option, value of options
    optArgs.push if option.length is 1 then "-#{option}" else "--#{option}"
    optArgs.push(value) if value isnt yes
  git = spawn 'git', optArgs.concat(args), cwd: path
  git.stderr.on 'data', (data) -> console.warn data.toString()
  entries = []
  buffer = []
  git.stdout.on 'data', (data) ->
    buffer += data.toString()
    if (details = parseRow buffer, '__rest')
      buffer = details.__rest
      delete details.__rest
      entries.push details
  git.on 'close', (code) ->
    if code
      callback new Error("git process exited with status #{code}")
    else
      callback null, entries

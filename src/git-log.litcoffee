git-log main script
===================

We gonna need `spawn` to run the `git` command

    spawn = require('child_process').spawn

Some constants for the git pretty format

    C0 = '%x00'
    C1 = '%x01'

Here we build a map of all data we can get from the git log:

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

We build the --pretty=format: option of git log here thanks to our map:

    PRETTY_FORMAT = "#{C0}#{C1}#{C0}#{(code for key, code of PRETTY_FORMAT_MAP).join C0}#{C0}#{C1}#{C0}"

The `parseRow` is used to extract one set of result from a buffer which may contain more.
If the `returnRestIn` parameter is given, the remaining of the string will be returned in that
property of the returned value

    parseRow = (row, returnRestIn = null) ->

Do we have at least 1 header and 1 footer, and does the middle contains all our segments?

      if (parts = row.split '\0\x01\0').length >= 3 and
      (segments = parts[1].split '\0').length is Object.keys(PRETTY_FORMAT_MAP).length

If yes, then prepare the resulting object and set the tailing string into the given property if we
got that parameter

        res = {}
        res[returnRestIn] = parts.slice(2).join '\0\x01\0' if returnRestIn

Loop over each segment and grab them with their appropriate property name, converting the data to
the good type if necessary

        for key, code of PRETTY_FORMAT_MAP
          value = segments.shift()
          if /Date$/.test(key)
            value = new Date(value)
          else if value is ''
            value = null
          res[key] = value

Finally return our details

        res
      else

If not a valid match or partial one, return null

        null


The main function, `gitLog`. It takes a `path` being the path of the repository and if null
would be using the current working directory. Then it takes some options that will be transformed
into git log options. Then the `args` is an array of stuff after the options such as:
['master', '--', '*.coffee']
Then comes the callback which will be called with the results array as second parameter, or the
error as first parameter if any error

The signature is: gitLog(String path[, Object options][, Array args][, Function callback])

    gitLog = (path = process.cwd(), options = {}, args = [], callback = ->) ->

If only 2 arguments and the second is a function, assume gitLog(path, callback)

      if arguments.length is 2 and options?.constructor is Function
        callback = options
        options = {}

If only 3 arguments and the last is a function, assume gitLog(path, options, callback)

      if arguments.length is 3 and args?.constructor is Function
        callback = args
        args = []

Force our own required options to read correctly the output

      options.date = 'iso'
      options.pretty = "format:#{PRETTY_FORMAT}"

Transforms all options into an array of git log arguments

      optArgs = ['log']
      for option, value of options
        if option.length is 1
          optArgs.push "-#{option}"
          optArgs.push "#{value}" if value isnt yes
        else
          optArgs.push "--#{option}#{if value isnt yes then "=#{value}" else ''}"

Call the git process

      git = spawn 'git', optArgs.concat(args), cwd: path, encoding: 'utf8'
      git.stderr.on 'data', (data) -> console.warn data.toString()
      entries = []
      buffer = ''

Each time we receive data we transform it into a string, append it to our (string) buffer, and
ask `parseRow` if it finds something to read from it. If it does, simply reset the buffer to the
tailing part (not used by parseRow) and add the entry to our array, else simply do nothing and wait
for next data

      git.stdout.on 'data', (data) ->
        buffer += data.toString()
        if (details = parseRow buffer, '__rest')
          buffer = details.__rest
          delete details.__rest
          entries.push details

When the process is done, check that our buffer does not remain empty and if not try to grab more
parts until no more part is found, then call the provided callback with the results

      git.on 'close', (code) ->
        if code
          callback new Error("git process exited with status #{code}")
        else
          while (details = parseRow buffer, '__rest')
            buffer = details.__rest
            delete details.__rest
            entries.push details
          callback null, entries


Export our gitLog function and the know list of properties for a commit

    module.exports = gitLog
    module.exports.COMMIT_PROPERTIES = Object.keys PRETTY_FORMAT_MAP

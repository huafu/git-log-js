chai = require 'chai'
global.expect = chai.expect
global.sinon = require 'sinon'
global.gitLog = require '../../index.js'

chai.use (_chai, utils) ->
  Assertion = chai.Assertion
  Assertion.addMethod 'matchCommit', (expected) ->
    commit = @_obj
    new Assertion(@_obj).to.be.an 'object'
    for prop in gitLog.COMMIT_PROPERTIES
      new Assertion(commit).to.have.property(prop)
      if expected.hasOwnProperty(prop) and not /DateRelative$/.test(prop)
        if /Date$/.test(prop)
          exp = expected[prop].toString()
          act = commit[prop].toString()
        else
          act = commit[prop]
          exp = expected[prop]
        @assert act is exp,
          'expected #{this} to have ' + prop + ' being #{exp} but got #{act}',
          'expected #{this} to have ' + prop + ' not being #{act}',
          exp,
          act
    return


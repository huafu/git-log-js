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
          new Assertion(commit[prop].toString()).to.equal expected[prop]
        else
          new Assertion(commit[prop]).to.equal expected[prop]
    return


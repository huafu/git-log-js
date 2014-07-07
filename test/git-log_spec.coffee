
describe 'git-log basics', ->

  results = null
  error = null

  before (done) ->
    gitLog null, {n: 1, reverse: yes}, ['master'], (err, data) ->
      results = data
      error = err
      done()

  after ->
    results = null
    error = null

  it 'should return an array', ->
    expect(error).to.be.null
    expect(results).to.be.an 'array'
    expect(results).to.have.length 1

  it 'should return the correct data', ->
    expect(results[0]).to.matchCommit
      commitHash: '12e02312813c4ccc7e05676ab108d7ac0b0aa392'
      abbreviatedCommitHash: '12e0231'
      treeHash: '2f744b768d0c4e57a0ff3a7b4e75f9275ddaf5ab'
      abbreviatedTreeHash: '2f744b7'
      parentHashes: null
      abbreviatedParentHashes: null
      authorName: 'Huafu Gandon'
      authorEmail: 'huafu.gandon@gmail.com'
      authorDate: 'Mon Jul 07 2014 11:30:48 GMT+0700 (ICT)'
      committerName: 'Huafu Gandon'
      committerEmail: 'huafu.gandon@gmail.com'
      committerDate: 'Mon Jul 07 2014 11:30:48 GMT+0700 (ICT)'
      subject: 'Initial commit'



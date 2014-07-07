
describe 'git-log basics', ->

  results = null
  error = null

  before (done) ->
    gitLog null, {n: 1}, ['10e0449'], (err, data) ->
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
      commitHash: '10e0449d5402a2574468f882a2fc53cacff3c8b8'
      abbreviatedCommitHash: '10e0449'
      treeHash: '406d761fba18398d5c01cabd880f17ce14e5305a'
      abbreviatedTreeHash: '406d761'
      parentHashes: 'e60f16e1ca70280d167047dfe4a3b9c2d14ad655'
      abbreviatedParentHashes: 'e60f16e'
      authorName: 'Huafu Gandon'
      authorEmail: 'huafu.gandon@gmail.com'
      authorDate: 'Mon Jul 07 2014 14:02:42 GMT+0700 (ICT)'
      committerName: 'Huafu Gandon'
      committerEmail: 'huafu.gandon@gmail.com'
      committerDate: 'Mon Jul 07 2014 14:03:21 GMT+0700 (ICT)'
      subject: 'First basic version'



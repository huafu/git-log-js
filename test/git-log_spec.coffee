
describe 'git-log', ->

  it 'should return js data', (done) ->
    gitLog {n: 1, reverse: yes}, ['master'], (err, entries) ->
      console.log {entries, err}
      done()
